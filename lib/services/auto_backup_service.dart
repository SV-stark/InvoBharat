import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:invobharat/providers/app_config_provider.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/services/backup_service.dart';

final autoBackupServiceProvider = Provider<AutoBackupService>((final ref) {
  final service = AutoBackupService(ref);
  ref.onDispose(service.stop);
  return service;
});

class AutoBackupService {
  final Ref _ref;
  Timer? _timer;

  AutoBackupService(this._ref);

  void start() {
    _timer?.cancel();
    // Check every hour
    _timer = Timer.periodic(
      const Duration(hours: 1),
      (final _) => checkAndBackup(),
    );
    // Also check on startup
    checkAndBackup();
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> checkAndBackup() async {
    final config = _ref.read(appConfigProvider);
    if (!config.autoBackupEnabled ||
        config.backupFrequency == BackupFrequency.none) {
      return;
    }

    final now = DateTime.now();
    final lastBackup = config.lastAutoBackup;

    // Check if it's the right time
    final timeParts = config.backupTime.split(':');
    if (timeParts.length != 2) return;
    final scheduledHour = int.tryParse(timeParts[0]) ?? 0;

    final scheduledMinute = int.tryParse(timeParts[1]) ?? 0;
    final scheduledTimeToday = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledHour,
      scheduledMinute,
    );

    bool shouldBackup = false;

    if (lastBackup == null) {
      shouldBackup = true;
    } else {
      final diff = now.difference(lastBackup);

      switch (config.backupFrequency) {
        case BackupFrequency.daily:
          // Backup if we haven't backed up today and it's past the scheduled time
          if (lastBackup.isBefore(scheduledTimeToday) &&
              now.isAfter(scheduledTimeToday)) {
            shouldBackup = true;
          }
          // Or if we've missed more than 24 hours entirely
          if (diff.inHours >= 24) {
            shouldBackup = true;
          }
          break;
        case BackupFrequency.weekly:
          if (diff.inDays >= 7 && now.isAfter(scheduledTimeToday)) {
            shouldBackup = true;
          }
          break;
        case BackupFrequency.monthly:
          if (diff.inDays >= 30 && now.isAfter(scheduledTimeToday)) {
            shouldBackup = true;
          }
          break;
        case BackupFrequency.none:
          break;
      }
    }

    if (shouldBackup) {
      try {
        await _performBackup();
        await _ref
            .read(appConfigProvider.notifier)
            .updateLastBackupDate(DateTime.now());
        debugPrint("Auto-backup completed successfully at ${DateTime.now()}");
      } catch (e) {
        debugPrint("Auto-backup failed: $e");
      }
    }
  }

  Future<void> _performBackup() async {
    final config = _ref.read(appConfigProvider);
    final db = _ref.read(databaseProvider);

    // Get default backup directory
    final docDir = await getApplicationDocumentsDirectory();
    final backupDir = config.backupPath != null
        ? Directory(config.backupPath!)
        : Directory(p.join(docDir.path, 'InvoBharat', 'AutoBackups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

    // Create a temporary file for VACUUM INTO
    // This ensures we get a clean, consistent copy of the DB including WAL data
    final tempDbPath = p.join(
      Directory.systemTemp.path,
      'invobharat_backup_$timestamp.sqlite',
    );
    final tempManifestPath = p.join(
      Directory.systemTemp.path,
      'invobharat_manifest_$timestamp.json',
    );

    try {
      // 1. Create consistent copy
      await db.vacuumInto(tempDbPath);

      final tempFile = File(tempDbPath);
      final manifestFile = File(tempManifestPath);
      await manifestFile.writeAsString(jsonEncode({'schemaVersion': db.schemaVersion}));

      final outputFile = p.join(
        backupDir.path,
        'invobharat_auto_backup_$timestamp.zip',
      );

      // 2. Zip the consistent copy
      final zipEncoder = ZipFileEncoder();
      zipEncoder.create(outputFile);
      await zipEncoder.addFile(tempFile, kDbFileName);
      await zipEncoder.addFile(manifestFile, 'manifest.json');
      await zipEncoder.close();

      // 3. Clean up temp files
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      if (await manifestFile.exists()) {
        await manifestFile.delete();
      }

      // 4. Prune old backups to free disk space
      await _pruneOldBackups(backupDir);
    } catch (e) {
      // Clean up on error
      final tempFile = File(tempDbPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      final manifestFile = File(tempManifestPath);
      if (await manifestFile.exists()) {
        await manifestFile.delete();
      }
      rethrow;
    }
  }

  Future<void> _pruneOldBackups(final Directory backupDir) async {
    try {
      if (!await backupDir.exists()) return;

      final List<FileSystemEntity> entities = await backupDir.list().toList();
      final List<MapEntry<File, DateTime>> backupsWithTime = [];

      for (final entity in entities) {
        if (entity is File &&
            p.basename(entity.path).startsWith('invobharat_auto_backup_') &&
            p.basename(entity.path).endsWith('.zip')) {
          try {
            final modTime = await entity.lastModified();
            backupsWithTime.add(MapEntry(entity, modTime));
          } catch (_) {}
        }
      }

      // Sort by modified time (oldest first)
      backupsWithTime.sort((final a, final b) => a.value.compareTo(b.value));

      final now = DateTime.now();
      const int maxBackups = 10;
      final int keepThresholdIndex = backupsWithTime.length - maxBackups;

      for (int i = 0; i < backupsWithTime.length; i++) {
        final entry = backupsWithTime[i];
        final file = entry.key;
        final age = now.difference(entry.value);

        if (i < keepThresholdIndex || age.inDays > 30) {
          try {
            await file.delete();
            debugPrint("Pruned old auto-backup: ${file.path}");
          } catch (e) {
            debugPrint("Failed to delete file ${file.path}: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to prune old auto-backups: $e");
    }
  }
}
