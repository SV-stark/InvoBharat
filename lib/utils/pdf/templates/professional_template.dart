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

class ProfessionalTemplate implements InvoiceTemplate {
  @override
  String get name => 'Professional';

  @override
  Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile, pw.Font font, pw.Font fontBold,
      {String? title}) async {
    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    ));

    // Define styles
    final titleStyle = pw.TextStyle(
        fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);
    final headerLabelStyle =
        const pw.TextStyle(fontSize: 10, color: PdfColors.grey700);
    final headerValueStyle =
        pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final tableHeaderStyle = pw.TextStyle(
        fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
    final itemsStyle = const pw.TextStyle(fontSize: 8);

    // Determines Supply Type
    String supplyType = title ?? "Tax Invoice";
    if (title == null && invoice.receiver.gstin.isEmpty) {
      supplyType = "Retail Invoice";
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) {
        return pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // --- HEADER SECTION ---
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (profile.logoPath != null &&
                          File(profile.logoPath!).existsSync())
                        pw.Container(
                            height: 60,
                            margin: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Image(pw.MemoryImage(
                                File(profile.logoPath!).readAsBytesSync())))
                      else
                        pw.Text(profile.companyName, style: titleStyle),
                      pw.SizedBox(height: 5),
                      if (profile.address.isNotEmpty)
                        pw.Text(profile.address, style: headerLabelStyle),
                      if (profile.gstin.isNotEmpty)
                        pw.Text("GSTIN: ${profile.gstin}",
                            style: headerLabelStyle),
                      if (profile.phone.isNotEmpty)
                        pw.Text("Phone: ${profile.phone}",
                            style: headerLabelStyle),
                      if (profile.email.isNotEmpty)
                        pw.Text("Email: ${profile.email}",
                            style: headerLabelStyle),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(supplyType.toUpperCase(),
                          style: titleStyle.copyWith(fontSize: 18)),
                      pw.SizedBox(height: 10),
                      _buildHeaderField("Invoice #", invoice.invoiceNo,
                          headerLabelStyle, headerValueStyle),
                      _buildHeaderField(
                          "Date",
                          DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                          headerLabelStyle,
                          headerValueStyle),
                      _buildHeaderField(
                          "Place of Supply",
                          invoice.placeOfSupply,
                          headerLabelStyle,
                          headerValueStyle),
                      _buildHeaderField("Reverse Charge", invoice.reverseCharge,
                          headerLabelStyle, headerValueStyle),
                    ])
              ]),
          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 20),

          // --- BILL TO ---
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(children: [
              pw.Expanded(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                    pw.Text("Bill To:",
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700)),
                    pw.SizedBox(height: 5),
                    pw.Text(invoice.receiver.name, style: headerValueStyle),
                    if (invoice.receiver.address.isNotEmpty)
                      pw.Text(invoice.receiver.address,
                          style: headerLabelStyle),
                    pw.Text(
                        "GSTIN: ${invoice.receiver.gstin.isEmpty ? 'Unregistered' : invoice.receiver.gstin}",
                        style: headerLabelStyle),
                    if (invoice.receiver.state.isNotEmpty)
                      pw.Text("State: ${invoice.receiver.state}",
                          style: headerLabelStyle),
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
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700)),
                      pw.SizedBox(height: 5),
                      pw.Text(invoice.deliveryAddress!,
                          style: headerLabelStyle),
                    ]))
              ]
            ]),
          ),
          pw.SizedBox(height: 20),

          // --- ITEMS TABLE ---
          _buildItemsTable(invoice, tableHeaderStyle, itemsStyle),

          pw.SizedBox(height: 20),

          // --- TOTALS ---
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                    flex: 5,
                    child: pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 20),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Amount in words:",
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                  "${getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.grandTotal)} Only",
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontStyle: pw.FontStyle.italic)),
                              pw.SizedBox(height: 10),
                              pw.Text("Tax Amount in words:",
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                  "${getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.totalCGST + invoice.totalSGST + invoice.totalIGST)} Only",
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontStyle: pw.FontStyle.italic)),
                            ]))),
                pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4))),
                        child: pw.Column(children: [
                          _buildTotalRow(
                              "Total Taxable Value",
                              invoice.totalTaxableValue,
                              profile.currencySymbol),
                          if (invoice.totalCGST > 0)
                            _buildTotalRow("Total CGST", invoice.totalCGST,
                                profile.currencySymbol),
                          if (invoice.totalSGST > 0)
                            _buildTotalRow("Total SGST", invoice.totalSGST,
                                profile.currencySymbol),
                          if (invoice.totalIGST > 0)
                            _buildTotalRow("Total IGST", invoice.totalIGST,
                                profile.currencySymbol),
                          pw.Divider(),
                          _buildTotalRow("Grand Total", invoice.grandTotal,
                              profile.currencySymbol,
                              isBold: true),
                        ])))
              ]),

          pw.Spacer(),

          // --- FOOTER ---
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Expanded(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                  pw.Text("Bank Details",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                      "Bank: ${invoice.bankName}\nA/c: ${invoice.accountNo}\nIFSC: ${invoice.ifscCode}\nBranch: ${invoice.branch}",
                      style: const pw.TextStyle(fontSize: 9, height: 1.2)),
                  pw.SizedBox(height: 10),
                  pw.Text("Terms & Conditions",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text(profile.termsAndConditions,
                      style: const pw.TextStyle(fontSize: 8)),
                ])),
            pw.SizedBox(width: 20),
            buildUpiQr(profile.upiId, profile.upiName, invoice),
            pw.Column(children: [
              if (profile.signaturePath != null &&
                  File(profile.signaturePath!).existsSync())
                pw.Container(
                    height: 60, // increased height for stack
                    width: 100,
                    child: pw.Stack(alignment: pw.Alignment.center, children: [
                      if (profile.stampPath != null &&
                          File(profile.stampPath!).existsSync())
                        pw.Opacity(
                            opacity: 0.6,
                            child: pw.Image(
                                pw.MemoryImage(
                                    File(profile.stampPath!).readAsBytesSync()),
                                width: 80)),
                      pw.Image(
                          pw.MemoryImage(
                              File(profile.signaturePath!).readAsBytesSync()),
                          fit: pw.BoxFit.contain),
                    ])),
              pw.SizedBox(height: 5),
              pw.Text("Authorized Signatory",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ])
          ])
        ]);
      },
    ));
    return pdf.save();
  }

  pw.Widget _buildHeaderField(String label, String value,
      pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
        pw.Text("$label: ", style: labelStyle),
        pw.Text(value, style: valueStyle),
      ]),
    );
  }

  pw.Widget _buildTotalRow(String label, double amount, String symbol,
      {bool isBold = false}) {
    final style = pw.TextStyle(
        fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : null);
    return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: style),
              pw.Text("$symbol ${amount.toStringAsFixed(2)}", style: style),
            ]));
  }

  pw.Widget _buildItemsTable(
      Invoice invoice, pw.TextStyle headerStyle, pw.TextStyle itemStyle) {
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

    final data = invoice.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final taxableValue = item.netAmount;

      final row = [
        (index + 1).toString(),
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
      border: null,
      headerStyle: headerStyle,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellStyle: itemStyle,
      columnWidths: {
        1: const pw.FlexColumnWidth(3),
      },
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft, // HSN
        3: pw.Alignment.centerRight, // Qty
        4: pw.Alignment.centerRight, // Rate
        5: pw.Alignment.centerRight, // Taxable
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        headers.length - 1: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    );
  }
}
