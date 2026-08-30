import 'dart:isolate';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/gst_utils.dart';
import 'package:invobharat/utils/einvoice_exporter.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

class GstrService {
  Future<String> generateGstr1CsvAsync(final List<Invoice> invoices) async {
    return Isolate.run(() => generateGstr1Csv(invoices));
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
              inv.status.toLowerCase() != 'draft' &&
              inv.type != InvoiceType.deliveryChallan,
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
        for (final item in inv.items) {
          final gstRate = item.gstRate;
          final taxableValue = item.netAmount * multiplier;
          final cgst = item.calculateCgst(inv.isInterState) * multiplier;
          final sgst = item.calculateSgst(inv.isInterState) * multiplier;
          final igst = item.calculateIgst(inv.isInterState) * multiplier;
          final hsnDesc = item.description;
          final hsnDetails = item.sacCode;

          rows.add([
            _sanitize(gstin),
            _sanitize(receiverName),
            _sanitize(inv.invoiceNo),
            date,
            invoiceValue.toStringAsFixed(2),
            gstRate.toStringAsFixed(2),
            taxableValue.toStringAsFixed(2),
            cgst.toStringAsFixed(2),
            sgst.toStringAsFixed(2),
            igst.toStringAsFixed(2),
            cess,
            _sanitize(placeOfSupply),
            _sanitize(rcm),
            _sanitize(hsnDetails),
            _sanitize(hsnDesc),
            type,
          ]);
        }
      }
    }

    return Csv().encode(rows);
  }
}
