import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:invobharat/database/database.dart' hide Invoice;
import 'package:invobharat/services/backup_service.dart';
import 'package:invobharat/services/csv_export_service.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/models/invoice.dart';

class MockFilePickerWrapper extends Mock implements FilePickerWrapper {}
class MockCsvExportService extends Mock implements CsvExportService {}
class MockInvoiceRepository extends Mock implements SqlInvoiceRepository {}

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
  late BackupService backupService;
  late MockFilePickerWrapper mockFilePicker;
  late MockCsvExportService mockCsvService;
  late MockInvoiceRepository mockRepo;
  late AppDatabase db;

  setUpAll(() {
    registerFallbackValue(FileType.any);
    registerFallbackValue(Uint8List(0));
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  setUp(() {
    mockFilePicker = MockFilePickerWrapper();
    mockCsvService = MockCsvExportService();
    mockRepo = MockInvoiceRepository();
    db = AppDatabase(NativeDatabase.memory());

    backupService = BackupService(
      filePicker: mockFilePicker,
      csvService: mockCsvService,
      db: db,
    );
  });

  tearDown(() async {
    await db.close();
    // Clean up destination folder if created
    final destDbDir = Directory(p.join(Directory.systemTemp.path, 'InvoBharat'));
    if (await destDbDir.exists()) {
      await destDbDir.delete(recursive: true);
    }
  });

  group('BackupService', () {
    test('exportData should generate CSV and save to file', () async {
      final invoices = <Invoice>[];
      when(() => mockRepo.getAllInvoices()).thenAnswer((_) async => invoices);
      when(
        () => mockCsvService.generateInvoiceCsv(any()),
      ).thenAnswer((_) async => 'csvContent');

      final tempFile = File('${Directory.systemTemp.path}/test_backup_${DateTime.now().microsecondsSinceEpoch}.csv');
      when(
        () => mockFilePicker.saveFile(
          dialogTitle: any(named: 'dialogTitle'),
          fileName: any(named: 'fileName'),
          allowedExtensions: any(named: 'allowedExtensions'),
          type: any(named: 'type'),
          bytes: any(named: 'bytes'),
        ),
      ).thenAnswer((_) async => tempFile.path);

      final result = await backupService.exportData(mockRepo);

      expect(result, contains('Backup saved successfully'));
      expect(await tempFile.readAsString(), 'csvContent');

      if (await tempFile.exists()) await tempFile.delete();
    });

    test(
      'exportData should return cancelled if file picker returns null',
      () async {
        when(() => mockRepo.getAllInvoices()).thenAnswer((_) async => []);
        when(
          () => mockCsvService.generateInvoiceCsv(any()),
        ).thenAnswer((_) async => 'csvContent');
        when(
          () => mockFilePicker.saveFile(
            dialogTitle: any(named: 'dialogTitle'),
            fileName: any(named: 'fileName'),
            allowedExtensions: any(named: 'allowedExtensions'),
            type: any(named: 'type'),
            bytes: any(named: 'bytes'),
          ),
        ).thenAnswer((_) async => null);

        final result = await backupService.exportData(mockRepo);
        expect(result, 'Backup cancelled');
      },
    );

    test('exportFullBackup should create a ZIP with db.sqlite and manifest.json', () async {
      final tempZipPath = p.join(Directory.systemTemp.path, 'test_full_backup_${DateTime.now().microsecondsSinceEpoch}.zip');
      when(
        () => mockFilePicker.saveFile(
          dialogTitle: any(named: 'dialogTitle'),
          fileName: any(named: 'fileName'),
          allowedExtensions: any(named: 'allowedExtensions'),
          type: any(named: 'type'),
          bytes: any(named: 'bytes'),
        ),
      ).thenAnswer((_) async => tempZipPath);

      final result = await backupService.exportFullBackup();
      expect(result, contains('Full Backup saved to'));

      final zipFile = File(tempZipPath);
      expect(await zipFile.exists(), isTrue);

      // Verify zip contents
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      final dbEntry = archive.findFile('db.sqlite');
      final manifestEntry = archive.findFile('manifest.json');

      expect(dbEntry, isNotNull);
      expect(manifestEntry, isNotNull);

      final manifestContent = String.fromCharCodes(manifestEntry!.content as List<int>);
      final manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;
      expect(manifestMap['schemaVersion'], equals(db.schemaVersion));

      // Clean up ZIP
      await zipFile.delete();
    });

    test('restoreFullBackup should restore db.sqlite and verify manifest.json version', () async {
      // 1. Create a dummy backup zip in memory
      final archive = Archive();
      
      final dbBytes = utf8.encode('sqlite data contents');
      archive.addFile(ArchiveFile('db.sqlite', dbBytes.length, dbBytes));
      
      final manifestBytes = utf8.encode(jsonEncode({'schemaVersion': db.schemaVersion}));
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
      
      final zipBytes = ZipEncoder().encode(archive);
      expect(zipBytes, isNotNull);

      final tempZipPath = p.join(Directory.systemTemp.path, 'test_restore_input_${DateTime.now().microsecondsSinceEpoch}.zip');
      final tempZipFile = File(tempZipPath);
      await tempZipFile.writeAsBytes(zipBytes!, flush: true);

      // Mock picking this zip file
      when(
        () => mockFilePicker.pickFile(
          dialogTitle: any(named: 'dialogTitle'),
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => PlatformFile(
            name: p.basename(tempZipPath),
            size: tempZipFile.lengthSync(),
            path: tempZipPath,
          ));

      final result = await backupService.restoreFullBackup();
      expect(result, contains('Restore Successful'));

      // Check destination file contents
      final destDbPath = p.join(Directory.systemTemp.path, 'InvoBharat', 'db.sqlite');
      final destDbFile = File(destDbPath);
      expect(await destDbFile.exists(), isTrue);
      expect(await destDbFile.readAsString(), equals('sqlite data contents'));

      // Cleanup
      if (await tempZipFile.exists()) await tempZipFile.delete();
    });

    test('restoreFullBackup should throw exception for incompatible schema version', () async {
      // 1. Create an incompatible dummy backup zip in memory
      final archive = Archive();
      
      final dbBytes = utf8.encode('sqlite data contents');
      archive.addFile(ArchiveFile('db.sqlite', dbBytes.length, dbBytes));
      
      final manifestBytes = utf8.encode(jsonEncode({'schemaVersion': 3})); // incompatible
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
      
      final zipBytes = ZipEncoder().encode(archive);
      expect(zipBytes, isNotNull);

      final tempZipPath = p.join(Directory.systemTemp.path, 'test_incompatible_${DateTime.now().microsecondsSinceEpoch}.zip');
      final tempZipFile = File(tempZipPath);
      await tempZipFile.writeAsBytes(zipBytes!, flush: true);

      // Mock picking this zip file
      when(
        () => mockFilePicker.pickFile(
          dialogTitle: any(named: 'dialogTitle'),
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => PlatformFile(
            name: p.basename(tempZipPath),
            size: tempZipFile.lengthSync(),
            path: tempZipPath,
          ));

      await expectLater(
        backupService.restoreFullBackup(),
        throwsA(isA<Exception>().having((final e) => e.toString(), 'message', contains('Incompatible backup: schema version 3'))),
      );

      // Cleanup
      if (await tempZipFile.exists()) await tempZipFile.delete();
    });
  });
}
