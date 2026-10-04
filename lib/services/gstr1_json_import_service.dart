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

      if (result.isEmpty) {
        return GstrImportResult(0, 0, "No files selected");
      }

      int totalSuccess = 0;
      int totalErrors = 0;
      final List<String> messages = [];

      for (final filePickerFile in result) {
        if (filePickerFile.path == null) continue;
        try {
          final file = File(filePickerFile.path!);
          final content = await file.readAsString();
          final decoded = json.decode(content);
          if (decoded is! Map<String, dynamic>) {
            totalErrors++;
            messages.add("${filePickerFile.name}: Invalid JSON format (expected object)");
            continue;
          }

          final importRes = await parseAndSaveJson(decoded, repository);
          totalSuccess += importRes.successCount;
          totalErrors += importRes.errorCount;
          messages.add("${filePickerFile.name}: ${importRes.message}");
        } catch (fileErr) {
          totalErrors++;
          messages.add("${filePickerFile.name}: Error: $fileErr");
          debugPrint("Failed importing file ${filePickerFile.name}: $fileErr");
        }
      }

      final summaryMsg = messages.isNotEmpty
          ? messages.join('\n')
          : "Imported $totalSuccess invoices from ${result.length} files.";

      return GstrImportResult(
        totalSuccess,
        totalErrors,
        summaryMsg,
      );
    } catch (e) {
      debugPrint("GSTR-1 JSON Import Error: $e");
      return GstrImportResult(0, 0, "Error: $e");
    }
  }

  @visibleForTesting
  static Future<GstrImportResult> parseAndSaveJson(
    final Map<String, dynamic> data,
    final InvoiceRepository repository,
  ) async {
    int success = 0;
    int errors = 0;

    // 1. Process B2B Invoices
    if (data['b2b'] is List) {
      final List<dynamic> b2bList = data['b2b'];
      for (final b2b in b2bList) {
        if (b2b is! Map<String, dynamic>) continue;
        final String ctin = b2b['ctin']?.toString() ?? '';
        final invList = b2b['inv'];
        if (invList is! List) continue;

        for (final invJson in invList) {
          if (invJson is! Map<String, dynamic>) continue;
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
    if (data['cdnr'] is List) {
      final List<dynamic> cdnrList = data['cdnr'];
      for (final cdnr in cdnrList) {
        if (cdnr is! Map<String, dynamic>) continue;
        final String ctin = cdnr['ctin']?.toString() ?? '';
        final ntList = cdnr['nt'];
        if (ntList is! List) continue;

        for (final ntJson in ntList) {
          if (ntJson is! Map<String, dynamic>) continue;
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
    if (data['b2cl'] is List) {
      final List<dynamic> b2clList = data['b2cl'];
      for (final b2cl in b2clList) {
        if (b2cl is! Map<String, dynamic>) continue;
        final invList = b2cl['inv'];
        if (invList is! List) continue;

        for (final invJson in invList) {
          if (invJson is! Map<String, dynamic>) continue;
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

    return GstrImportResult(success, errors, "Processed ($success saved, $errors failed).");
  }

  static Invoice _mapB2BToInvoice(
    final Map<String, dynamic> invJson,
    final String ctin,
  ) {
    final String inum = invJson['inum']?.toString() ?? '';
    final String idt = invJson['idt']?.toString() ?? '';
    final String pos = invJson['pos']?.toString() ?? '';
    final String rchrg = invJson['rchrg']?.toString() ?? 'N';
    final itms = invJson['itms'];
    final List<dynamic> itmsList = itms is List ? itms : [];

    final invoiceItems = <InvoiceItem>[];
    for (final itm in itmsList) {
      if (itm is! Map<String, dynamic>) continue;
      final det = itm['itm_det'];
      if (det is Map<String, dynamic>) {
        final txval = (det['txval'] as num?)?.toDouble() ?? 0.0;
        double rt = (det['rt'] as num?)?.toDouble() ?? 0.0;
        final iamt = (det['iamt'] as num?)?.toDouble() ?? 0.0;
        final camt = (det['camt'] as num?)?.toDouble() ?? 0.0;
        final samt = (det['samt'] as num?)?.toDouble() ?? 0.0;
        final csamt = (det['csamt'] as num?)?.toDouble() ?? 0.0;

        // If rate was omitted or 0 but tax amounts are present, deduce the rate
        if (rt == 0.0 && txval > 0.0) {
          if (iamt > 0.0) {
            rt = (iamt / txval) * 100.0;
          } else if (camt > 0.0 || samt > 0.0) {
            rt = ((camt + samt) / txval) * 100.0;
          }
        }

        invoiceItems.add(
          InvoiceItem(
            id: const Uuid().v4(),
            description: "Goods/Service",
            gstRate: rt,
            amount: txval,
          ),
        );

        if (csamt > 0.0) {
          invoiceItems.add(
            InvoiceItem(
              id: const Uuid().v4(),
              description: "Cess",
              gstRate: 0.0,
              amount: csamt,
            ),
          );
        }
      }
    }

    return Invoice(
      id: const Uuid().v4(),
      invoiceNo: inum,
      invoiceDate: _parseGstDate(idt),
      placeOfSupply: _mapStateCodeToName(pos),
      reverseCharge: rchrg,
      receiver: Receiver(
        name: ctin.isNotEmpty ? "Client $ctin" : "B2C Consumer",
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
    final String ntNum = ntJson['nt_num']?.toString() ?? '';
    final String ntDt = ntJson['nt_dt']?.toString() ?? '';
    final String inum = ntJson['inum']?.toString() ?? '';
    final String idt = ntJson['idt']?.toString() ?? '';
    final String nty = ntJson['nty']?.toString() ?? 'C'; // C for Credit, D for Debit
    final String pos = ntJson['pos']?.toString() ?? '';
    final itms = ntJson['itms'];
    final List<dynamic> itmsList = itms is List ? itms : [];

    final invoiceItems = <InvoiceItem>[];
    for (final itm in itmsList) {
      if (itm is! Map<String, dynamic>) continue;
      final det = itm['itm_det'];
      if (det is Map<String, dynamic>) {
        final txval = (det['txval'] as num?)?.toDouble() ?? 0.0;
        double rt = (det['rt'] as num?)?.toDouble() ?? 0.0;
        final iamt = (det['iamt'] as num?)?.toDouble() ?? 0.0;
        final camt = (det['camt'] as num?)?.toDouble() ?? 0.0;
        final samt = (det['samt'] as num?)?.toDouble() ?? 0.0;
        final csamt = (det['csamt'] as num?)?.toDouble() ?? 0.0;

        if (rt == 0.0 && txval > 0.0) {
          if (iamt > 0.0) {
            rt = (iamt / txval) * 100.0;
          } else if (camt > 0.0 || samt > 0.0) {
            rt = ((camt + samt) / txval) * 100.0;
          }
        }

        invoiceItems.add(
          InvoiceItem(
            id: const Uuid().v4(),
            description: "Adjustment",
            gstRate: rt,
            amount: txval,
          ),
        );

        if (csamt > 0.0) {
          invoiceItems.add(
            InvoiceItem(
              id: const Uuid().v4(),
              description: "Cess",
              gstRate: 0.0,
              amount: csamt,
            ),
          );
        }
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
        name: ctin.isNotEmpty ? "Client $ctin" : "B2C Consumer",
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
