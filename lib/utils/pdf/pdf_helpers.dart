import 'package:pdf/widgets.dart' as pw;
import 'package:invobharat/models/invoice.dart';

String getCurrencyName(final String symbol) {
  switch (symbol) {
    case '₹':
      return 'Rupees';
    case '\$':
      return 'Dollars';
    case '€':
      return 'Euros';
    case '£':
      return 'Pounds';
    case '¥':
      return 'Yen';
    default:
      return 'Currency';
  }
}

pw.Widget buildUpiQr(
    final String? upiId, final String? upiName, final Invoice invoice, final String currencySymbol) {
  if (upiId == null || upiId.isEmpty) return pw.Container();
  // Only show QR for INR
  if (currencySymbol != '₹' &&
      currencySymbol != 'Rs' &&
      currencySymbol != 'INR') {
    return pw.Container();
  }

  final upiUrl =
      "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName ?? '')}&am=${invoice.grandTotal.toStringAsFixed(2)}&tn=${Uri.encodeComponent('Inv ${invoice.invoiceNo}')}&cu=INR";

  return pw.Column(children: [
    pw.BarcodeWidget(
      barcode: pw.Barcode.qrCode(),
      data: upiUrl,
      width: 80,
      height: 80,
    ),
    pw.SizedBox(height: 4),
    pw.Text("Scan to Pay", style: const pw.TextStyle(fontSize: 8)),
  ]);
}
