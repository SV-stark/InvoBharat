import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../models/invoice.dart';
import '../../../models/business_profile.dart';
import 'base_template.dart';

class CreativeTemplate extends BasePdfTemplate {
  @override
  String get name => 'Creative';

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
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Sidebar (Left)
              pw.Container(
                width: 180, // Fixed width sidebar
                height: double.infinity, // Full height
                padding: const pw.EdgeInsets.all(20),
                color: themeColor,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (hasLogo)
                      pw.Container(
                          height: 80,
                          margin: const pw.EdgeInsets.only(bottom: 20),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.white,
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.ClipOval(
                              child: pw.Image(
                            pw.MemoryImage(File(logoPath).readAsBytesSync()),
                            fit: pw.BoxFit.cover,
                          ))),
                    pw.Text(profile.companyName,
                        style: pw.TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 20),
                    pw.Text("ADDRESS",
                        style: pw.TextStyle(
                            color: white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text(profile.address,
                        style: pw.TextStyle(color: white, fontSize: 9)),
                    pw.SizedBox(height: 15),
                    pw.Text("CONTACT",
                        style: pw.TextStyle(
                            color: white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold)),
                    if (profile.phone.isNotEmpty)
                      pw.Text(profile.phone,
                          style: pw.TextStyle(color: white, fontSize: 9)),
                    if (profile.email.isNotEmpty)
                      pw.Text(profile.email,
                          style: pw.TextStyle(color: white, fontSize: 9)),
                    pw.Spacer(),
                    pw.Text("GSTIN",
                        style: pw.TextStyle(
                            color: white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text(profile.gstin,
                        style: pw.TextStyle(color: white, fontSize: 9)),
                  ],
                ),
              ),

              // Main Content (Right)
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(supplyType.toUpperCase(),
                              style: pw.TextStyle(
                                  color: themeColor,
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text("# ${invoice.invoiceNo}",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 12)),
                                pw.Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(invoice.invoiceDate),
                                    style: const pw.TextStyle(
                                        fontSize: 10,
                                        color: PdfColors.grey600)),
                              ])
                        ],
                      ),
                      pw.Divider(color: themeColor, thickness: 2),
                      pw.SizedBox(height: 20),

                      // Bill To
                      pw.Text("Billed To:",
                          style: pw.TextStyle(
                              color: PdfColors.grey600, fontSize: 10)),
                      pw.Text(invoice.receiver.name,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text(invoice.receiver.address,
                          style: const pw.TextStyle(fontSize: 10)),
                      if (invoice.receiver.gstin.isNotEmpty)
                        pw.Text("GSTIN: ${invoice.receiver.gstin}",
                            style: const pw.TextStyle(fontSize: 10)),

                      pw.SizedBox(height: 30),

                      // Items
                      buildItemsTable(
                        invoice,
                        headerDecoration: const pw.BoxDecoration(
                            border: pw.Border(
                                bottom: pw.BorderSide(
                                    width: 1, color: PdfColors.grey400))),
                        border: null,
                        headerStyle: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: themeColor,
                            fontSize: 9),
                      ),

                      pw.SizedBox(height: 30),

                      // Footer & Calculation
                      pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                                child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                  pw.Text("Bank Details",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          color: themeColor)),
                                  pw.Text(
                                      "${invoice.bankName}\n${invoice.accountNo}\n${invoice.ifscCode}",
                                      style: const pw.TextStyle(fontSize: 9)),
                                ])),
                            pw.Expanded(
                                child: pw.Column(children: [
                              buildSummaryRow(
                                  "Sub Total",
                                  invoice.totalTaxableValue,
                                  profile.currencySymbol),
                              buildSummaryRow(
                                  "Tax",
                                  invoice.totalCGST +
                                      invoice.totalSGST +
                                      invoice.totalIGST,
                                  profile.currencySymbol),
                              pw.Divider(),
                              buildSummaryRow("Total", invoice.grandTotal,
                                  profile.currencySymbol,
                                  isBold: true),
                            ]))
                          ]),

                      pw.Spacer(),
                      pw.Align(
                          alignment: pw.Alignment.bottomRight,
                          child: pw.Text("Authorized Signature",
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey600)))
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
