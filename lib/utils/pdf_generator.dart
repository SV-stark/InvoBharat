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
                  "Total: ${profile.currencySymbol} ${invoice.grandTotal.toStringAsFixed(2)}",
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
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
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
                              DateFormat('dd MMM yyyy')
                                  .format(invoice.invoiceDate),
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
                        height: 50,
                        child: pw.Image(
                            pw.MemoryImage(
                                File(profile.signaturePath!).readAsBytesSync()),
                            fit: pw.BoxFit.contain)),
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
                                  "${profile.currencySymbol} ${invoice.totalTaxableValue.toStringAsFixed(2)}",
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
                          "Amount (in words): ${_getCurrencyName(profile.currencySymbol)} ${numberToWords(invoice.grandTotal)} Only",
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
        "Tax (${invoice.items.firstOrNull?.gstRate ?? 0}%)",
        "Total"
      ],
      data: invoice.items.map((item) {
        final isInterState = invoice.isInterState;
        final taxAmt = isInterState
            ? item.calculateIgst(true)
            : item.calculateCgst(false) + item.calculateSgst(false);

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
