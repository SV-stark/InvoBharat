import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/business_profile.dart';
import '../models/invoice.dart';
import '../providers/business_profile_provider.dart';

import '../providers/invoice_repository_provider.dart';
import 'package:archive/archive.dart';
import '../data/file_invoice_repository.dart';

class BackupService {
  // final InvoiceRepository _invoiceRepository = InvoiceRepository(); // Removed

  Future<String> exportData(WidgetRef ref) async {
    try {
      // 1. Fetch Data
      final invoices =
          await ref.read(invoiceRepositoryProvider).getAllInvoices();
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

  Future<String> exportAllProfiles(WidgetRef ref) async {
    try {
      final profiles = ref.read(businessProfileListProvider);
      final archive = Archive();

      for (final profile in profiles) {
        // Fetch invoices for this profile
        // We need to instantiate a temporary repository access or use the provider if we can switch it?
        // Provider depends on 'current profile'.
        // So we manually create InvoiceRepository with the profile ID.
        final repo = FileInvoiceRepository(profileId: profile.id);
        final invoices = await repo.getAllInvoices();

        final backupData = {
          'version': 1,
          'timestamp': DateTime.now().toIso8601String(),
          'profile': profile.toJson(),
          'invoices': invoices.map((e) => e.toJson()).toList(),
        };

        final jsonString = jsonEncode(backupData);
        final filename =
            'profile_${profile.companyName.replaceAll(RegExp(r'[^\w\s]+'), '')}_${profile.id}.json';

        final bytes = utf8.encode(jsonString);
        archive.addFile(ArchiveFile(filename, bytes.length, bytes));
      }

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      // Save to file

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
            .read(businessProfileNotifierProvider)
            .updateProfile(newProfile);

        // 4. Restore Invoices
        final List<dynamic> invoicesList = data['invoices'];
        int restoreCount = 0;
        final repository = ref.read(invoiceRepositoryProvider);
        for (var invMap in invoicesList) {
          try {
            final invoice = Invoice.fromJson(invMap);
            await repository.saveInvoice(invoice);
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
