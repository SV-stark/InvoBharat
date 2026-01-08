import '../models/invoice.dart';
import 'package:intl/intl.dart';

class GstrService {
  String generateGstr1Csv(List<Invoice> invoices) {
    // Header based on user request
    final buffer = StringBuffer();
    buffer.writeln(
        'GSTIN/UIN,Trade Name,Invoice No,Date of Invoice,Invoice Value,GST%,Taxable Value,CESS,Place Of Supply,RCM Applicable');

    for (final inv in invoices) {
      final date = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);
      final receiverName = inv.receiver.name.replaceAll(',', ' ');
      final gstin = inv.receiver.gstin;
      final invoiceValue = inv.grandTotal.toStringAsFixed(2);
      final placeOfSupply =
          inv.receiver.state.isEmpty ? inv.placeOfSupply : inv.receiver.state;
      const rcm = "N"; // Default RCM to No
      const cess = "0.00";

      // Group items by GST Rate
      final Map<double, double> rateWiseTaxable = {};

      for (final item in inv.items) {
        // item.amount is typically the unit value. We want the Taxable Value (netAmount).
        // netAmount = (amount * quantity) - discount
        rateWiseTaxable.update(item.gstRate, (value) => value + item.netAmount,
            ifAbsent: () => item.netAmount);
      }

      // If no items, output one row with 0 values?
      // Or just skip? Typically an invoice has items.
      if (rateWiseTaxable.isEmpty) {
        // Fallback for empty invoice
        buffer.writeln(
            '$gstin,$receiverName,${inv.invoiceNo},$date,$invoiceValue,0,0.00,$cess,$placeOfSupply,$rcm');
      } else {
        rateWiseTaxable.forEach((rate, taxableVal) {
          buffer.writeln(
              '$gstin,$receiverName,${inv.invoiceNo},$date,$invoiceValue,${rate.toStringAsFixed(2)},${taxableVal.toStringAsFixed(2)},$cess,$placeOfSupply,$rcm');
        });
      }
    }

    return buffer.toString();
  }
}
