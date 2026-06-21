import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:uuid/uuid.dart';

class Gstr1JsonImportService {
  /// Picks one or more GSTR-1 JSON files and imports invoices into the repository.
  static Future<GstrImportResult> importGstr1Json(
    final InvoiceRepository repository,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return GstrImportResult(0, 0, "No files selected");
      }

      int totalSuccess = 0;
      int totalErrors = 0;
      final List<String> messages = [];

      for (final filePickerFile in result.files) {
        if (filePickerFile.path == null) continue;
        final file = File(filePickerFile.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = json.decode(content);

        final importRes = await _parseAndSaveJson(data, repository);
        totalSuccess += importRes.successCount;
        totalErrors += importRes.errorCount;
        messages.add("${filePickerFile.name}: ${importRes.message}");
      }

      return GstrImportResult(
        totalSuccess,
        totalErrors,
        "Imported $totalSuccess invoices from ${result.files.length} files.",
      );
    } catch (e) {
      debugPrint("GSTR-1 JSON Import Error: $e");
      return GstrImportResult(0, 0, "Error: $e");
    }
  }

  static Future<GstrImportResult> _parseAndSaveJson(
    final Map<String, dynamic> data,
    final InvoiceRepository repository,
  ) async {
    int success = 0;
    int errors = 0;

    // 1. Process B2B Invoices
    if (data.containsKey('b2b')) {
      final List<dynamic> b2bList = data['b2b'];
      for (final b2b in b2bList) {
        final String ctin = b2b['ctin'] ?? '';
        final List<dynamic> invList = b2b['inv'] ?? [];

        for (final invJson in invList) {
          try {
            final invoice = _mapB2BToInvoice(invJson, ctin);
            await repository.saveInvoice(invoice);
            success++;
          } catch (e) {
            errors++;
            debugPrint("Failed to parse B2B invoice: $e");
          }
        }
      }
    }

    // 2. Process Credit/Debit Notes (CDNR)
    if (data.containsKey('cdnr')) {
      final List<dynamic> cdnrList = data['cdnr'];
      for (final cdnr in cdnrList) {
        final String ctin = cdnr['ctin'] ?? '';
        final List<dynamic> ntList = cdnr['nt'] ?? [];

        for (final ntJson in ntList) {
          try {
            final invoice = _mapCDNRToInvoice(ntJson, ctin);
            await repository.saveInvoice(invoice);
            success++;
          } catch (e) {
            errors++;
            debugPrint("Failed to parse CDNR invoice: $e");
          }
        }
      }
    }

    // 3. Process B2CL (Business to Large Consumer)
    if (data.containsKey('b2cl')) {
      final List<dynamic> b2clList = data['b2cl'];
      for (final b2cl in b2clList) {
        final List<dynamic> invList = b2cl['inv'] ?? [];
        for (final invJson in invList) {
          try {
            final invoice = _mapB2BToInvoice(invJson, ''); // B2C has no ctin
            await repository.saveInvoice(invoice);
            success++;
          } catch (e) {
            errors++;
            debugPrint("Failed to parse B2CL invoice: $e");
          }
        }
      }
    }

    return GstrImportResult(success, errors, "Processed.");
  }

  static Invoice _mapB2BToInvoice(
    final Map<String, dynamic> invJson,
    final String ctin,
  ) {
    final String inum = invJson['inum'] ?? '';
    final String idt = invJson['idt'] ?? '';
    final String pos = invJson['pos'] ?? '';
    final String rchrg = invJson['rchrg'] ?? 'N';
    final List<dynamic> itms = invJson['itms'] ?? [];

    final invoiceItems = <InvoiceItem>[];
    for (final itm in itms) {
      final det = itm['itm_det'];
      if (det != null) {
        invoiceItems.add(
          InvoiceItem(
            id: const Uuid().v4(),
            description: "Goods/Service",
            gstRate: (det['rt'] as num?)?.toDouble() ?? 0,
            amount: (det['txval'] as num?)?.toDouble() ?? 0,
          ),
        );
      }
    }

    return Invoice(
      id: const Uuid().v4(),
      invoiceNo: inum,
      invoiceDate: _parseGstDate(idt),
      placeOfSupply: _mapStateCodeToName(pos),
      reverseCharge: rchrg,
      receiver: Receiver(
        name: "Client $ctin",
        gstin: ctin,
        state: _mapStateCodeToName(pos),
      ),
      items: invoiceItems,
      supplier: const Supplier(),
      status: 'Sent',
    );
  }

  static Invoice _mapCDNRToInvoice(
    final Map<String, dynamic> ntJson,
    final String ctin,
  ) {
    final String ntNum = ntJson['nt_num'] ?? '';
    final String ntDt = ntJson['nt_dt'] ?? '';
    final String inum = ntJson['inum'] ?? '';
    final String idt = ntJson['idt'] ?? '';
    final String nty = ntJson['nty'] ?? 'C'; // C for Credit, D for Debit
    final String pos = ntJson['pos'] ?? '';
    final List<dynamic> itms = ntJson['itms'] ?? [];

    final invoiceItems = <InvoiceItem>[];
    for (final itm in itms) {
      final det = itm['itm_det'];
      if (det != null) {
        invoiceItems.add(
          InvoiceItem(
            id: const Uuid().v4(),
            description: "Adjustment",
            gstRate: (det['rt'] as num?)?.toDouble() ?? 0,
            amount: (det['txval'] as num?)?.toDouble() ?? 0,
          ),
        );
      }
    }

    return Invoice(
      id: const Uuid().v4(),
      invoiceNo: ntNum,
      invoiceDate: _parseGstDate(ntDt),
      placeOfSupply: _mapStateCodeToName(pos),
      originalInvoiceNumber: inum,
      originalInvoiceDate: _parseGstDate(idt),
      receiver: Receiver(
        name: "Client $ctin",
        gstin: ctin,
        state: _mapStateCodeToName(pos),
      ),
      items: invoiceItems,
      supplier: const Supplier(),
      status: 'Sent',
      type: nty == 'C' ? InvoiceType.creditNote : InvoiceType.debitNote,
    );
  }

  static DateTime _parseGstDate(final String str) {
    if (str.isEmpty) return DateTime.now();
    try {
      // GST Portal uses dd-MM-yyyy
      return DateFormat('dd-MM-yyyy').parse(str);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd').parse(str);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  static String _mapStateCodeToName(final String code) {
    final Map<String, String> states = {
      '01': 'Jammu & Kashmir',
      '02': 'Himachal Pradesh',
      '03': 'Punjab',
      '04': 'Chandigarh',
      '05': 'Uttarakhand',
      '06': 'Haryana',
      '07': 'Delhi',
      '08': 'Rajasthan',
      '09': 'Uttar Pradesh',
      '10': 'Bihar',
      '11': 'Sikkim',
      '12': 'Arunachal Pradesh',
      '13': 'Nagaland',
      '14': 'Manipur',
      '15': 'Mizoram',
      '16': 'Tripura',
      '17': 'Meghalaya',
      '18': 'Assam',
      '19': 'West Bengal',
      '20': 'Jharkhand',
      '21': 'Odisha',
      '22': 'Chhattisgarh',
      '23': 'Madhya Pradesh',
      '24': 'Gujarat',
      '25': 'Daman & Diu',
      '26': 'Dadra & Nagar Haveli',
      '27': 'Maharashtra',
      '29': 'Karnataka',
      '30': 'Goa',
      '31': 'Lakshadweep',
      '32': 'Kerala',
      '33': 'Tamil Nadu',
      '34': 'Puducherry',
      '35': 'Andaman & Nicobar Islands',
      '36': 'Telangana',
      '37': 'Andhra Pradesh',
      '38': 'Ladakh',
      '97': 'Other Territory',
    };
    return states[code] ?? code;
  }
}

class GstrImportResult {
  final int successCount;
  final int errorCount;
  final String message;

  GstrImportResult(this.successCount, this.errorCount, this.message);
}
