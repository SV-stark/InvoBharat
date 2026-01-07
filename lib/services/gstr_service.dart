import '../models/invoice.dart';
import 'package:intl/intl.dart';

class GstrService {
  String generateGstr1Csv(List<Invoice> invoices) {
    // Header
    final buffer = StringBuffer();
    buffer.writeln(
        'Invoice No,Invoice Date,Receiver Name,GSTIN,State,Taxable Value,IGST,CGST,SGST,Total Invoice Value');

    for (final inv in invoices) {
      final date = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);
      final receiver = inv.receiver.name.replaceAll(',', ' '); // Escape commas
      final gstin = inv.receiver.gstin;
      final state =
          inv.receiver.state.isEmpty ? inv.placeOfSupply : inv.receiver.state;

      final taxable = inv.totalTaxableValue.toStringAsFixed(2);
      final igst = inv.totalIGST.toStringAsFixed(2);
      final cgst = inv.totalCGST.toStringAsFixed(2);
      final sgst = inv.totalSGST.toStringAsFixed(2);
      final total = inv.grandTotal.toStringAsFixed(2);

      buffer.writeln(
          '${inv.invoiceNo},$date,$receiver,$gstin,$state,$taxable,$igst,$cgst,$sgst,$total');
    }

    return buffer.toString();
  }
}
