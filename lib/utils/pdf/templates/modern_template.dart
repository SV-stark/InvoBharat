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

// ... (imports remain same)

class ModernTemplate implements InvoiceTemplate {
  @override
  String get name => 'Modern';

  @override
  Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile, pw.Font font, pw.Font fontBold,
      {String? title}) async {
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

    // Determine Supply Type
    String supplyType = title ?? "Tax Invoice"; // Default
    if (title == null && invoice.receiver.gstin.isEmpty) {
      // B2C
      supplyType = "Retail Invoice";
      if (invoice.grandTotal >= 50000 && invoice.isInterState) {
        // B2C Large
      }
    }
    // Check if Export/SEZ (Logic would be in Invoice model usually, e.g. "Supply Type" field)
    // For now we stick to "Tax Invoice" unless composition scheme (Bill of Supply).

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
                            pw.Text(supplyType.toUpperCase(), style: titleText),
                            pw.SizedBox(height: 10),
                            _buildWhiteField("Invoice #", invoice.invoiceNo,
                                isLarge: true),
                            _buildWhiteField(
                                "Date",
                                DateFormat('dd MMM yyyy')
                                    .format(invoice.invoiceDate)),
                            _buildWhiteField(
                                "Place Of Supply", invoice.placeOfSupply),
                            _buildWhiteField(
                                "Reverse Charge", invoice.reverseCharge),
                            if (invoice.originalInvoiceNumber != null &&
                                invoice.originalInvoiceNumber!.isNotEmpty)
                              _buildWhiteField("Orig. Invoice No.",
                                  invoice.originalInvoiceNumber!),
                            if (invoice.originalInvoiceDate != null)
                              _buildWhiteField(
                                  "Orig. Invoice Date",
                                  DateFormat('dd MMM yyyy')
                                      .format(invoice.originalInvoiceDate!)),
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
                                pw.Text(
                                    "GSTIN: ${invoice.receiver.gstin.isEmpty ? 'Unregistered' : invoice.receiver.gstin}",
                                    style: const pw.TextStyle(fontSize: 9)),
                                if (invoice.receiver.state.isNotEmpty)
                                  pw.Text(
                                      "State: ${invoice.receiver.state}", // Removed State Code for cleaner look, valid per rule? Rule says State Name.
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
                          flex: 5,
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
                                pw.Text("Terms & Conditions", // Fixed Label
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
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                          flex: 5,
                          child: pw.Column(children: [
                            // Detailed Tax Breakup
                            _buildSummaryRow(
                                "Total Taxable Value",
                                invoice.totalTaxableValue,
                                profile.currencySymbol),
                            if (!invoice.isInterState)
                              _buildSummaryRow("Total CGST", invoice.totalCGST,
                                  profile.currencySymbol),
                            if (!invoice.isInterState)
                              _buildSummaryRow("Total SGST", invoice.totalSGST,
                                  profile.currencySymbol),
                            if (invoice.isInterState)
                              _buildSummaryRow("Total IGST", invoice.totalIGST,
                                  profile.currencySymbol),

                            pw.Divider(color: themeColor),
                            _buildSummaryRow("Grand Total", invoice.grandTotal,
                                profile.currencySymbol,
                                isBold: true, color: themeColor),
                            pw.SizedBox(height: 10),
                            pw.Container(
                                width: double.infinity,
                                padding: const pw.EdgeInsets.all(5),
                                color: PdfColors.grey200,
                                child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text("Tax Amount In Words:",
                                          style: pw.TextStyle(
                                              fontSize: 7,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.Text(
                                          numberToWords(invoice.totalCGST +
                                              invoice.totalSGST +
                                              invoice.totalIGST),
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontStyle: pw.FontStyle.italic))
                                    ]))
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
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Thank you for your business!",
                                style: pw.TextStyle(
                                    color: themeColor,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                "For any queries, contact ${profile.email.isNotEmpty ? profile.email : profile.phone}",
                                style: const pw.TextStyle(
                                    fontSize: 8, color: PdfColors.grey600)),
                          ]),
                      if (profile.companyName
                          .isNotEmpty) // Use business name for signature? Or logic to show something.
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text("For ${profile.companyName}",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 9)),
                              if (profile.signaturePath != null &&
                                  File(profile.signaturePath!).existsSync())
                                pw.Container(
                                    height: 40,
                                    child: pw.Image(
                                        pw.MemoryImage(
                                            File(profile.signaturePath!)
                                                .readAsBytesSync()),
                                        fit: pw.BoxFit.contain))
                              else
                                pw.SizedBox(height: 40),
                              pw.Text("Authorized Signatory",
                                  style: const pw.TextStyle(fontSize: 8)),
                            ])
                    ]))
          ]);
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildWhiteField(String label, String value,
      {bool isLarge = false}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
          pw.Text("$label: ",
              style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 9)),
          pw.Text(value,
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: isLarge ? 11 : 9,
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
    // GST Rule 46 requires: Description, HSN/SAC, Qty, Total Value, Taxable Value, CGST/SGST/IGST breakdown (Rate & Amount).
    // The previous table was a bit simplified. We should expand it.

    final bool isInterState = invoice.isInterState;

    List<String> headers = ['Item', 'HSN/SAC', 'Qty', 'Rate', 'Taxable Val'];
    if (isInterState) {
      headers.addAll(['IGST %', 'IGST Amt']);
    } else {
      headers.addAll(['CGST %', 'CGST Amt', 'SGST %', 'SGST Amt']);
    }
    headers.add('Total');

    final data = invoice.items.map((item) {
      final taxableValue = item.netAmount; // Amount * Qty - Discount
      final rate = item.amount;

      final row = [
        item.description,
        item.sacCode,
        "${item.quantity} ${item.unit}",
        rate.toStringAsFixed(2),
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
        headerStyle: pw.TextStyle(
            fontSize: 8, // Smaller font to fit more columns
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold),
        headerDecoration: pw.BoxDecoration(
            color: themeColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
        cellStyle: const pw.TextStyle(fontSize: 8),
        columnWidths: {
          0: const pw.FlexColumnWidth(3), // Description
          // Auto for others
        },
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          // Align numbers to right
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight, // Tax 1
          6: pw.Alignment.centerRight, // Tax 1
          if (!isInterState) 7: pw.Alignment.centerRight, // Tax 2
          if (!isInterState) 8: pw.Alignment.centerRight, // Tax 2
          headers.length - 1: pw.Alignment.centerRight // Total
        },
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4));
  }
}
