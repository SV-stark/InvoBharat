import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/invoice_repository.dart';
import '../models/business_profile.dart';
import '../models/invoice.dart';
import '../providers/business_profile_provider.dart';

class BackupService {
  final InvoiceRepository _invoiceRepository = InvoiceRepository();

  Future<String> exportData(WidgetRef ref) async {
    try {
      // 1. Fetch Data
      final invoices = await _invoiceRepository.getAllInvoices();
      final profile = ref.read(businessProfileProvider);

      // 2. create JSON structure
      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'profile': profile.toJson(),
        'invoices': invoices.map((e) => e.toJson()).toList(),
      };

      final jsonString = jsonEncode(backupData);

      // 3. Save to file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName:
            'invobharat_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        // file_picker might return a path without extension on some platforms (though windows usually adds it)
        if (!outputFile.toLowerCase().endsWith('.json')) {
          outputFile = '$outputFile.json';
        }

        final file = File(outputFile);
        await file.writeAsString(jsonString);
        return "Backup saved successfully to $outputFile";
      } else {
        return "Backup cancelled";
      }
    } catch (e) {
      debugPrint("Export Error: $e");
      throw Exception("Failed to export data: $e");
    }
  }

  Future<String> importData(WidgetRef ref) async {
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);

        // 2. Validate Version (Basic)
        if (!data.containsKey('version') ||
            !data.containsKey('profile') ||
            !data.containsKey('invoices')) {
          throw Exception("Invalid backup file format");
        }

        // 3. Restore Profile
        final profileMap = data['profile'];
        final newProfile = BusinessProfile.fromJson(profileMap);
        await ref
            .read(businessProfileProvider.notifier)
            .updateProfile(newProfile);

        // 4. Restore Invoices
        final List<dynamic> invoicesList = data['invoices'];
        int restoreCount = 0;
        for (var invMap in invoicesList) {
          try {
            final invoice = Invoice.fromJson(invMap);
            await _invoiceRepository.saveInvoice(invoice);
            restoreCount++;
          } catch (e) {
            debugPrint("Skipping invalid invoice record: $e");
          }
        }

        return "Successfully restored profile and $restoreCount invoices.";
      } else {
        return "Import cancelled";
      }
    } catch (e) {
      debugPrint("Import Error: $e");
      throw Exception("Failed to import data: $e");
    }
  }
}
