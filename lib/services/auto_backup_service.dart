import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:invobharat/providers/app_config_provider.dart';
import 'package:invobharat/providers/database_provider.dart';

final autoBackupServiceProvider = Provider<AutoBackupService>((final ref) {
  return AutoBackupService(ref);
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
      (final _) => _checkAndBackup(),
    );
    // Also check on startup
    _checkAndBackup();
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _checkAndBackup() async {
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

    try {
      // 1. Create consistent copy
      await db.vacuumInto(tempDbPath);

      final tempFile = File(tempDbPath);
      final outputFile = p.join(
        backupDir.path,
        'invobharat_auto_backup_$timestamp.zip',
      );

      // 2. Zip the consistent copy
      final zipEncoder = ZipFileEncoder();
      zipEncoder.create(outputFile);
      await zipEncoder.addFile(tempFile);
      await zipEncoder.close();

      // 3. Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      // Clean up on error
      final tempFile = File(tempDbPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      rethrow;
    }
  }
}
