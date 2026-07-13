import 'dart:isolate';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/gst_utils.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

class GstrService {
  Future<String> generateGstr1CsvAsync(final List<Invoice> invoices) async {
    return Isolate.run(() => generateGstr1Csv(invoices));
  }

  String generateGstr1Csv(final List<Invoice> invoices) {
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

    for (final inv in invoices) {
      final date = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);
      final receiverName = inv.receiver.name;
      final gstin = inv.receiver.gstin;
      final invoiceValue = inv.grandTotal;

      final state = inv.receiver.state.isEmpty
          ? inv.placeOfSupply
          : inv.receiver.state;

      final stateCode = inv.receiver.stateCode.trim().isNotEmpty
          ? inv.receiver.stateCode.trim()
          : (gstin.length >= 2 ? GstUtils.getStateCode(gstin) : null);

      final placeOfSupply = (stateCode != null && stateCode.isNotEmpty)
          ? "$stateCode-$state"
          : state;

      final rcm = inv.reverseCharge;
      const cess = "0.00";
      final type = gstin.trim().isNotEmpty ? 'B2B' : 'B2C';

      if (inv.items.isEmpty) {
        // Fallback for empty invoice (though unlikely)
        rows.add([
          gstin,
          receiverName,
          inv.invoiceNo,
          date,
          invoiceValue.toStringAsFixed(2),
          0,
          0.00,
          0.00,
          0.00,
          0.00,
          cess,
          placeOfSupply,
          rcm,
          '',
          '',
          type,
        ]);
      } else {
        for (final item in inv.items) {
          final gstRate = item.gstRate;
          final taxableValue = item.netAmount;
          final cgst = item.calculateCgst(inv.isInterState);
          final sgst = item.calculateSgst(inv.isInterState);
          final igst = item.calculateIgst(inv.isInterState);
          final hsnDesc = item.description;
          final hsnDetails = item.sacCode;

          rows.add([
            gstin,
            receiverName,
            inv.invoiceNo,
            date,
            invoiceValue.toStringAsFixed(2),
            gstRate.toStringAsFixed(2),
            taxableValue.toStringAsFixed(2),
            cgst.toStringAsFixed(2),
            sgst.toStringAsFixed(2),
            igst.toStringAsFixed(2),
            cess,
            placeOfSupply,
            rcm,
            hsnDetails,
            hsnDesc,
            type,
          ]);
        }
      }
    }

    return Csv().encode(rows);
  }
}
