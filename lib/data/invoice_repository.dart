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
    final fileName = 'inv_${DateTime.now().millisecondsSinceEpoch}.json';
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
            print("Error parsing ${file.path}: $e");
          }
        }
      }
      
      // Sort by date desc
      invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
      return invoices;
    } catch (e) {
      print("Error loading invoices: $e");
      return [];
    }
  }
}
