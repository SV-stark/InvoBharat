import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/providers/app_config_provider.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/services/auto_backup_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getLibraryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;

  @override
  Future<List<String>?> getExternalCachePaths() async => [Directory.systemTemp.path];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => [Directory.systemTemp.path];

  @override
  Future<String?> getDownloadsPath() async => Directory.systemTemp.path;
}

void main() {
  late ProviderContainer container;
  late AppDatabase db;
  late Directory tempBackupDir;

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempBackupDir = Directory(p.join(Directory.systemTemp.path, 'InvoBharat_Backup_Tests'));
    if (await tempBackupDir.exists()) {
      await tempBackupDir.delete(recursive: true);
    }
    await tempBackupDir.create(recursive: true);
  });

  tearDown(() async {
    await db.close();
    if (await tempBackupDir.exists()) {
      await tempBackupDir.delete(recursive: true);
    }
  });

  void setupContainer({
    required bool enabled,
    required int frequencyIndex,
    required String backupTime,
    String? lastBackupStr,
  }) {
    SharedPreferences.setMockInitialValues({
      'auto_backup_enabled': enabled,
      'backup_frequency': frequencyIndex,
      'backup_time': backupTime,
      if (lastBackupStr != null) 'last_auto_backup': lastBackupStr,
      'backup_path': tempBackupDir.path,
    });

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
  }

  group('AutoBackupService', () {
    test('does not perform backup when disabled', () async {
      setupContainer(
        enabled: false,
        frequencyIndex: BackupFrequency.daily.index,
        backupTime: "00:00",
      );

      final service = container.read(autoBackupServiceProvider);
      
      // Wait for notifier to load config from SharedPrefs
      await container.read(appConfigProvider.notifier).setAutoBackupEnabled(false);
      
      await service.checkAndBackup();

      // Check that no ZIP file is created
      final files = tempBackupDir.listSync();
      expect(files.isEmpty, isTrue);
    });

    test('performs backup when enabled and last backup is null', () async {
      setupContainer(
        enabled: true,
        frequencyIndex: BackupFrequency.daily.index,
        backupTime: "00:00",
      );

      final service = container.read(autoBackupServiceProvider);
      
      // Force Riverpod to instantiate notifier and load state
      await container.read(appConfigProvider.notifier).setAutoBackupEnabled(true);

      await service.checkAndBackup();

      // Check that a ZIP file was created
      final files = tempBackupDir.listSync();
      expect(files.length, equals(1));
      expect(files.first.path, endsWith('.zip'));

      // Validate the created zip
      final bytes = await File(files.first.path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      expect(archive.findFile('db.sqlite'), isNotNull);
      expect(archive.findFile('manifest.json'), isNotNull);
    });

    test('skips backup when daily backup was already done recently', () async {
      // Set last backup to now
      final nowStr = DateTime.now().toIso8601String();
      setupContainer(
        enabled: true,
        frequencyIndex: BackupFrequency.daily.index,
        backupTime: "23:59", // Scheduled time late tonight, so now is before it
        lastBackupStr: nowStr,
      );

      final service = container.read(autoBackupServiceProvider);
      
      // Trigger config load
      await container.read(appConfigProvider.notifier).setAutoBackupEnabled(true);
      // Wait for a small bit so config values populate
      await Future.delayed(const Duration(milliseconds: 50));

      await service.checkAndBackup();

      final files = tempBackupDir.listSync();
      expect(files.isEmpty, isTrue);
    });
  });
}
