import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../models/invoice.dart';
import '../../../models/business_profile.dart';
import '../../number_to_words.dart';
import '../pdf_helpers.dart';

// ... (imports remain same)

import 'base_template.dart';

// ... (imports remain same)

class ModernTemplate extends BasePdfTemplate {
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
                            buildField("Invoice #", invoice.invoiceNo,
                                titleText.copyWith(fontSize: 9), headerText),
                            buildField(
                                "Date",
                                DateFormat('dd MMM yyyy')
                                    .format(invoice.invoiceDate),
                                titleText.copyWith(fontSize: 9),
                                headerText),
                            buildField("Place Of Supply", invoice.placeOfSupply,
                                titleText.copyWith(fontSize: 9), headerText),
                            buildField("Reverse Charge", invoice.reverseCharge,
                                titleText.copyWith(fontSize: 9), headerText),
                            if (invoice.originalInvoiceNumber != null &&
                                invoice.originalInvoiceNumber!.isNotEmpty)
                              buildField(
                                  "Orig. Invoice No.",
                                  invoice.originalInvoiceNumber!,
                                  titleText.copyWith(fontSize: 9),
                                  headerText),
                            if (invoice.originalInvoiceDate != null)
                              buildField(
                                  "Orig. Invoice Date",
                                  DateFormat('dd MMM yyyy')
                                      .format(invoice.originalInvoiceDate!),
                                  titleText.copyWith(fontSize: 9),
                                  headerText),
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
                child: buildItemsTable(
                  invoice,
                  includeIndex: false,
                  headerStyle: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(
                      color: themeColor,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4))),
                  oddRowDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey100),
                  border: null,
                  cellPadding:
                      const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                )),

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
                                buildUpiQr(profile.upiId, profile.upiName,
                                    invoice, profile.currencySymbol),
                              ])),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                          flex: 5,
                          child: pw.Column(children: [
                            // Detailed Tax Breakup
                            buildSummaryRow(
                                "Total Taxable Value",
                                invoice.totalTaxableValue,
                                profile.currencySymbol),
                            if (!invoice.isInterState)
                              buildSummaryRow("Total CGST", invoice.totalCGST,
                                  profile.currencySymbol),
                            if (!invoice.isInterState)
                              buildSummaryRow("Total SGST", invoice.totalSGST,
                                  profile.currencySymbol),
                            if (invoice.isInterState)
                              buildSummaryRow("Total IGST", invoice.totalIGST,
                                  profile.currencySymbol),

                            pw.Divider(color: themeColor),
                            buildSummaryRow("Grand Total", invoice.grandTotal,
                                profile.currencySymbol,
                                isBold: true),
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
                              if ((profile.signaturePath != null &&
                                      File(profile.signaturePath!)
                                          .existsSync()) ||
                                  (profile.stampPath != null &&
                                      File(profile.stampPath!).existsSync()))
                                pw.Container(
                                    height: 60,
                                    width: 100,
                                    child: pw.Stack(
                                        alignment: pw.Alignment.center,
                                        children: [
                                          if (profile.stampPath != null &&
                                              File(profile.stampPath!)
                                                  .existsSync())
                                            pw.Opacity(
                                                opacity: 0.6,
                                                child: pw.Image(
                                                    pw.MemoryImage(
                                                        File(profile.stampPath!)
                                                            .readAsBytesSync()),
                                                    width: 60)),
                                          if (profile.signaturePath != null &&
                                              File(profile.signaturePath!)
                                                  .existsSync())
                                            pw.Image(
                                                pw.MemoryImage(
                                                    File(profile.signaturePath!)
                                                        .readAsBytesSync()),
                                                height: 40,
                                                fit: pw.BoxFit.contain),
                                        ]))
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
}
