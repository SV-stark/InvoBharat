import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';

class InvoiceRepository {
  final String profileId;

  InvoiceRepository({required this.profileId});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // New path structure: .../InvoBharat/profiles/<profileId>/invoices
    final path = '${directory.path}/InvoBharat/profiles/$profileId/invoices';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  // Static helper to get path for a specific profile (useful for backups/migration)
  static Future<String> getProfilePath(String pid) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/InvoBharat/profiles/$pid/invoices';
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
      fileName = 'inv_${invoice.id}.json';
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      fileName = 'inv_$id.json';
    }

    final file = File('$path/$fileName');
    await file.writeAsString(jsonEncode(invoice.toJson()));
  }

  Future<Invoice?> getInvoice(String id) async {
    try {
      final path = await _localPath;
      final file = File('$path/inv_$id.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return Invoice.fromJson(jsonDecode(content));
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching invoice $id: $e");
      return null;
    }
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

  // Fetch invoices for a specific profile ID (static or instance method)
  static Future<List<Invoice>> getAllInvoicesForProfile(String pid) async {
    try {
      final path = await getProfilePath(pid);
      final dir = Directory(path);
      List<Invoice> invoices = [];

      if (!dir.existsSync()) return [];

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
      return invoices;
    } catch (e) {
      debugPrint("Error loading invoices for profile $pid: $e");
      return [];
    }
  }
}
