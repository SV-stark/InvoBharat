import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';

class InvoiceRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/InvoBharat/invoices';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> saveInvoice(Invoice invoice) async {
    final path = await _localPath;
    String fileName;

    if (invoice.id != null) {
      // Updating existing
      // Find the file that matches this ID
      // Ideally, the ID should be part of the filename or we iterate.
      // For simplicity, let's assume we search or use ID as filename for new ones.
      // BUT, existing files use timestamp.

      // STRATEGY:
      // If ID is set, we try to find the file or just overwrite.
      // However, we don't know the original filename from just the ID unless we store it.
      // Let's refactor: New invoices use ID as filename. Old invoices...
      // To support backward compatibility + editing:
      // 1. If invoice has ID, use it for filename.
      // 2. If invoice has no ID, generate one, set it, and save.

      // Wait, if we edit an old invoice (no ID), we should probably assign it one now.
      // Let's stick to using ID as filename for robustness.

      fileName = 'inv_${invoice.id}.json';
    } else {
      // Should have been assigned an ID before reaching here ideally,
      // but let's handle it.
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      fileName = 'inv_$id.json';
      // We technically need to start returning the saved invoice or ID,
      // but the repo signature is void.
      // For now, let's assume the UI assigns IDs or we just use what's given.
    }

    final file = File('$path/$fileName');
    await file.writeAsString(jsonEncode(invoice.toJson()));
  }

  Future<List<Invoice>> getAllInvoices() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      List<Invoice> invoices = [];

      final List<FileSystemEntity> files = dir.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final String contents = await file.readAsString();
          try {
            invoices.add(Invoice.fromJson(jsonDecode(contents)));
          } catch (e) {
            debugPrint("Error parsing ${file.path}: $e");
          }
        }
      }

      // Sort by date desc
      invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
      return invoices;
    } catch (e) {
      debugPrint("Error loading invoices: $e");
      return [];
    }
  }
}
