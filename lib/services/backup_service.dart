import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// actually we need it to pass to CsvExport? No, just Invoices.
// But we need to Read profile list for exportAll
import '../providers/business_profile_provider.dart';
import '../providers/invoice_repository_provider.dart';
import 'package:archive/archive.dart';
import '../data/file_invoice_repository.dart';
import 'csv_export_service.dart';

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

  Future<String> exportAllProfiles(WidgetRef ref) async {
    try {
      final profiles = ref.read(businessProfileListProvider);
      final archive = Archive();

      for (final profile in profiles) {
        final repo = FileInvoiceRepository(profileId: profile.id);
        final invoices = await repo.getAllInvoices();

        final csvString = CsvExportService().generateInvoiceCsv(invoices);

        final filename =
            'profile_${profile.companyName.replaceAll(RegExp(r'[^\w\s]+'), '')}_${profile.id}.csv';

        final bytes = utf8.encode(csvString);
        archive.addFile(ArchiveFile(filename, bytes.length, bytes));
      }

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Full Backup (ZIP)',
        fileName:
            'invobharat_full_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.zip',
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

  Future<String> importData(WidgetRef ref) async {
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select CSV Backup',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        // 2. Parse CSV
        final invoices = CsvExportService().parseInvoiceCsv(content);

        if (invoices.isEmpty) {
          return "No invoices found in CSV.";
        }

        // 3. Restore to Current Profile
        final repository = ref.read(invoiceRepositoryProvider);
        int restoreCount = 0;

        // Clear existing? No, user might want to merge.
        // But duplicates? Invoice ID is generated new in parse logic to avoid collision with existing IDs if they are UUIDs.
        // Wait, parseInvoiceCsv generates NEW IDs 'restored_...'.
        // So we are safe from overwriting, but we might duplicates Invoice Nos.
        // The Repository might allow duplicate Invoice Nos (it's often just a string field).

        for (final invoice in invoices) {
          await repository.saveInvoice(invoice);
          restoreCount++;
        }

        return "Successfully restored $restoreCount invoices.";
      } else {
        return "Import cancelled";
      }
    } catch (e) {
      debugPrint("Import Error: $e");
      throw Exception("Failed to import data: $e");
    }
  }
}
