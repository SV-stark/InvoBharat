import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

import '../providers/invoice_repository_provider.dart';
// import '../data/file_invoice_repository.dart'; // Unused
import 'csv_export_service.dart';

class ImportResult {
  final int successCount;
  final int skippedCount;
  final String? skippedCsv;

  ImportResult(this.successCount, this.skippedCount, this.skippedCsv);
}

class BackupService {
  Future<String> exportData(WidgetRef ref) async {
    try {
      // 1. Fetch Data
      final invoices =
          await ref.read(invoiceRepositoryProvider).getAllInvoices();

      // 2. Generate CSV
      final csvString = CsvExportService().generateInvoiceCsv(invoices);

      // 3. Save to file
      String? outputFile = await FilePicker.platform.saveFile(
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

  Future<String> exportFullBackup(WidgetRef ref) async {
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

      String? outputFile = await FilePicker.platform.saveFile(
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

  Future<String> restoreFullBackup(WidgetRef ref) async {
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Full Backup (ZIP)',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final zipFile = File(result.files.single.path!);
        final bytes = await zipFile.readAsBytes();

        final archive = ZipDecoder().decodeBytes(bytes);

        // Find db.sqlite
        final dbEntry = archive.findFile('db.sqlite');

        if (dbEntry == null) {
          throw Exception("Invalid Backup: 'db.sqlite' not found inside zip.");
        }

        // 2. Prepare Paths
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbPath = '${dbFolder.path}/InvoBharat/db.sqlite';
        final dbDestFile = File(dbPath);

        // 3. Backup Current (Safety)
        if (await dbDestFile.exists()) {
          await dbDestFile.copy('$dbPath.bak');
        } else {
          // Create dir if needed? Database class does it but safe to check
          await Directory('${dbFolder.path}/InvoBharat')
              .create(recursive: true);
        }

        // 4. Overwrite
        if (dbEntry.isFile) {
          final data = dbEntry.content as List<int>;
          await dbDestFile.writeAsBytes(data, flush: true);
        }

        return "Restore Successful. Please RESTART the app to load new data.";
      } else {
        return "Restore cancelled";
      }
    } catch (e) {
      debugPrint("Restore Error: $e");
      throw Exception("Failed to restore backup: $e");
    }
  }
}
