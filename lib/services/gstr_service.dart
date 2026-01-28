import '../models/invoice.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

class GstrService {
  String generateGstr1Csv(List<Invoice> invoices) {
    // Header based on user request
    List<List<dynamic>> rows = [];

    // Add Header
    rows.add([
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
      'HSN Description'
    ]);

    for (final inv in invoices) {
      final date = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);
      final receiverName = inv.receiver.name;
      final gstin = inv.receiver.gstin;
      final invoiceValue = inv.grandTotal;
      final placeOfSupply =
          inv.receiver.state.isEmpty ? inv.placeOfSupply : inv.receiver.state;
      const rcm = "N"; // Default RCM to No
      const cess = "0.00";

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
          cess,
          placeOfSupply,
          rcm,
          ''
        ]);
      } else {
        for (final item in inv.items) {
          final gstRate = item.gstRate;
          final taxableValue = item.netAmount;
          final hsnDesc = item.description;

          rows.add([
            gstin,
            receiverName,
            inv.invoiceNo,
            date,
            invoiceValue.toStringAsFixed(2),
            gstRate.toStringAsFixed(2),
            taxableValue.toStringAsFixed(2),
            cess,
            placeOfSupply,
            rcm,
            hsnDesc
          ]);
        }
      }
    }

    return const ListToCsvConverter().convert(rows);
  }
}
