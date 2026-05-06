import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:invobharat/providers/app_config_provider.dart';

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

    // We check if it's the same day and if the current hour is >= scheduled hour
    // and if we haven't backed up today (for daily) or this week/month.

    bool shouldBackup = false;

    if (lastBackup == null) {
      shouldBackup = true;
    } else {
      final diff = now.difference(lastBackup);
      switch (config.backupFrequency) {
        case BackupFrequency.daily:
          if (diff.inDays >= 1 && now.hour >= scheduledHour) {
            shouldBackup = true;
          }
          break;
        case BackupFrequency.weekly:
          if (diff.inDays >= 7 && now.hour >= scheduledHour) {
            shouldBackup = true;
          }
          break;
        case BackupFrequency.monthly:
          if (diff.inDays >= 30 && now.hour >= scheduledHour) {
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

    // Get default backup directory
    final docDir = await getApplicationDocumentsDirectory();
    final backupDir = config.backupPath != null
        ? Directory(config.backupPath!)
        : Directory(p.join(docDir.path, 'InvoBharat', 'AutoBackups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, 'InvoBharat', 'db.sqlite');
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception("Database file not found at $dbPath");
    }

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final outputFile = p.join(
      backupDir.path,
      'invobharat_auto_backup_$timestamp.zip',
    );

    final zipEncoder = ZipFileEncoder();
    zipEncoder.create(outputFile);
    await zipEncoder.addFile(dbFile);
    await zipEncoder.close();
  }
}
