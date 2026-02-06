import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../models/invoice.dart';
import '../../../models/business_profile.dart';
import 'base_template.dart';

class CorporateTemplate extends BasePdfTemplate {
  @override
  String get name => 'Corporate';

  @override
  Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile, pw.Font font, pw.Font fontBold,
      {String? title}) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
    );

    final themeColor = PdfColor.fromInt(profile.colorValue);
    final white = PdfColors.white;

    String supplyType = title ?? "TAX INVOICE";
    if (title == null && invoice.receiver.gstin.isEmpty) {
      supplyType = "RETAIL INVOICE";
    }

    final logoPath = profile.logoPath;
    final hasLogo = logoPath != null && File(logoPath).existsSync();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero, // Full bleed for header
        build: (context) {
          return pw.Column(
            children: [
              // Header Bar
              pw.Container(
                color: themeColor,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (hasLogo)
                          pw.Container(
                            height: 60,
                            margin: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Image(
                                pw.MemoryImage(
                                    File(logoPath).readAsBytesSync()),
                                fit: pw.BoxFit.contain),
                          )
                        else
                          pw.Text(
                            profile.companyName,
                            style: pw.TextStyle(
                                color: white,
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold),
                          ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(supplyType,
                            style: pw.TextStyle(
                                color: white,
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text("Invoice #: ${invoice.invoiceNo}",
                            style: pw.TextStyle(color: white, fontSize: 10)),
                        pw.Text(
                            "Date: ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}",
                            style: pw.TextStyle(color: white, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              // Body Content
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: pw.Column(
                  children: [
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // From
                          pw.Expanded(
                              child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                pw.Text("FROM",
                                    style: pw.TextStyle(
                                        color: PdfColors.grey600, fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(profile.companyName,
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(profile.address,
                                    style: const pw.TextStyle(fontSize: 10)),
                                if (profile.gstin.isNotEmpty)
                                  pw.Text("GSTIN: ${profile.gstin}",
                                      style: const pw.TextStyle(fontSize: 10)),
                                pw.Text("Phone: ${profile.phone}",
                                    style: const pw.TextStyle(fontSize: 10)),
                              ])),
                          // To
                          pw.Expanded(
                              child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                pw.Text("BILL TO",
                                    style: pw.TextStyle(
                                        color: PdfColors.grey600, fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(invoice.receiver.name,
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(invoice.receiver.address,
                                    style: const pw.TextStyle(fontSize: 10)),
                                if (invoice.receiver.gstin.isNotEmpty)
                                  pw.Text("GSTIN: ${invoice.receiver.gstin}",
                                      style: const pw.TextStyle(fontSize: 10)),
                                if (invoice.receiver.state.isNotEmpty)
                                  pw.Text("State: ${invoice.receiver.state}",
                                      style: const pw.TextStyle(fontSize: 10)),
                              ])),
                        ]),
                    pw.SizedBox(height: 30),

                    // Items Table
                    buildItemsTable(
                      invoice,
                      headerDecoration:
                          pw.BoxDecoration(color: PdfColors.grey200),
                      headerStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 9),
                      border: pw.TableBorder(
                        bottom: pw.BorderSide(color: PdfColors.grey300),
                        horizontalInside:
                            pw.BorderSide(color: PdfColors.grey100),
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Totals & Bank
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                            flex: 6,
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text("Payment Details",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          color: themeColor)),
                                  pw.SizedBox(height: 5),
                                  pw.Text("Bank: ${invoice.bankName}",
                                      style: const pw.TextStyle(fontSize: 9)),
                                  pw.Text("A/c No: ${invoice.accountNo}",
                                      style: const pw.TextStyle(fontSize: 9)),
                                  pw.Text("IFSC: ${invoice.ifscCode}",
                                      style: const pw.TextStyle(fontSize: 9)),
                                  pw.SizedBox(height: 10),
                                  pw.Text("Terms",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          color: themeColor)),
                                  pw.Text(profile.termsAndConditions,
                                      style: const pw.TextStyle(
                                          fontSize: 8,
                                          color: PdfColors.grey700)),
                                ])),
                        pw.Expanded(
                            flex: 4,
                            child: pw.Container(
                                padding: const pw.EdgeInsets.all(10),
                                decoration: pw.BoxDecoration(
                                    color: PdfColors.grey100,
                                    borderRadius: const pw.BorderRadius.all(
                                        pw.Radius.circular(4))),
                                child: pw.Column(children: [
                                  buildSummaryRow(
                                      "Taxable Value",
                                      invoice.totalTaxableValue,
                                      profile.currencySymbol),
                                  if (!invoice.isInterState) ...[
                                    buildSummaryRow("CGST", invoice.totalCGST,
                                        profile.currencySymbol),
                                    buildSummaryRow("SGST", invoice.totalSGST,
                                        profile.currencySymbol),
                                  ] else
                                    buildSummaryRow("IGST", invoice.totalIGST,
                                        profile.currencySymbol),
                                  pw.Divider(color: PdfColors.white),
                                  buildSummaryRow("Total", invoice.grandTotal,
                                      profile.currencySymbol,
                                      isBold: true),
                                ]))),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Container(
                  color: PdfColors.grey200,
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(
                    child: pw.Text("Thank you for your business!",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, color: themeColor)),
                  ))
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
