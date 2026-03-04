import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

import 'package:invobharat/services/csv_export_service.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';

class ImportResult {
  final int successCount;
  final int skippedCount;
  final String? skippedCsv;

  ImportResult(this.successCount, this.skippedCount, this.skippedCsv);
}

abstract class FilePickerWrapper {
  Future<String?> saveFile({
    final String? dialogTitle,
    final String? fileName,
    final List<String>? allowedExtensions,
    final FileType type = FileType.any,
  });
  Future<FilePickerResult?> pickFiles({
    final String? dialogTitle,
    final FileType type = FileType.any,
    final List<String>? allowedExtensions,
  });
}

class DefaultFilePickerWrapper implements FilePickerWrapper {
  @override
  Future<String?> saveFile({
    final String? dialogTitle,
    final String? fileName,
    final List<String>? allowedExtensions,
    final FileType type = FileType.any,
  }) {
    return FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      allowedExtensions: allowedExtensions,
      type: type,
    );
  }

  @override
  Future<FilePickerResult?> pickFiles({
    final String? dialogTitle,
    final FileType type = FileType.any,
    final List<String>? allowedExtensions,
  }) {
    return FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: type,
      allowedExtensions: allowedExtensions,
    );
  }
}

class BackupService {
  final FilePickerWrapper _filePicker;
  final CsvExportService _csvService;

  BackupService({
    final FilePickerWrapper? filePicker,
    final CsvExportService? csvService,
  }) : _filePicker = filePicker ?? DefaultFilePickerWrapper(),
       _csvService = csvService ?? CsvExportService();

  Future<String> exportData(final SqlInvoiceRepository repository) async {
    try {
      // 1. Fetch Data
      final invoices = await repository.getAllInvoices();

      // 2. Generate CSV
      final csvString = _csvService.generateInvoiceCsv(invoices);

      // 3. Save to file
      String? outputFile = await _filePicker.saveFile(
        dialogTitle: 'Save CSV Backup',
        fileName:
            'invobharat_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.csv')) {
          outputFile = '$outputFile.csv';
        }

        final file = File(outputFile);
        await file.writeAsString(csvString);
        return "Backup saved successfully to $outputFile";
      } else {
        return "Backup cancelled";
      }
    } catch (e) {
      debugPrint("Export Error: $e");
      throw Exception("Failed to export data: $e");
    }
  }

  Future<String> exportFullBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = '${dbFolder.path}/InvoBharat/db.sqlite';
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception("Database file not found at $dbPath");
      }

      // Read DB bytes
      final dbBytes = await dbFile.readAsBytes();

      // Create Archive
      final archive = Archive();
      archive.addFile(ArchiveFile('db.sqlite', dbBytes.length, dbBytes));

      // Encode to Zip
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      String? outputFile = await _filePicker.saveFile(
        dialogTitle: 'Save Full Backup (ZIP)',
        fileName:
            'invobharat_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.zip',
        allowedExtensions: ['zip'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.zip')) {
          outputFile = '$outputFile.zip';
        }

        final file = File(outputFile);
        await file.writeAsBytes(zipData);
        return "Full Backup saved to $outputFile";
      } else {
        return "Backup cancelled";
      }
    } catch (e) {
      debugPrint("Full Backup Error: $e");
      throw Exception("Failed to create full backup: $e");
    }
  }

  Future<String> restoreFullBackup() async {
    try {
      final FilePickerResult? result = await _filePicker.pickFiles(
        dialogTitle: 'Select Full Backup (ZIP)',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final zipFile = File(result.files.single.path!);
        final bytes = await zipFile.readAsBytes();

        final archive = ZipDecoder().decodeBytes(bytes);

        final dbEntry = archive.findFile('db.sqlite');
        if (dbEntry == null) {
          throw Exception("Invalid Backup: 'db.sqlite' not found inside zip.");
        }

        final prefsEntry = archive.findFile('manifest.json');
        if (prefsEntry != null) {
          final manifestContent = String.fromCharCodes(
            prefsEntry.content as List<int>,
          );
          final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
          final backedUpSchemaVersion = manifest['schemaVersion'] as int?;
          if (backedUpSchemaVersion != 5 && backedUpSchemaVersion != 6) {
            throw Exception(
              "Incompatible backup: schema version $backedUpSchemaVersion",
            );
          }
        }

        final dbFolder = await getApplicationDocumentsDirectory();
        final dbPath = '${dbFolder.path}/InvoBharat/db.sqlite';
        final dbDestFile = File(dbPath);

        String? backupPath;
        if (await dbDestFile.exists()) {
          backupPath = '$dbPath.bak';
          await dbDestFile.copy(backupPath);
        } else {
          await Directory(
            '${dbFolder.path}/InvoBharat',
          ).create(recursive: true);
        }

        try {
          if (dbEntry.isFile) {
            final data = dbEntry.content as List<int>;
            await dbDestFile.writeAsBytes(data, flush: true);
          }
          return "Restore Successful. Please restart the app manually.";
        } catch (e) {
          if (backupPath != null) {
            final backupFile = File(backupPath);
            if (await backupFile.exists()) {
              await backupFile.copy(dbPath);
            }
          }
          rethrow;
        }
      } else {
        return "Restore cancelled";
      }
    } catch (e) {
      debugPrint("Restore Error: $e");
      throw Exception("Failed to restore backup: $e");
    }
  }
}
