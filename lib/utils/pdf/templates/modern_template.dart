import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../models/invoice.dart';
import '../../../models/business_profile.dart';
import '../../invoice_template.dart';
import '../../number_to_words.dart';
import '../pdf_helpers.dart';

class ModernTemplate implements InvoiceTemplate {
  @override
  String get name => 'Modern';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile,
      pw.Font font, pw.Font fontBold) async {
    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    ));
    final themeColor = PdfColor.fromInt(profile.colorValue);
    final lightThemeColor = PdfColor.fromInt(profile.colorValue).flatten();

    final headerText = const pw.TextStyle(color: PdfColors.white, fontSize: 9);
    final titleText = pw.TextStyle(
        color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero, // Full bleed
        build: (context) {
          return pw.Column(children: [
            // Top Header Block
            pw.Container(
                color: themeColor,
                padding: const pw.EdgeInsets.only(
                    top: 40, left: 30, right: 30, bottom: 20),
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Logo / Company info
                      pw.Expanded(
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                            if (profile.logoPath != null &&
                                File(profile.logoPath!).existsSync())
                              pw.Container(
                                  height: 50,
                                  margin: const pw.EdgeInsets.only(bottom: 10),
                                  child: pw.Image(
                                      pw.MemoryImage(File(profile.logoPath!)
                                          .readAsBytesSync()),
                                      fit: pw.BoxFit.contain))
                            else
                              pw.Text(profile.companyName,
                                  style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 18,
                                      fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            if (profile.address.isNotEmpty)
                              pw.Text(profile.address, style: headerText),
                            if (profile.gstin.isNotEmpty)
                              pw.Text("GSTIN: ${profile.gstin}",
                                  style: headerText),
                            if (profile.phone.isNotEmpty)
                              pw.Text("Phone: ${profile.phone}",
                                  style: headerText),
                            if (profile.email.isNotEmpty)
                              pw.Text("Email: ${profile.email}",
                                  style: headerText),
                          ])),
                      // Invoice Title & Details
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("INVOICE", style: titleText),
                            pw.SizedBox(height: 10),
                            _buildWhiteField("Invoice #", invoice.invoiceNo),
                            _buildWhiteField(
                                "Date",
                                DateFormat('dd MMM yyyy')
                                    .format(invoice.invoiceDate)),
                            _buildWhiteField(
                                "Place Of Supply", invoice.placeOfSupply),
                            _buildWhiteField(
                                "Reverse Charge", invoice.reverseCharge),
                          ])
                    ])),

            pw.SizedBox(height: 20),

            // Bill To Section (Contained)
            pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 30),
                child: pw.Row(children: [
                  pw.Expanded(
                      child: pw.Container(
                          padding: const pw.EdgeInsets.all(15),
                          decoration: const pw.BoxDecoration(
                              color: PdfColors.grey100,
                              borderRadius:
                                  pw.BorderRadius.all(pw.Radius.circular(8))),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("Bill To",
                                    style: pw.TextStyle(
                                        color: themeColor,
                                        fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 5),
                                pw.Text(invoice.receiver.name,
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(invoice.receiver.address,
                                    style: const pw.TextStyle(fontSize: 9)),
                                pw.Text("GSTIN: ${invoice.receiver.gstin}",
                                    style: const pw.TextStyle(fontSize: 9)),
                                if (invoice.receiver.state.isNotEmpty)
                                  pw.Text(
                                      "State: ${invoice.receiver.state} (Code: ${invoice.receiver.stateCode})",
                                      style: const pw.TextStyle(fontSize: 9)),
                              ]))),
                  if (invoice.deliveryAddress != null &&
                      invoice.deliveryAddress!.isNotEmpty &&
                      invoice.deliveryAddress != invoice.receiver.address) ...[
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.all(15),
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text("Shipped To",
                                      style: pw.TextStyle(
                                          color: themeColor,
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 5),
                                  pw.Text(invoice.deliveryAddress!,
                                      style: const pw.TextStyle(fontSize: 9)),
                                ])))
                  ],
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                        pw.Text("Grand Total",
                            style: const pw.TextStyle(
                                color: PdfColors.grey600, fontSize: 12)),
                        pw.Text(
                            "${profile.currencySymbol} ${invoice.grandTotal.toStringAsFixed(2)}",
                            style: pw.TextStyle(
                                color: themeColor,
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(
                            "${getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.grandTotal)} Only",
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColors.grey700)),
                      ]))
                ])),

            pw.SizedBox(height: 30),

            // Table
            pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 30),
                child: _buildItemsTable(invoice, themeColor, lightThemeColor)),

            pw.SizedBox(height: 10),

            // Summary & Bank
            pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 30),
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                          flex: 6,
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("Bank Information",
                                    style: pw.TextStyle(
                                        color: themeColor,
                                        fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 5),
                                pw.Text("Bank: ${invoice.bankName}",
                                    style: const pw.TextStyle(fontSize: 9)),
                                pw.Text("Acc No: ${invoice.accountNo}",
                                    style: const pw.TextStyle(fontSize: 9)),
                                pw.Text("IFSC: ${invoice.ifscCode}",
                                    style: const pw.TextStyle(fontSize: 9)),
                                pw.Text("Branch: ${invoice.branch}",
                                    style: const pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 15),
                                pw.Text("Terms",
                                    style: pw.TextStyle(
                                        color: themeColor,
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(profile.termsAndConditions,
                                    style: const pw.TextStyle(
                                        fontSize: 8, color: PdfColors.grey700)),
                                pw.SizedBox(height: 10),
                                buildUpiQr(
                                    profile.upiId, profile.upiName, invoice),
                              ])),
                      pw.Expanded(
                          flex: 4,
                          child: pw.Column(children: [
                            _buildSummaryRow(
                                "Taxable Value",
                                invoice.totalTaxableValue,
                                profile.currencySymbol),
                            if (!invoice.isInterState)
                              _buildSummaryRow("CGST Total", invoice.totalCGST,
                                  profile.currencySymbol),
                            if (!invoice.isInterState)
                              _buildSummaryRow("SGST Total", invoice.totalSGST,
                                  profile.currencySymbol),
                            if (invoice.isInterState)
                              _buildSummaryRow("IGST Total", invoice.totalIGST,
                                  profile.currencySymbol),
                            pw.Divider(color: themeColor),
                            _buildSummaryRow("Grand Total", invoice.grandTotal,
                                profile.currencySymbol,
                                isBold: true, color: themeColor),
                          ]))
                    ])),

            pw.Spacer(),

            // Footer
            pw.Container(
                color: PdfColors.grey100,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Thank you for your business!",
                          style: pw.TextStyle(
                              color: themeColor,
                              fontWeight: pw.FontWeight.bold)),
                      if (profile.signaturePath != null &&
                          File(profile.signaturePath!).existsSync())
                        pw.Stack(alignment: pw.Alignment.center, children: [
                          if (profile.stampPath != null &&
                              File(profile.stampPath!).existsSync())
                            pw.Opacity(
                                opacity: 0.7,
                                child: pw.Image(
                                    pw.MemoryImage(File(profile.stampPath!)
                                        .readAsBytesSync()),
                                    height: 70)),
                          pw.Image(
                              pw.MemoryImage(File(profile.signaturePath!)
                                  .readAsBytesSync()),
                              height: 50),
                        ])
                      else
                        pw.Text("Authorized Signatory")
                    ]))
          ]);
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildWhiteField(String label, String value) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
          pw.Text("$label: ",
              style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 9)),
          pw.Text(value,
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold)),
        ]));
  }

  pw.Widget _buildSummaryRow(String label, double value, String symbol,
      {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: isBold ? pw.FontWeight.bold : null)),
              pw.Text("$symbol ${value.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: isBold ? pw.FontWeight.bold : null)),
            ]));
  }

  pw.Widget _buildItemsTable(
      Invoice invoice, PdfColor themeColor, PdfColor lightColor) {
    final headers = ['Item', 'SAC', 'Price', 'Qty', 'GST', 'Total'];
    final data = invoice.items.asMap().entries.map((e) {
      final item = e.value;
      final gstAmount = invoice.isInterState
          ? item.calculateIgst(true)
          : (item.calculateCgst(false) + item.calculateSgst(false));

      return [
        item.description,
        item.sacCode,
        item.amount.toStringAsFixed(2),
        "${item.quantity} ${item.unit}",
        gstAmount.toStringAsFixed(2),
        item.totalAmount.toStringAsFixed(2),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold),
        headerDecoration: pw.BoxDecoration(
            color: themeColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
        },
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8));
  }
}
