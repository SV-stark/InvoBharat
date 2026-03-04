import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:invobharat/services/backup_service.dart';
import 'package:invobharat/services/csv_export_service.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/models/invoice.dart';

class MockFilePickerWrapper extends Mock implements FilePickerWrapper {}

class MockCsvExportService extends Mock implements CsvExportService {}

class MockInvoiceRepository extends Mock implements SqlInvoiceRepository {}

void main() {
  late BackupService backupService;
  late MockFilePickerWrapper mockFilePicker;
  late MockCsvExportService mockCsvService;
  late MockInvoiceRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FileType.any);
  });

  setUp(() {
    mockFilePicker = MockFilePickerWrapper();
    mockCsvService = MockCsvExportService();
    mockRepo = MockInvoiceRepository();

    backupService = BackupService(
      filePicker: mockFilePicker,
      csvService: mockCsvService,
    );
  });

  group('BackupService', () {
    test('exportData should generate CSV and save to file', () async {
      final invoices = <Invoice>[];
      when(() => mockRepo.getAllInvoices()).thenAnswer((_) async => invoices);
      when(
        () => mockCsvService.generateInvoiceCsv(any()),
      ).thenReturn('csvContent');

      final tempFile = File('${Directory.systemTemp.path}/test_backup.csv');
      when(
        () => mockFilePicker.saveFile(
          dialogTitle: any(named: 'dialogTitle'),
          fileName: any(named: 'fileName'),
          allowedExtensions: any(named: 'allowedExtensions'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => tempFile.path);

      final result = await backupService.exportData(mockRepo);

      expect(result, contains('Backup saved successfully'));
      expect(await tempFile.readAsString(), 'csvContent');

      // Cleanup
      if (await tempFile.exists()) await tempFile.delete();
    });

    test(
      'exportData should return cancelled if file picker returns null',
      () async {
        when(() => mockRepo.getAllInvoices()).thenAnswer((_) async => []);
        when(
          () => mockCsvService.generateInvoiceCsv(any()),
        ).thenReturn('csvContent');
        when(
          () => mockFilePicker.saveFile(
            dialogTitle: any(named: 'dialogTitle'),
            fileName: any(named: 'fileName'),
            allowedExtensions: any(named: 'allowedExtensions'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => null);

        final result = await backupService.exportData(mockRepo);
        expect(result, 'Backup cancelled');
      },
    );
  });
}
