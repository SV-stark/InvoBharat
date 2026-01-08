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

// ... imports

class MinimalTemplate implements InvoiceTemplate {
  @override
  String get name => 'Minimal';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile,
      pw.Font font, pw.Font fontBold) async {
    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    ));

    final titleStyle =
        pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold);
    final headerLabel =
        const pw.TextStyle(fontSize: 9, color: PdfColors.grey700);
    final headerValue =
        pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);

    // Determines Supply Type
    String supplyType = "Tax Invoice";
    if (invoice.receiver.gstin.isEmpty) {
      supplyType = "Retail Invoice";
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // Header
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (profile.logoPath != null &&
                          File(profile.logoPath!).existsSync())
                        pw.Container(
                            height: 50,
                            margin: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Image(pw.MemoryImage(
                                File(profile.logoPath!).readAsBytesSync())))
                      else
                        pw.Text(profile.companyName, style: titleStyle),
                      pw.SizedBox(height: 5),
                      if (profile.address.isNotEmpty)
                        pw.Text(profile.address, style: headerLabel),
                      if (profile.gstin.isNotEmpty)
                        pw.Text("GSTIN: ${profile.gstin}", style: headerLabel),
                      if (profile.phone.isNotEmpty)
                        pw.Text("Phone: ${profile.phone}", style: headerLabel),
                      if (profile.email.isNotEmpty)
                        pw.Text("Email: ${profile.email}", style: headerLabel),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(supplyType.toUpperCase(),
                          style: titleStyle.copyWith(fontSize: 16)),
                      pw.SizedBox(height: 10),
                      _buildField("Invoice #", invoice.invoiceNo, headerLabel,
                          headerValue),
                      _buildField(
                          "Date",
                          DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                          headerLabel,
                          headerValue),
                      _buildField("Place of Supply", invoice.placeOfSupply,
                          headerLabel, headerValue),
                      _buildField("Reverse Charge", invoice.reverseCharge,
                          headerLabel, headerValue),
                    ])
              ]),

          pw.SizedBox(height: 30),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.SizedBox(height: 10),

          // Bill To
          pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Row(children: [
                pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                      pw.Text("Bill To:",
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.receiver.name,
                          style: const pw.TextStyle(fontSize: 11)),
                      if (invoice.receiver.address.isNotEmpty)
                        pw.Text(invoice.receiver.address, style: headerLabel),
                      pw.Text(
                          "GSTIN: ${invoice.receiver.gstin.isEmpty ? 'Unregistered' : invoice.receiver.gstin}",
                          style: headerLabel),
                      if (invoice.receiver.state.isNotEmpty)
                        pw.Text("State: ${invoice.receiver.state}",
                            style: headerLabel),
                    ])),
                if (invoice.deliveryAddress != null &&
                    invoice.deliveryAddress!.isNotEmpty &&
                    invoice.deliveryAddress != invoice.receiver.address) ...[
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                        pw.Text("Shipped To:",
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.deliveryAddress!, style: headerLabel),
                      ]))
                ],
              ])),

          pw.SizedBox(height: 30),

          // Table
          _buildItemsTable(invoice),

          pw.SizedBox(height: 20),

          // Amounts
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Amount in words:",
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "${getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.grandTotal)} Only",
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey800)),
                          pw.SizedBox(height: 5),
                          pw.Text("Tax Amount in words:",
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "${getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.totalCGST + invoice.totalSGST + invoice.totalIGST)} Only",
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey800)),
                          pw.SizedBox(height: 15),
                          pw.Text("Bank Details:",
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                            "${invoice.bankName}\nA/c: ${invoice.accountNo}\nIFSC: ${invoice.ifscCode}\nBranch: ${invoice.branch}",
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700),
                          ),
                        ])),
                pw.SizedBox(width: 10),
                buildUpiQr(profile.upiId, profile.upiName, invoice),
                pw.Expanded(
                    flex: 5,
                    child: pw.Column(children: [
                      _buildSummaryRow("Total Taxable Value",
                          invoice.totalTaxableValue, profile.currencySymbol),
                      if (invoice.totalCGST > 0)
                        _buildSummaryRow("Total CGST", invoice.totalCGST,
                            profile.currencySymbol),
                      if (invoice.totalSGST > 0)
                        _buildSummaryRow("Total SGST", invoice.totalSGST,
                            profile.currencySymbol),
                      if (invoice.totalIGST > 0)
                        _buildSummaryRow("Total IGST", invoice.totalIGST,
                            profile.currencySymbol),
                      pw.Divider(),
                      _buildSummaryRow("Grand Total", invoice.grandTotal,
                          profile.currencySymbol,
                          isBold: true),
                    ]))
              ]),

          pw.Spacer(),
          pw.Divider(thickness: 0.5),

          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Terms & Conditions",
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text(profile.termsAndConditions,
                          style: const pw.TextStyle(
                              fontSize: 8, color: PdfColors.grey600)),
                    ]),
                if (profile.signaturePath != null &&
                    File(profile.signaturePath!).existsSync())
                  pw.Column(children: [
                    pw.Container(
                        height: 60,
                        width: 100,
                        child:
                            pw.Stack(alignment: pw.Alignment.center, children: [
                          if (profile.stampPath != null &&
                              File(profile.stampPath!).existsSync())
                            pw.Opacity(
                                opacity: 0.6,
                                child: pw.Image(
                                    pw.MemoryImage(File(profile.stampPath!)
                                        .readAsBytesSync()),
                                    width: 60)),
                          pw.Image(
                              pw.MemoryImage(File(profile.signaturePath!)
                                  .readAsBytesSync()),
                              height: 40,
                              fit: pw.BoxFit.contain),
                        ])),
                    pw.Text("Authorized Signatory",
                        style: const pw.TextStyle(fontSize: 8)),
                  ])
              ])
        ]);
      },
    ));

    return pdf.save();
  }

  pw.Widget _buildField(String label, String value, pw.TextStyle labelStyle,
      pw.TextStyle valueStyle) {
    return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
      pw.Text("$label: ", style: labelStyle),
      pw.Text(value, style: valueStyle),
    ]);
  }

  pw.Widget _buildSummaryRow(String label, double value, String symbol,
      {bool isBold = false}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: isBold ? pw.FontWeight.bold : null)),
              pw.Text("$symbol ${value.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: isBold ? pw.FontWeight.bold : null)),
            ]));
  }

  pw.Widget _buildItemsTable(Invoice invoice) {
    final isInterState = invoice.isInterState;

    List<String> headers = [
      '#',
      'Item',
      'HSN/SAC',
      'Qty',
      'Rate',
      'Taxable Val'
    ];
    if (isInterState) {
      headers.addAll(['IGST %', 'IGST Amt']);
    } else {
      headers.addAll(['CGST %', 'CGST Amt', 'SGST %', 'SGST Amt']);
    }
    headers.add('Total');

    final data = invoice.items.asMap().entries.map((e) {
      final item = e.value;
      final taxableValue = item.netAmount;

      final row = [
        (e.key + 1).toString(),
        item.description,
        item.sacCode,
        "${item.quantity} ${item.unit}",
        item.amount.toStringAsFixed(2),
        taxableValue.toStringAsFixed(2),
      ];

      if (isInterState) {
        row.add("${item.gstRate}%");
        row.add(item.calculateIgst(true).toStringAsFixed(2));
      } else {
        final halfRate = item.gstRate / 2;
        row.add("$halfRate%");
        row.add(item.calculateCgst(false).toStringAsFixed(2));
        row.add("$halfRate%");
        row.add(item.calculateSgst(false).toStringAsFixed(2));
      }

      row.add(item.totalAmount.toStringAsFixed(2));
      return row;
    }).toList();

    return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: const pw.TableBorder(
          top: pw.BorderSide(color: PdfColors.grey300),
          bottom: pw.BorderSide(color: PdfColors.grey300),
          horizontalInside: pw.BorderSide(color: PdfColors.grey200),
        ),
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 8),
        columnWidths: {
          1: const pw.FlexColumnWidth(3), // Desc
        },
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerLeft,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
          6: pw.Alignment.centerRight,
          7: pw.Alignment.centerRight,
          headers.length - 1: pw.Alignment.centerRight,
        },
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4));
  }
}
