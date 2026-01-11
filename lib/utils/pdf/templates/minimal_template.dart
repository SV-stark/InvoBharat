import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../models/invoice.dart';
import '../../../models/business_profile.dart';
import '../../number_to_words.dart';
import '../pdf_helpers.dart';

import 'base_template.dart';

// ... imports

class MinimalTemplate extends BasePdfTemplate {
  @override
  String get name => 'Minimal';

  @override
  Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile, pw.Font font, pw.Font fontBold,
      {String? title}) async {
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
    String supplyType = title ?? "Tax Invoice";
    if (title == null && invoice.receiver.gstin.isEmpty) {
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
                      buildField("Invoice #", invoice.invoiceNo, headerLabel,
                          headerValue),
                      buildField(
                          "Date",
                          DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                          headerLabel,
                          headerValue),
                      buildField("Place of Supply", invoice.placeOfSupply,
                          headerLabel, headerValue),
                      buildField("Reverse Charge", invoice.reverseCharge,
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
          buildItemsTable(invoice),

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
                      buildSummaryRow("Total Taxable Value",
                          invoice.totalTaxableValue, profile.currencySymbol),
                      if (invoice.totalCGST > 0)
                        buildSummaryRow("Total CGST", invoice.totalCGST,
                            profile.currencySymbol),
                      if (invoice.totalSGST > 0)
                        buildSummaryRow("Total SGST", invoice.totalSGST,
                            profile.currencySymbol),
                      if (invoice.totalIGST > 0)
                        buildSummaryRow("Total IGST", invoice.totalIGST,
                            profile.currencySymbol),
                      pw.Divider(),
                      buildSummaryRow("Grand Total", invoice.grandTotal,
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
}
