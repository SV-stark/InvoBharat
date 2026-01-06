import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import 'invoice_template.dart';
import 'number_to_words.dart';

// --- FACTORY ---
Future<Uint8List> generateInvoicePdf(
    Invoice invoice, BusinessProfile profile) async {
  InvoiceTemplate template;
  switch (invoice.style) {
    case 'Professional':
      template = ProfessionalTemplate();
      break;
    case 'Minimal':
      template = MinimalTemplate();
      break;
    case 'Modern':
    default:
      template = ModernTemplate();
      break;
  }

  return template.generate(invoice, profile);
}

// --- TEMPLATES ---

class MinimalTemplate implements InvoiceTemplate {
  @override
  String get name => 'Minimal';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Center(
              child: pw.Text("INVOICE",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("From:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(profile.companyName),
                      pw.Text(profile.address),
                      pw.Text("GSTIN: ${profile.gstin}"),
                      pw.Text("Phone: ${profile.phone}"),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("To:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.receiver.name),
                      if (invoice.receiver.address.isNotEmpty)
                        pw.Text(invoice.receiver.address),
                      pw.Text("GSTIN: ${invoice.receiver.gstin}"),
                    ])
              ]),
          pw.SizedBox(height: 20),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Invoice No: ${invoice.invoiceNo}"),
                pw.Text(
                    "Date: ${DateFormat('dd-MMM-yyyy').format(invoice.invoiceDate)}"),
              ]),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Description', 'Qty', 'Price', 'GST %', 'Total'],
            data: invoice.items.map((item) {
              return [
                item.description,
                "1",
                item.amount.toStringAsFixed(2),
                "${item.gstRate}%",
                item.totalAmount.toStringAsFixed(2)
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                  "Total: Rs. ${invoice.grandTotal.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold))),
          pw.Spacer(),
          pw.Divider(),
          pw.Center(
              child: pw.Text("Thank you",
                  style: const pw.TextStyle(fontSize: 10))),
        ]);
      },
    ));

    return pdf.save();
  }
}

class ProfessionalTemplate implements InvoiceTemplate {
  @override
  String get name => 'Professional';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile) async {
    final pdf = pw.Document();

    // Define styles
    // ignore: prefer_const_constructors
    final textStyle = pw.TextStyle(fontSize: 9);
    final boldStyle = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        decoration: pw.TextDecoration.underline);

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text("TAX INVOICE", style: headerStyle),
                  ),

                  pw.Divider(height: 1),

                  // Supplier & Receiver Row
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Supplier
                        pw.Expanded(
                            child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(right: pw.BorderSide())),
                                child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Center(
                                          child: pw.Text("Supplier",
                                              style: boldStyle)),
                                      pw.Divider(height: 5),
                                      _buildLabelValue("Name",
                                          profile.companyName, boldStyle),
                                      _buildLabelValue(
                                          "GSTIN", profile.gstin, textStyle),
                                      // Assume PAN is derived or empty if not in profile (it is usually part of GSTIN: chars 3-12)
                                      _buildLabelValue(
                                          "PAN",
                                          profile.gstin.length > 12
                                              ? profile.gstin.substring(2, 12)
                                              : "",
                                          textStyle),
                                      _buildLabelValue("Address",
                                          profile.address, textStyle),
                                    ]))),
                        // Receiver
                        pw.Expanded(
                            child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Center(
                                          child: pw.Text("Receiver",
                                              style: boldStyle)),
                                      pw.Divider(height: 5),
                                      _buildLabelValue("Name",
                                          invoice.receiver.name, boldStyle),
                                      _buildLabelValue("GSTIN",
                                          invoice.receiver.gstin, textStyle),
                                      _buildLabelValue("PAN",
                                          invoice.receiver.pan, textStyle),
                                      _buildLabelValue("Address",
                                          invoice.receiver.address, textStyle),
                                    ]))),
                      ]),

                  pw.Divider(height: 1),

                  // Invoice Details
                  pw.Container(
                      child: pw.Row(children: [
                    pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide())),
                            child: _buildLabelValue("Place of Supply",
                                invoice.placeOfSupply, textStyle))),
                    pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide())),
                            child: _buildLabelValue(
                                "Invoice Date",
                                DateFormat('dd/MM/yyyy')
                                    .format(invoice.invoiceDate),
                                textStyle))),
                    pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            child: _buildLabelValue(
                                "Invoice No.", invoice.invoiceNo, boldStyle))),
                  ])),

                  pw.Divider(height: 1),

                  // Items Table
                  _buildItemsTable(invoice),

                  // Total in Words
                  pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide())),
                      child: pw.Row(children: [
                        pw.Text("Total Invoice Value (In Words): ",
                            style: boldStyle),
                        pw.Text(
                            "Rupees ${numberToWords(invoice.grandTotal)} Only",
                            style: textStyle),
                      ])),

                  // Footer Section (Payment + Signatory)
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Bottom Left
                        pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(right: pw.BorderSide())),
                                child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text("Payment Terms",
                                          style: boldStyle),
                                      pw.SizedBox(height: 2),
                                      _buildLabelValue(
                                          "Bank", invoice.bankName, textStyle),
                                      _buildLabelValue("A/c No.",
                                          invoice.accountNo, textStyle),
                                      _buildLabelValue(
                                          "IFSC", invoice.ifscCode, textStyle),
                                      _buildLabelValue(
                                          "Branch", invoice.branch, textStyle),
                                      pw.SizedBox(height: 5),
                                      pw.Text("Terms & Conditions:",
                                          style: boldStyle),
                                      pw.Text(profile.termsAndConditions,
                                          style: textStyle),
                                    ]))),
                        // Bottom Right (Signatory)
                        pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                height: 100, // Fixed height for sig area
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
                                    children: [
                                      pw.Text("for ${profile.companyName}",
                                          style: boldStyle),
                                      if (profile.signaturePath != null &&
                                          File(profile.signaturePath!)
                                              .existsSync())
                                        pw.Image(
                                            pw.MemoryImage(
                                                File(profile.signaturePath!)
                                                    .readAsBytesSync()),
                                            height: 50,
                                            fit: pw.BoxFit.contain),
                                      pw.Text("Authorized Signatory",
                                          style: boldStyle),
                                    ]))),
                      ])
                ]));
      },
    ));
    return pdf.save();
  }

  pw.Widget _buildLabelValue(String label, String value, pw.TextStyle style) {
    return pw.Row(children: [
      pw.SizedBox(width: 80, child: pw.Text(label, style: style)),
      pw.Text(": ", style: style),
      pw.Expanded(child: pw.Text(value, style: style))
    ]);
  }

  pw.Widget _buildItemsTable(Invoice invoice) {
    final headers = [
      "S.No",
      "Description & SAC",
      "Year",
      "Amount",
      "Discount",
      "Net Amt",
      "CGST %",
      "CGST",
      "SGST %",
      "SGST",
      "Total"
    ];

    final List<pw.TableRow> rows = [];

    // Header
    rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: headers
            .map((t) => pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Center(
                    child: pw.Text(t,
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold)))))
            .toList()));

    // Items
    for (var i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      rows.add(pw.TableRow(
          children: [
        (i + 1).toString(),
        "${item.description}\nSAC: ${item.sacCode}",
        item.year,
        item.amount.toStringAsFixed(0),
        item.discount.toStringAsFixed(0),
        item.netAmount.toStringAsFixed(0),
        "${item.cgstRate}%",
        item.cgstAmount.toStringAsFixed(0),
        "${item.sgstRate}%",
        item.sgstAmount.toStringAsFixed(0),
        item.totalAmount.toStringAsFixed(0),
      ]
              .map((t) => pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(t,
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.right)))
              .toList()));
    }

    // Total
    rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: [
          "",
          "Total",
          "",
          invoice.totalTaxableValue.toStringAsFixed(0),
          "",
          (invoice.totalTaxableValue).toStringAsFixed(0),
          "",
          invoice.totalCGST.toStringAsFixed(0),
          "",
          invoice.totalSGST.toStringAsFixed(0),
          invoice.grandTotal.toStringAsFixed(0),
        ]
            .map((t) => pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(t,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.right)))
            .toList()));

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.2),
        6: const pw.FlexColumnWidth(0.8),
        7: const pw.FlexColumnWidth(1),
        8: const pw.FlexColumnWidth(0.8),
        9: const pw.FlexColumnWidth(1),
        10: const pw.FlexColumnWidth(1.5),
      },
      children: rows,
    );
  }
}

class ModernTemplate implements InvoiceTemplate {
  @override
  String get name => 'Modern';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile) async {
    final pdf = pw.Document();
    final themeColor = PdfColor.fromInt(profile.colorValue);

    pw.MemoryImage? logoImage;
    if (profile.logoPath != null) {
      final file = File(profile.logoPath!);
      if (await file.exists()) {
        logoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    final headerStyle = pw.TextStyle(
        color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8);
    final rowStyle = const pw.TextStyle(fontSize: 8);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0), // Full bleed for header
        build: (context) {
          return pw.Column(children: [
            // Header
            pw.Container(
                color: themeColor,
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("INVOICE",
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold)),
                        if (logoImage != null)
                          pw.Container(
                              height: 50, width: 50, child: pw.Image(logoImage))
                        else
                          pw.Text(profile.companyName,
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                      ]),
                  pw.SizedBox(height: 10),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(profile.companyName,
                                  style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(profile.address,
                                  style: const pw.TextStyle(
                                      color: PdfColors.white)),
                              pw.Text("GSTIN: ${profile.gstin}",
                                  style: const pw.TextStyle(
                                      color: PdfColors.white)),
                              pw.Text("Phone: ${profile.phone}",
                                  style: const pw.TextStyle(
                                      color: PdfColors.white)),
                            ]),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text("Before Tax Amount",
                                  style: const pw.TextStyle(
                                      color: PdfColors.white)),
                              pw.Text(
                                  "Rs. ${invoice.totalTaxableValue.toStringAsFixed(2)}",
                                  style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold)),
                            ])
                      ])
                ])),

            pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(children: [
                  // Info Row
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Billed To:",
                                  style: pw.TextStyle(
                                      color: themeColor,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(invoice.receiver.name),
                              pw.Text(invoice.receiver.address),
                              pw.Text("GSTIN: ${invoice.receiver.gstin}"),
                            ]),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text("Invoice Details:",
                                  style: pw.TextStyle(
                                      color: themeColor,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text("Invoice #: ${invoice.invoiceNo}"),
                              pw.Text(
                                  "Date: ${DateFormat('dd-MMM-yyyy').format(invoice.invoiceDate)}"),
                              pw.Text(
                                  "Place of Supply: ${invoice.placeOfSupply}"),
                            ])
                      ]),
                  pw.SizedBox(height: 20),

                  // GST Table
                  _buildItemsTable(invoice, themeColor, headerStyle, rowStyle),

                  pw.SizedBox(height: 10),

                  // Total in Words
                  pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(5),
                      color: PdfColors.grey100,
                      child: pw.Text(
                          "Amount (in words): ${numberToWords(invoice.grandTotal)} Only",
                          style: const pw.TextStyle(fontSize: 10))),

                  pw.SizedBox(height: 20),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Bank Details
                        pw.Expanded(
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                              pw.Text("Bank Details",
                                  style: pw.TextStyle(
                                      color: themeColor,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text("Bank: ${invoice.bankName}"),
                              pw.Text("A/c: ${invoice.accountNo}"),
                              pw.Text("IFSC: ${invoice.ifscCode}"),
                              pw.Text("Branch: ${invoice.branch}"),
                              pw.SizedBox(height: 10),
                              pw.Text("Terms",
                                  style: pw.TextStyle(
                                      color: themeColor,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(profile.termsAndConditions,
                                  style: const pw.TextStyle(fontSize: 8)),
                            ])),
                        // Signature
                        pw.Expanded(
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                              if (profile.signaturePath != null &&
                                  File(profile.signaturePath!).existsSync())
                                pw.Image(
                                    pw.MemoryImage(File(profile.signaturePath!)
                                        .readAsBytesSync()),
                                    height: 60,
                                    fit: pw.BoxFit.contain),
                              pw.Text(
                                  "Authorized Signatory\nfor ${profile.companyName}",
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ]))
                      ]),

                  pw.SizedBox(height: 10),
                  pw.Divider(color: themeColor),
                  pw.Center(
                      child: pw.Text("Thank you for your business!",
                          style: pw.TextStyle(color: themeColor)))
                ])),
          ]);
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildItemsTable(Invoice invoice, PdfColor themeColor,
      pw.TextStyle headerStyle, pw.TextStyle rowStyle) {
    // Simplification for Modern View: Combine taxes differently or show fewer columns if needed

    // Simplification for Modern View: Combine taxes differently or show fewer columns if needed
    // But user asked for GST details. Let's make a readable table.

    return pw.TableHelper.fromTextArray(
      headerStyle: headerStyle,
      headerDecoration: pw.BoxDecoration(color: themeColor),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellStyle: rowStyle,
      headers: [
        "Description",
        "SAC",
        "Value",
        "Dis.",
        "Tax (${invoice.items.firstOrNull?.gstRate ?? 0}%)", // Assuming uniform tax for simple column, otherwise split
        "Total"
      ],
      // Let's use detailed row builder manually for full control if standard array isn't enough
      // But standard is easy. Let's do a rigorous detailed table like Professional but styled.
      data: invoice.items.map((item) {
        final taxAmt = item.cgstAmount +
            item.sgstAmount +
            (item.amount * 0); // IGST logic if needed
        return [
          item.description,
          item.sacCode,
          item.amount.toStringAsFixed(2),
          item.discount.toStringAsFixed(2),
          taxAmt.toStringAsFixed(2),
          item.totalAmount.toStringAsFixed(2)
        ];
      }).toList(),
    );
  }
}
