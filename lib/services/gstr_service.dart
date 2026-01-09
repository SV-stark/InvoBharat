import '../models/invoice.dart';
import 'package:intl/intl.dart';

class GstrService {
  String generateGstr1Csv(List<Invoice> invoices) {
    // Header based on user request
    final buffer = StringBuffer();
    buffer.writeln(
        'GSTIN(recipeint),Trade Name(recipeint),Invoice No,Date of Invoice,Invoice Value,GST%,Taxable Value,CESS,Place Of Supply,RCM Applicable,HSN Description');

    for (final inv in invoices) {
      final date = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);
      final receiverName = inv.receiver.name.replaceAll(',', ' ');
      final gstin = inv.receiver.gstin;
      final invoiceValue = inv.grandTotal.toStringAsFixed(2);
      final placeOfSupply =
          inv.receiver.state.isEmpty ? inv.placeOfSupply : inv.receiver.state;
      const rcm = "N"; // Default RCM to No
      const cess = "0.00";

      if (inv.items.isEmpty) {
        // Fallback for empty invoice (though unlikely)
        buffer.writeln(
            '$gstin,$receiverName,${inv.invoiceNo},$date,$invoiceValue,0,0.00,$cess,$placeOfSupply,$rcm,');
      } else {
        for (final item in inv.items) {
          final gstRate = item.gstRate.toStringAsFixed(2);
          final taxableValue = item.netAmount.toStringAsFixed(2);
          final hsnDesc = item.description.replaceAll(',', ' ');

          buffer.writeln(
              '$gstin,$receiverName,${inv.invoiceNo},$date,$invoiceValue,$gstRate,$taxableValue,$cess,$placeOfSupply,$rcm,$hsnDesc');
        }
      }
    }

    return buffer.toString();
  }
}
