import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/gst_utils.dart';
import 'package:invobharat/utils/einvoice_exporter.dart';
import 'package:intl/intl.dart';
import 'package:csv_plus/csv_plus.dart';

class GstrService {
  Future<String> generateGstr1CsvAsync(final List<Invoice> invoices) async {
    return Isolate.run(() => generateGstr1Csv(invoices));
  }

  Future<String> generateGstr1PortalJsonAsync(
    final List<Invoice> invoices, {
    final String gstin = '',
    final String fp = '',
  }) async {
    return Isolate.run(
      () => generateGstr1PortalJson(invoices, gstin: gstin, fp: fp),
    );
  }

  static Future<String?> exportGstr1PortalJson(
    final List<Invoice> invoices, {
    final String gstin = '',
    final String fp = '',
  }) async {
    final jsonContent = await GstrService().generateGstr1PortalJsonAsync(
      invoices,
      gstin: gstin,
      fp: fp,
    );
    final bytes = Uint8List.fromList(utf8.encode(jsonContent));
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return FileSaver.instance.saveFile(
      name: 'GSTR1_Portal_$timestamp',
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
  }

  static dynamic _sanitize(final dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    if (str.isEmpty) return str;
    final firstChar = str[0];
    if (firstChar == '=' ||
        firstChar == '+' ||
        firstChar == '-' ||
        firstChar == '@' ||
        firstChar == '\t' ||
        firstChar == '\r') {
      return "'$str";
    }
    return str;
  }

  String generateGstr1Csv(final List<Invoice> invoices) {
    final validInvoices = invoices
        .where(
          (inv) =>
              !inv.isDeleted &&
              inv.type != InvoiceType.deliveryChallan &&
              !inv.isCancelled,
        )
        .toList();

    // Header based on user request
    final List<List<dynamic>> rows = [];

    // Add Header
    rows.add([
      'GSTIN(recipeint)',
      'Trade Name(recipeint)',
      'Invoice No',
      'Date of Invoice',
      'Invoice Value',
      'GST%',
      'Taxable Value',
      'CGST',
      'SGST',
      'IGST',
      'CESS',
      'Place Of Supply',
      'RCM Applicable',
      'HSN Details',
      'HSN Description',
      'type',
    ]);

    for (final inv in validInvoices) {
      final isCreditNote = inv.type == InvoiceType.creditNote;
      final multiplier = isCreditNote ? -1.0 : 1.0;
      final date = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);
      final receiverName = inv.receiver.name;
      final gstin = inv.receiver.gstin;
      final invoiceValue = inv.grandTotal * multiplier;

      final state = inv.receiver.state.isEmpty
          ? inv.placeOfSupply
          : inv.receiver.state;

      final stateCode = inv.receiver.stateCode.trim().isNotEmpty
          ? inv.receiver.stateCode.trim()
          : (gstin.length >= 2
                ? (GstUtils.getStateCode(gstin) ??
                      EInvoiceExporter.getStateCode(state, gstin))
                : EInvoiceExporter.getStateCode(state, gstin));

      final placeOfSupply =
          (stateCode.isNotEmpty && !state.startsWith('$stateCode-'))
          ? "$stateCode-$state"
          : state;

      final rcm = inv.reverseCharge;
      const cess = "0.00";
      final type = isCreditNote
          ? (gstin.trim().isNotEmpty ? 'CDNR' : 'CDNUR')
          : (gstin.trim().isNotEmpty ? 'B2B' : 'B2C');

      if (inv.items.isEmpty) {
        rows.add([
          _sanitize(gstin),
          _sanitize(receiverName),
          _sanitize(inv.invoiceNo),
          date,
          invoiceValue.toStringAsFixed(2),
          0,
          0.00,
          0.00,
          0.00,
          0.00,
          cess,
          _sanitize(placeOfSupply),
          _sanitize(rcm),
          '',
          '',
          type,
        ]);
      } else {
        for (int i = 0; i < inv.items.length; i++) {
          final item = inv.items[i];
          final isFirstItem = i == 0;
          final gstRate = item.gstRate;
          final taxableValue = inv.itemTaxableValue(item) * multiplier;
          final cgst = inv.itemCgstAmount(item) * multiplier;
          final sgst = inv.itemSgstAmount(item) * multiplier;
          final igst = inv.itemIgstAmount(item) * multiplier;
          final itemCess = inv.itemCessAmount(item) * multiplier;
          final hsnDesc = item.description;
          final hsnDetails = item.sacCode;

          rows.add([
            _sanitize(gstin),
            _sanitize(receiverName),
            _sanitize(inv.invoiceNo),
            date,
            isFirstItem ? invoiceValue.toStringAsFixed(2) : '0.00',
            gstRate.toStringAsFixed(2),
            taxableValue.toStringAsFixed(2),
            cgst.toStringAsFixed(2),
            sgst.toStringAsFixed(2),
            igst.toStringAsFixed(2),
            itemCess.toStringAsFixed(2),
            _sanitize(placeOfSupply),
            _sanitize(rcm),
            _sanitize(hsnDetails),
            _sanitize(hsnDesc),
            type,
          ]);
        }
      }
    }

    return const CsvCodec().encode(rows);
  }

  /// Generates GSTN Offline Tool compatible GSTR-1 JSON (b2b, b2cl, b2cs, exp, cdnr, cdnur, hsn, doc_issue)
  String generateGstr1PortalJson(
    final List<Invoice> invoices, {
    final String gstin = '',
    final String fp = '',
  }) {
    final nonDeletedInvoices = invoices
        .where((inv) => !inv.isDeleted)
        .toList();
    final validInvoices = nonDeletedInvoices
        .where(
          (inv) =>
              inv.type != InvoiceType.deliveryChallan && !inv.isCancelled,
        )
        .toList();

    final dateFmt = DateFormat('dd-MM-yyyy');
    final b2bByCtin = <String, List<Map<String, dynamic>>>{};
    final b2clByPos = <String, List<Map<String, dynamic>>>{};
    final b2csGrouped = <String, Map<String, dynamic>>{};
    final expByTyp = <String, List<Map<String, dynamic>>>{};
    final cdnrByCtin = <String, List<Map<String, dynamic>>>{};
    final cdnurList = <Map<String, dynamic>>[];
    final hsnGrouped = <String, Map<String, dynamic>>{};

    for (final inv in validInvoices) {
      final isNote =
          inv.type == InvoiceType.creditNote ||
          inv.type == InvoiceType.debitNote;
      final isCreditNote = inv.type == InvoiceType.creditNote;
      final multiplier = isCreditNote ? -1.0 : 1.0;

      final ctin = inv.receiver.gstin.trim().toUpperCase();
      final isB2B = ctin.isNotEmpty;
      final rawState = inv.placeOfSupply.isNotEmpty
          ? inv.placeOfSupply
          : inv.receiver.state;
      final posCode =
          GstUtils.getStateCodeFromInput(rawState) ??
          GstUtils.getStateCodeFromInput(inv.receiver.stateCode) ??
          (ctin.length >= 2
              ? GstUtils.getStateCodeFromInput(ctin.substring(0, 2))
              : null) ??
          '07';

      // Group items by GST rate for GSTN 'itms' array
      final itemsByRate = <double, Map<String, double>>{};
      for (final item in inv.items) {
        final rate = item.gstRate;
        final txval = inv.itemTaxableValue(item);
        final iamt = inv.itemIgstAmount(item);
        final camt = inv.itemCgstAmount(item);
        final samt = inv.itemSgstAmount(item);
        final csamt = inv.itemCessAmount(item);

        final bucket = itemsByRate.putIfAbsent(
          rate,
          () => {
            'txval': 0.0,
            'iamt': 0.0,
            'camt': 0.0,
            'samt': 0.0,
            'csamt': 0.0,
          },
        );
        bucket['txval'] = bucket['txval']! + txval;
        bucket['iamt'] = bucket['iamt']! + iamt;
        bucket['camt'] = bucket['camt']! + camt;
        bucket['samt'] = bucket['samt']! + samt;
        bucket['csamt'] = bucket['csamt']! + csamt;

        // Populate HSN summary
        final hsnCode = item.cleanSacCode.isEmpty ? '998311' : item.cleanSacCode;
        final uqc = item.codeType == 'SAC'
            ? 'NA'
            : EInvoiceExporter.getGstUnitCode(item.unit);
        final hsnKey = '$hsnCode|$uqc|${rate.toStringAsFixed(2)}';
        final hsnEntry = hsnGrouped.putIfAbsent(
          hsnKey,
          () => {
            'hsn_sc': hsnCode,
            'desc': EInvoiceExporter.cleanText(
              item.description,
              30,
              'Goods/Services',
            ),
            'uqc': uqc,
            'qty': 0.0,
            'rt': rate,
            'txval': 0.0,
            'iamt': 0.0,
            'camt': 0.0,
            'samt': 0.0,
            'csamt': 0.0,
          },
        );
        hsnEntry['qty'] =
            (hsnEntry['qty'] as double) + (item.quantity * multiplier);
        hsnEntry['txval'] =
            (hsnEntry['txval'] as double) + (txval * multiplier);
        hsnEntry['iamt'] = (hsnEntry['iamt'] as double) + (iamt * multiplier);
        hsnEntry['camt'] = (hsnEntry['camt'] as double) + (camt * multiplier);
        hsnEntry['samt'] = (hsnEntry['samt'] as double) + (samt * multiplier);
        hsnEntry['csamt'] =
            (hsnEntry['csamt'] as double) + (csamt * multiplier);
      }

      int itemIndex = 1;
      final itmsJson = itemsByRate.entries.map((final e) {
        final rate = e.key;
        final b = e.value;
        final det = <String, dynamic>{
          'txval': double.parse(b['txval']!.toStringAsFixed(2)),
          'rt': double.parse(rate.toStringAsFixed(2)),
          'csamt': double.parse(b['csamt']!.toStringAsFixed(2)),
        };
        if (inv.isInterState) {
          det['iamt'] = double.parse(b['iamt']!.toStringAsFixed(2));
        } else {
          det['camt'] = double.parse(b['camt']!.toStringAsFixed(2));
          det['samt'] = double.parse(b['samt']!.toStringAsFixed(2));
        }
        return {'num': itemIndex++, 'itm_det': det};
      }).toList();

      final invTyp = inv.supplyType == SupplyType.sezWithPayment
          ? 'SEWP'
          : (inv.supplyType == SupplyType.sezWithLut ? 'SEWOP' : 'R');

      if (isNote) {
        final noteObj = <String, dynamic>{
          'ntty': isCreditNote ? 'C' : 'D',
          'nty': isCreditNote ? 'C' : 'D',
          'nt_num': inv.invoiceNo,
          'nt_dt': dateFmt.format(inv.invoiceDate),
          'inum': inv.originalInvoiceNumber ?? '',
          'idt': inv.originalInvoiceDate != null
              ? dateFmt.format(inv.originalInvoiceDate!)
              : dateFmt.format(inv.invoiceDate),
          'val': double.parse(inv.grandTotal.toStringAsFixed(2)),
          'pos': posCode,
          'rchrg': inv.reverseCharge == 'Y' ? 'Y' : 'N',
          'inv_typ': invTyp,
          'itms': itmsJson,
        };
        if (isB2B) {
          cdnrByCtin.putIfAbsent(ctin, () => []).add(noteObj);
        } else {
          cdnurList.add(noteObj);
        }
      } else if (inv.supplyType.isExport) {
        final expTyp = inv.supplyType == SupplyType.exportWithPayment
            ? 'WPAY'
            : 'WOPAY';
        expByTyp.putIfAbsent(expTyp, () => []).add({
          'inum': inv.invoiceNo,
          'idt': dateFmt.format(inv.invoiceDate),
          'val': double.parse(inv.grandTotal.toStringAsFixed(2)),
          'sbpcode': '',
          'sbnum': '',
          'sbdt': '',
          'itms': itmsJson,
        });
      } else if (isB2B) {
        b2bByCtin.putIfAbsent(ctin, () => []).add({
          'inum': inv.invoiceNo,
          'idt': dateFmt.format(inv.invoiceDate),
          'val': double.parse(inv.grandTotal.toStringAsFixed(2)),
          'pos': posCode,
          'rchrg': inv.reverseCharge == 'Y' ? 'Y' : 'N',
          'inv_typ': invTyp,
          'itms': itmsJson,
        });
      } else if (inv.isInterState && inv.grandTotal > 250000) {
        // B2CL: Inter-state B2C invoice with value > Rs 2.5 Lakh
        b2clByPos.putIfAbsent(posCode, () => []).add({
          'inum': inv.invoiceNo,
          'idt': dateFmt.format(inv.invoiceDate),
          'val': double.parse(inv.grandTotal.toStringAsFixed(2)),
          'pos': posCode,
          'itms': itmsJson,
        });
      } else {
        // B2CS: Aggregated by POS + Rate + Supply Type
        for (final e in itemsByRate.entries) {
          final rate = e.key;
          final b = e.value;
          final splyTy = inv.isInterState ? 'INTER' : 'INTRA';
          final key = '$posCode|$splyTy|${rate.toStringAsFixed(2)}';
          final b2cs = b2csGrouped.putIfAbsent(
            key,
            () => {
              'sply_ty': splyTy,
              'pos': posCode,
              'typ': 'OE',
              'rt': double.parse(rate.toStringAsFixed(2)),
              'txval': 0.0,
              'iamt': 0.0,
              'camt': 0.0,
              'samt': 0.0,
              'csamt': 0.0,
            },
          );
          b2cs['txval'] = (b2cs['txval'] as double) + b['txval']!;
          b2cs['iamt'] = (b2cs['iamt'] as double) + b['iamt']!;
          b2cs['camt'] = (b2cs['camt'] as double) + b['camt']!;
          b2cs['samt'] = (b2cs['samt'] as double) + b['samt']!;
          b2cs['csamt'] = (b2cs['csamt'] as double) + b['csamt']!;
        }
      }
    }

    int hsnSeq = 1;
    final hsnData = hsnGrouped.values.map((final h) {
      return {
        'num': hsnSeq++,
        'hsn_sc': h['hsn_sc'],
        'desc': h['desc'],
        'uqc': h['uqc'],
        'qty': double.parse((h['qty'] as double).toStringAsFixed(2)),
        'rt': double.parse((h['rt'] as double).toStringAsFixed(2)),
        'txval': double.parse((h['txval'] as double).toStringAsFixed(2)),
        'iamt': double.parse((h['iamt'] as double).toStringAsFixed(2)),
        'camt': double.parse((h['camt'] as double).toStringAsFixed(2)),
        'samt': double.parse((h['samt'] as double).toStringAsFixed(2)),
        'csamt': double.parse((h['csamt'] as double).toStringAsFixed(2)),
      };
    }).toList();

    final b2csData = b2csGrouped.values.map((final b) {
      final map = <String, dynamic>{
        'sply_ty': b['sply_ty'],
        'pos': b['pos'],
        'typ': b['typ'],
        'rt': b['rt'],
        'txval': double.parse((b['txval'] as double).toStringAsFixed(2)),
        'csamt': double.parse((b['csamt'] as double).toStringAsFixed(2)),
      };
      if (b['sply_ty'] == 'INTER') {
        map['iamt'] = double.parse((b['iamt'] as double).toStringAsFixed(2));
      } else {
        map['camt'] = double.parse((b['camt'] as double).toStringAsFixed(2));
        map['samt'] = double.parse((b['samt'] as double).toStringAsFixed(2));
      }
      return map;
    }).toList();

    // Table 13: Documents Issued (includes both active and cancelled non-deleted documents)
    final docGroups = <int, List<Invoice>>{};
    for (final inv in nonDeletedInvoices) {
      final docNum = switch (inv.type) {
        InvoiceType.debitNote => 4,
        InvoiceType.creditNote => 5,
        InvoiceType.deliveryChallan => 2,
        InvoiceType.invoice || InvoiceType.billOfSupply => 1,
      };
      docGroups.putIfAbsent(docNum, () => []).add(inv);
    }

    final docDetList = docGroups.entries.map((final entry) {
      final list = List<Invoice>.from(entry.value)
        ..sort((final a, final b) => a.invoiceNo.compareTo(b.invoiceNo));
      final totalNum = list.length;
      final cancelCount = list.where((final i) => i.isCancelled).length;
      return {
        'doc_num': entry.key,
        'docs': [
          {
            'num': 1,
            'from': list.first.invoiceNo,
            'to': list.last.invoiceNo,
            'totnum': totalNum,
            'cancel': cancelCount,
            'net_issue': totalNum - cancelCount,
          },
        ],
      };
    }).toList();

    final effectiveGstin = gstin.trim().isNotEmpty
        ? gstin.trim()
        : (validInvoices.isNotEmpty
              ? validInvoices.first.supplier.gstin.trim()
              : '');
    final effectiveFp = fp.trim().isNotEmpty
        ? fp.trim()
        : (validInvoices.isNotEmpty
              ? DateFormat('MMyyyy').format(validInvoices.first.invoiceDate)
              : DateFormat('MMyyyy').format(DateTime.now()));

    final payload = <String, dynamic>{
      'gstin': effectiveGstin,
      'fp': effectiveFp,
      'version': 'GST3.1.6',
      'hash': 'hash',
      'b2b': b2bByCtin.entries
          .map((final e) => {'ctin': e.key, 'inv': e.value})
          .toList(),
      'b2cl': b2clByPos.entries
          .map((final e) => {'pos': e.key, 'inv': e.value})
          .toList(),
      'b2cs': b2csData,
      'exp': expByTyp.entries
          .map((final e) => {'exp_typ': e.key, 'inv': e.value})
          .toList(),
      'cdnr': cdnrByCtin.entries
          .map((final e) => {'ctin': e.key, 'nt': e.value})
          .toList(),
      'cdnur': cdnurList,
      'hsn': {'data': hsnData},
      'doc_issue': {'doc_det': docDetList},
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
