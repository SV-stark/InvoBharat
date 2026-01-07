import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import 'invoice_template.dart';
import 'number_to_words.dart';

// --- FACTORY ---
Future<Uint8List> generateInvoicePdf(
    Invoice invoice, BusinessProfile profile) async {
  final font = await PdfGoogleFonts.notoSansRegular();
  final fontBold = await PdfGoogleFonts.notoSansBold();

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

  return template.generate(invoice, profile, font, fontBold);
}

// --- TEMPLATES ---

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
                      pw.Text(profile.address, style: headerLabel),
                      pw.Text("GSTIN: ${profile.gstin}", style: headerLabel),
                      pw.Text("Phone: ${profile.phone}", style: headerLabel),
                      if (profile.email.isNotEmpty)
                        pw.Text("Email: ${profile.email}", style: headerLabel),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("INVOICE", style: titleStyle),
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
                    ])
              ]),

          pw.SizedBox(height: 30),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.SizedBox(height: 10),

          // Bill To
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("Bill To:",
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text(invoice.receiver.name,
                style: const pw.TextStyle(fontSize: 11)),
            if (invoice.receiver.address.isNotEmpty)
              pw.Text(invoice.receiver.address, style: headerLabel),
            pw.Text("GSTIN: ${invoice.receiver.gstin}", style: headerLabel),
          ]),

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
                    flex: 6,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Amount in words:",
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "${_getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.grandTotal)} Only",
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
                pw.Expanded(
                    flex: 4,
                    child: pw.Column(children: [
                      _buildSummaryRow("Taxable Value",
                          invoice.totalTaxableValue, profile.currencySymbol),
                      if (invoice.totalCGST > 0)
                        _buildSummaryRow(
                            "CGST", invoice.totalCGST, profile.currencySymbol),
                      if (invoice.totalSGST > 0)
                        _buildSummaryRow(
                            "SGST", invoice.totalSGST, profile.currencySymbol),
                      if (invoice.totalIGST > 0)
                        _buildSummaryRow(
                            "IGST", invoice.totalIGST, profile.currencySymbol),
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
    final headers = ['#', 'Item', 'SAC', 'Qty', 'Rate', 'Total'];
    final data = invoice.items.asMap().entries.map((e) {
      final item = e.value;
      return [
        (e.key + 1).toString(),
        item.description,
        item.sacCode,
        "1",
        item.amount.toStringAsFixed(2),
        item.totalAmount.toStringAsFixed(2),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: const pw.TableBorder(
          top: pw.BorderSide(color: PdfColors.grey300),
          bottom: pw.BorderSide(color: PdfColors.grey300),
          horizontalInside: pw.BorderSide(color: PdfColors.grey200),
        ),
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerLeft,
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
        },
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4));
  }
}

class ProfessionalTemplate implements InvoiceTemplate {
  @override
  String get name => 'Professional';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile,
      pw.Font font, pw.Font fontBold) async {
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
        fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
    final itemsStyle = const pw.TextStyle(fontSize: 9);

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
                      pw.Text(profile.address, style: headerLabelStyle),
                      pw.Text("GSTIN: ${profile.gstin}",
                          style: headerLabelStyle),
                      pw.Text("Phone: ${profile.phone}",
                          style: headerLabelStyle),
                      pw.Text("Email: ${profile.email}",
                          style: headerLabelStyle),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("INVOICE", style: titleStyle),
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
              pw.Column(
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
                    pw.Text("GSTIN: ${invoice.receiver.gstin}",
                        style: headerLabelStyle),
                  ])
            ]),
          ),
          pw.SizedBox(height: 20),

          // --- ITEMS TABLE ---
          _buildItemsTable(invoice, tableHeaderStyle, itemsStyle),

          pw.SizedBox(height: 20),

          // --- TOTALS ---
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                    flex: 6,
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
                                  "${_getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.grandTotal)} Only",
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontStyle: pw.FontStyle.italic)),
                            ]))),
                pw.Expanded(
                    flex: 4,
                    child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4))),
                        child: pw.Column(children: [
                          _buildTotalRow(
                              "Taxable Value",
                              invoice.totalTaxableValue,
                              profile.currencySymbol),
                          if (invoice.totalCGST > 0)
                            _buildTotalRow("CGST", invoice.totalCGST,
                                profile.currencySymbol),
                          if (invoice.totalSGST > 0)
                            _buildTotalRow("SGST", invoice.totalSGST,
                                profile.currencySymbol),
                          if (invoice.totalIGST > 0)
                            _buildTotalRow("IGST", invoice.totalIGST,
                                profile.currencySymbol),
                          pw.Divider(),
                          _buildTotalRow("Total", invoice.grandTotal,
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

    final headers = [
      '#',
      'Description',
      'HSN/SAC',
      'Qty',
      'Rate',
      if (!isInterState) 'CGST',
      if (!isInterState) 'SGST',
      if (isInterState) 'IGST',
      'Total'
    ];

    final data = invoice.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return [
        (index + 1).toString(),
        item.description,
        item.sacCode,
        "1", // Qty hardcoded as per current model
        item.amount.toStringAsFixed(2),
        if (!isInterState) item.calculateCgst(false).toStringAsFixed(2),
        if (!isInterState) item.calculateSgst(false).toStringAsFixed(2),
        if (isInterState) item.calculateIgst(true).toStringAsFixed(2),
        item.totalAmount.toStringAsFixed(2),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: headerStyle,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellStyle: itemStyle,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    );
  }
}

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
                            pw.Text(profile.address, style: headerText),
                            pw.Text("GSTIN: ${profile.gstin}",
                                style: headerText),
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
                              ]))),
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
                            "${_getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.grandTotal)} Only",
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
        "1",
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

String _getCurrencyName(String symbol) {
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
