import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/pdf_helpers.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';

class ModernTemplate extends BasePdfTemplate {
  @override
  String get name => 'Modern';

  @override
  Future<Uint8List> generate(
      final Invoice invoice, final BusinessProfile profile, final pw.Font font, final pw.Font fontBold,
      {final String? title}) async {
    final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    ));
    final themeColor = PdfColor.fromInt(profile.colorValue);
    final headerText = const pw.TextStyle(color: PdfColors.white, fontSize: 9);
    final titleText = pw.TextStyle(
        color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold);

    String supplyType = title ?? "Tax Invoice";
    if (title == null && invoice.receiver.gstin.isEmpty) {
      supplyType = "Retail Invoice";
    }

    final logoPath = profile.logoPath;
    final hasLogo = logoPath != null && File(logoPath).existsSync();
    final signaturePath = profile.signaturePath;
    final hasSignature =
        signaturePath != null && File(signaturePath).existsSync();
    final stampPath = profile.stampPath;
    final hasStamp = stampPath != null && File(stampPath).existsSync();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (final context) {
          return pw.Column(children: [
            pw.Container(
                color: themeColor,
                padding: const pw.EdgeInsets.only(
                    top: 40, left: 30, right: 30, bottom: 20),
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                            if (hasLogo)
                              pw.Container(
                                  height: 50,
                                  margin: const pw.EdgeInsets.only(bottom: 10),
                                  child: pw.Image(
                                      pw.MemoryImage(
                                          File(logoPath).readAsBytesSync())))
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
                          ])
                    ])),
            pw.SizedBox(height: 20),
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
                                  pw.Text("State: ${invoice.receiver.state}",
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
                      ]))
                ])),
            pw.SizedBox(height: 30),
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
                  cellPadding:
                      const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                )),
            pw.SizedBox(height: 10),
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
                                pw.Text("Terms & Conditions",
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
                          ]))
                    ])),
            pw.Spacer(),
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
                          ]),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("For ${profile.companyName}",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9)),
                            if (hasSignature || hasStamp)
                              pw.Container(
                                  height: 60,
                                  width: 100,
                                  child: pw.Stack(
                                      alignment: pw.Alignment.center,
                                      children: [
                                        if (hasStamp)
                                          pw.Opacity(
                                              opacity: 0.6,
                                              child: pw.Image(
                                                  pw.MemoryImage(File(stampPath)
                                                      .readAsBytesSync()),
                                                  width: 80)),
                                        if (hasSignature)
                                          pw.Image(
                                              pw.MemoryImage(File(signaturePath)
                                                  .readAsBytesSync())),
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
