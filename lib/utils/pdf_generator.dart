import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/invoice.dart';

Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
  final pdf = pw.Document();

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '');
  final dateFormat = DateFormat('dd/MM/yyyy');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return _buildInvoiceContent(invoice, currencyFormat, dateFormat);
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildInvoiceContent(Invoice invoice, NumberFormat cf, DateFormat df) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 1),
    ),
    child: pw.Column(
      children: [
        // Title
        pw.Container(
          width: double.infinity,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text("TAX INVOICE",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        ),
        pw.Divider(height: 1, thickness: 1),

        // Supplier and Receiver Header
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Supplier
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(width: 1))),
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                        child: pw.Text("Supplier",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    _buildLabelValue("Name", invoice.supplier.name),
                    _buildLabelValue("GSTIN", invoice.supplier.gstin),
                    _buildLabelValue("PAN", invoice.supplier.pan),
                    _buildLabelValue("Address", invoice.supplier.address),
                    _buildLabelValue("Place of Supply", invoice.placeOfSupply),
                  ],
                ),
              ),
            ),
            // Receiver
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                        child: pw.Text("Receiver",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    _buildLabelValue("Name", invoice.receiver.name),
                    _buildLabelValue("GSTIN", invoice.receiver.gstin),
                    _buildLabelValue("PAN", invoice.receiver.pan),
                    pw.SizedBox(height: 5),
                    pw.Row(children: [
                      pw.Text("Inv Date: "),
                      pw.Text(df.format(invoice.invoiceDate),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]),
                    pw.Row(children: [
                      pw.Text("Inv No: "),
                      pw.Text(invoice.invoiceNo,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        pw.Divider(height: 1, thickness: 1),

        // Item Table Header
        pw.Container(
          color: PdfColors.grey200,
          child: pw.Row(
            children: [
              _buildCell("S.No", width: 30),
              _buildCell("Description & SAC", flex: 3),
              _buildCell("Year", width: 40),
              _buildCell("Amount"),
              _buildCell("Disc", width: 30),
              _buildCell("Net Amt"),
              _buildCell("CGST\n%", width: 30),
              _buildCell("CGST\nAmt"),
              _buildCell("SGST\n%", width: 30),
              _buildCell("SGST\nAmt"),
              _buildCell("Total"),
            ],
          ),
        ),
        pw.Divider(height: 1, thickness: 1),

        // Item Rows
        ...invoice.items.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final item = entry.value;
          return pw.Row(
            children: [
              _buildCell("$idx", width: 30),
              _buildCell("${item.description}\nSAC: ${item.sacCode}", flex: 3, align: pw.TextAlign.left),
              _buildCell(item.year, width: 40),
              _buildCell(cf.format(item.amount)),
              _buildCell(cf.format(item.discount), width: 30),
              _buildCell(cf.format(item.netAmount)),
              _buildCell("${item.cgstRate}%", width: 30),
              _buildCell(cf.format(item.cgstAmount)),
              _buildCell("${item.sgstRate}%", width: 30),
              _buildCell(cf.format(item.sgstAmount)),
              _buildCell(cf.format(item.totalAmount)),
            ],
          );
        }).toList(),
        
        // Fill remaining space with empty lines if needed? 
        // For simplicity, just one summary row
        pw.Divider(height: 1, thickness: 1),

        // Total Row
        pw.Row(
          children: [
            pw.Expanded(flex: 3, child: pw.Text("Total Amount", textAlign: pw.TextAlign.right)),
            _buildCell(cf.format(invoice.totalTaxableValue), width: 60), // Net Amt sum approx
            _buildCell("", width: 30), // Empty CGST rate
            _buildCell(cf.format(invoice.totalCGST)),
            _buildCell("", width: 30), // Empty SGST rate
            _buildCell(cf.format(invoice.totalSGST)),
            _buildCell(cf.format(invoice.grandTotal)),
          ],
        ),

        pw.Divider(height: 1, thickness: 1),
        
        // Amount in words (Placeholder)
        pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(5),
            child: pw.Row(children: [
             pw.Text("Total Invoice Value (In Words): ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
             pw.Text("Rupees ${invoice.grandTotal.toStringAsFixed(0)} Only (Approx)"),
            ])
        ),

        pw.Divider(height: 1, thickness: 1),

        // Bank Details & Footer
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
             pw.Expanded(
               flex: 2,
               child: pw.Container(
                 padding: const pw.EdgeInsets.all(5),
                 child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text("Payment Terms", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                    _buildLabelValue("In favour of", invoice.supplier.name),
                    _buildLabelValue("Bank", "${invoice.bankName}, ${invoice.branch}"),
                    _buildLabelValue("Account No", invoice.accountNo),
                    _buildLabelValue("IFSC Code", invoice.ifscCode),
                 ])
               )
             ),
             pw.Container(width: 1, height: 100, color: PdfColors.black),
             pw.Expanded(
               child: pw.Container(
                 padding: const pw.EdgeInsets.all(5),
                 alignment: pw.Alignment.bottomRight,
                 height: 100,
                 child: pw.Column(
                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: pw.CrossAxisAlignment.end,
                   children: [
                     pw.Text("for ${invoice.supplier.name}"),
                     pw.SizedBox(height: 40),
                     pw.Text("(PARTNER)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                   ]
                 )
               )
             )
          ]
        ),
        
        pw.Divider(height: 1, thickness: 1),
        
        // Contact Footer
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Column(children: [
             pw.Text("${invoice.supplier.address}"),
             pw.Text("Mobile: ${invoice.supplier.phone}; Email: ${invoice.supplier.email}"),
          ])
        )

      ],
    ),
  );
}

pw.Widget _buildLabelValue(String label, String value) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(width: 60, child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
      pw.Text(": "),
      pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
    ],
  );
}

pw.Widget _buildCell(String text, {double? width, int? flex, pw.TextAlign align = pw.TextAlign.right}) {
  final child = pw.Container(
    padding: const pw.EdgeInsets.all(2),
    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 0.5))),
    alignment: align == pw.TextAlign.right ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
  );
  
  if (width != null) return pw.SizedBox(width: width, child: child);
  return pw.Expanded(flex: flex ?? 1, child: child);
}
