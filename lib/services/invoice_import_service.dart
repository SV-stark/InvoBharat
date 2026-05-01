import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class InvoiceImportService {
  /// Picks a CSV file and imports invoices into the repository.
  /// Supports both InvoBharat format and standard GSTR-1 format.
  static Future<ImportResult> importInvoices(final InvoiceRepository repository) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        return ImportResult(0, 0, "No file selected");
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = Csv().decode(content);

      if (rows.length < 2) {
        return ImportResult(0, 0, "CSV file is empty or missing headers");
      }

      final headers = rows.first.map((final e) => e.toString().trim().toLowerCase()).toList();
      
      // Determine if it's InvoBharat format or GSTR-1 format
      final isInvoBharat = headers.contains('receiver gstin') && headers.contains('item price');
      final isGstr1 = headers.contains('gstin(recipeint)') || headers.contains('trade name(recipeint)');

      if (!isInvoBharat && !isGstr1) {
        return ImportResult(0, 0, "Unknown CSV format. Please use InvoBharat Export or GSTR-1 CSV.");
      }

      final Map<String, Invoice> invoiceMap = {};

      if (isInvoBharat) {
        _parseInvoBharat(rows, headers, invoiceMap);
      } else {
        _parseGstr1(rows, headers, invoiceMap);
      }

      for (final inv in invoiceMap.values) {
        await repository.saveInvoice(inv);
      }

      return ImportResult(invoiceMap.length, 0, "Successfully imported ${invoiceMap.length} invoices.");
    } catch (e) {
      debugPrint("Import Error: $e");
      return ImportResult(0, 0, "Error: $e");
    }
  }

  static Future<void> downloadImportTemplate() async {
    final headers = [
      'GSTIN(recipeint)',
      'Trade Name(recipeint)',
      'Invoice No',
      'Date of Invoice',
      'Invoice Value',
      'GST%',
      'Taxable Value',
      'CESS',
      'Place Of Supply',
      'RCM Applicable',
      'HSN Description',
    ];
    
    final sampleData = [
      [
        '27AAPFU0939F1ZV',
        'Test Client Corp',
        'INV-001',
        '01-05-2024',
        '1180.00',
        '18.0',
        '1000.00',
        '0.00',
        'Maharashtra',
        'No',
        'Consulting Services',
      ],
      [
        '27AAPFU0939F1ZV',
        'Test Client Corp',
        'INV-002',
        '02-05-2024',
        '525.00',
        '5.0',
        '500.00',
        '0.00',
        'Maharashtra',
        'No',
        'Printing Services',
      ],
    ];

    final csvString = Csv().encode([headers, ...sampleData]);
    
    final result = await FilePicker.saveFile(
      dialogTitle: 'Save Import Template',
      fileName: 'invobharat_gst_import_template.csv',
      allowedExtensions: ['csv'],
      type: FileType.custom,
    );

    if (result != null) {
      final file = File(result.endsWith('.csv') ? result : '$result.csv');
      await file.writeAsString(csvString);
    }
  }

  static int _parseInvoBharat(
    final List<List<dynamic>> rows,
    final List<String> headers,
    final Map<String, Invoice> invoiceMap,
  ) {
    // Map columns
    final idxInvNo = headers.indexOf('invoice no');
    final idxDate = headers.indexOf('date of invoice');
    final idxRecvName = headers.indexOf('receiver name');
    final idxRecvGstin = headers.indexOf('receiver gstin');
    final idxRecvAddr = headers.indexOf('receiver address');
    final idxRecvState = headers.indexOf('receiver state');
    
    final idxItemDesc = headers.indexOf('description');
    final idxItemHsn = headers.indexOf('hsn');
    final idxItemRate = headers.indexOf('gst rate (%)');
    final idxItemPrice = headers.indexOf('item price');
    final idxItemDiscount = headers.indexOf('item discount');
    final idxItemUnit = headers.indexOf('item unit');

    final idxDueDate = headers.indexOf('due date');
    final idxTerms = headers.indexOf('payment terms');
    final idxNotes = headers.indexOf('notes');
    final idxPos = headers.indexOf('place of supply');
    final idxRcm = headers.indexOf('rcm applicable');

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final invNo = _val(row, idxInvNo);
      if (invNo.isEmpty) continue;

      final item = InvoiceItem(
        id: const Uuid().v4(),
        description: _val(row, idxItemDesc),
        sacCode: _val(row, idxItemHsn),
        gstRate: double.tryParse(_val(row, idxItemRate)) ?? 0,
        amount: double.tryParse(_val(row, idxItemPrice)) ?? 0,
        discount: double.tryParse(_val(row, idxItemDiscount)) ?? 0,
        unit: _val(row, idxItemUnit),
      );

      if (invoiceMap.containsKey(invNo)) {
        final existing = invoiceMap[invNo]!;
        invoiceMap[invNo] = existing.copyWith(items: [...existing.items, item]);
      } else {
        invoiceMap[invNo] = Invoice(
          id: const Uuid().v4(),
          invoiceNo: invNo,
          invoiceDate: _parseDate(_val(row, idxDate)),
          dueDate: _parseDate(_val(row, idxDueDate)),
          placeOfSupply: _val(row, idxPos),
          reverseCharge: _val(row, idxRcm),
          paymentTerms: _val(row, idxTerms),
          comments: _val(row, idxNotes),
          receiver: Receiver(
            name: _val(row, idxRecvName),
            gstin: _val(row, idxRecvGstin),
            address: _val(row, idxRecvAddr),
            state: _val(row, idxRecvState),
          ),
          items: [item],
          supplier: const Supplier(),
        );
      }
    }
    return invoiceMap.length;
  }

  static int _parseGstr1(
    final List<List<dynamic>> rows,
    final List<String> headers,
    final Map<String, Invoice> invoiceMap,
  ) {
    final idxGstin = headers.indexWhere((final e) => e.contains('gstin'));
    final idxName = headers.indexWhere((final e) => e.contains('trade name') || e.contains('recipient'));
    final idxInvNo = headers.indexOf('invoice no');
    final idxDate = headers.indexOf('date of invoice');
    final idxGstRate = headers.indexOf('gst%');
    final idxTaxable = headers.indexOf('taxable value');
    final idxPos = headers.indexOf('place of supply');
    final idxRcm = headers.indexOf('rcm applicable');
    final idxHsn = headers.indexWhere((final e) => e.contains('hsn') || e.contains('description'));

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final invNo = _val(row, idxInvNo);
      if (invNo.isEmpty) continue;

      final item = InvoiceItem(
        id: const Uuid().v4(),
        description: _val(row, idxHsn).isEmpty ? "Goods/Service" : _val(row, idxHsn),
        sacCode: _val(row, idxHsn),
        gstRate: double.tryParse(_val(row, idxGstRate)) ?? 0,
        amount: double.tryParse(_val(row, idxTaxable)) ?? 0,
      );

      if (invoiceMap.containsKey(invNo)) {
        final existing = invoiceMap[invNo]!;
        invoiceMap[invNo] = existing.copyWith(items: [...existing.items, item]);
      } else {
        final pos = _val(row, idxPos);
        invoiceMap[invNo] = Invoice(
          id: const Uuid().v4(),
          invoiceNo: invNo,
          invoiceDate: _parseDate(_val(row, idxDate)),
          placeOfSupply: pos,
          reverseCharge: _val(row, idxRcm),
          receiver: Receiver(
            name: _val(row, idxName),
            gstin: _val(row, idxGstin),
            state: pos,
          ),
          items: [item],
          supplier: const Supplier(),
          status: 'Sent', // Default to Sent for imported invoices
        );
      }
    }
    return invoiceMap.length;
  }

  static String _val(final List<dynamic> row, final int idx) {
    if (idx == -1 || idx >= row.length) return '';
    return row[idx].toString().trim();
  }

  static DateTime _parseDate(final String str, [final DateTime? fallback]) {
    if (str.isEmpty) return fallback ?? DateTime.now();
    try {
      return DateFormat('dd-MM-yyyy').parse(str);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd').parse(str);
      } catch (_) {
        return fallback ?? DateTime.now();
      }
    }
  }
}

class ImportResult {
  final int successCount;
  final int errorCount;
  final String message;

  ImportResult(this.successCount, this.errorCount, this.message);
}
