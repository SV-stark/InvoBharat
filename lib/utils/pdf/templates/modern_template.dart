import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';
import 'dart:io';

class ModernTemplate extends BasePdfTemplate {
  @override
  String get name => 'Modern';

  @override
  Future<Uint8List> generate(
    final Invoice invoice,
    final BusinessProfile profile,
    final pw.Font font,
    final pw.Font fontBold, {
    final String? title,
  }) async {
    final pdf = pw.Document();

    final themeColor = PdfColor.fromInt(profile.colorValue);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (final context) => [
          // Header Bar
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: themeColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (profile.logoPath != null &&
                          profile.logoPath!.isNotEmpty &&
                          File(profile.logoPath!).existsSync())
                        pw.Image(
                          pw.MemoryImage(
                            File(profile.logoPath!).readAsBytesSync(),
                          ),
                          height: 50,
                        )
                      else
                        pw.Text(
                          profile.companyName,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        title ?? "INVOICE",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        "No: ${invoice.invoiceNo}",
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 32),

          // Info Rows
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "FROM",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      profile.companyName,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(profile.address, style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("GSTIN: ${profile.gstin}", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("Email: ${profile.email}", style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "BILL TO",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.receiver.name,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      invoice.receiver.address,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    if (invoice.receiver.gstin.isNotEmpty)
                      pw.Text(
                        "GSTIN: ${invoice.receiver.gstin}",
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    pw.Text(
                      "State: ${invoice.receiver.state}",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  buildField(
                    "Date",
                    DateFormat('dd/MM/yyyy').format(invoice.invoiceDate),
                    const pw.TextStyle(fontSize: 9),
                    const pw.TextStyle(fontSize: 9),
                  ),
                  if (invoice.dueDate != null)
                    buildField(
                      "Due Date",
                      DateFormat('dd/MM/yyyy').format(invoice.dueDate!),
                      const pw.TextStyle(fontSize: 9),
                      pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.red,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  buildField(
                    "Place of Supply",
                    invoice.placeOfSupply,
                    const pw.TextStyle(fontSize: 9),
                    const pw.TextStyle(fontSize: 9),
                  ),
                  if (invoice.reverseCharge == 'Y')
                    pw.Text("Reverse Charge: YES",
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          buildOriginalInvoiceInfo(invoice),
          pw.SizedBox(height: 32),

          // Items
          buildItemsTable(
            invoice,
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            headerDecoration: pw.BoxDecoration(color: themeColor),
          ),
          pw.SizedBox(height: 16),

          // Summary
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                  flex: 2,
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    if (profile.termsAndConditions.isNotEmpty) ...[
                      pw.Text("Terms & Conditions",
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: themeColor)),
                      pw.Text(profile.termsAndConditions, style: const pw.TextStyle(fontSize: 8)),
                      pw.SizedBox(height: 10),
                    ],
                    if (invoice.comments.isNotEmpty) ...[
                      pw.Text("Notes",
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: themeColor)),
                      pw.Text(invoice.comments, style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ])),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    buildSummaryRow(
                      "Taxable",
                      invoice.totalTaxableValue,
                      profile.currency,
                    ),
                    if (invoice.isInterState)
                      buildSummaryRow(
                        "IGST",
                        invoice.totalIGST,
                        profile.currency,
                      )
                    else ...[
                      buildSummaryRow(
                        "CGST",
                        invoice.totalCGST,
                        profile.currency,
                      ),
                      buildSummaryRow(
                        "SGST",
                        invoice.totalSGST,
                        profile.currency,
                      ),
                    ],
                    if (invoice.discountAmount > 0)
                      buildSummaryRow(
                        "Discount",
                        -invoice.discountAmount,
                        profile.currency,
                      ),
                    pw.Divider(color: themeColor),
                    buildSummaryRow(
                      "Total",
                      invoice.grandTotal,
                      profile.currency,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),
          buildAmountInWords(invoice.grandTotal),

          pw.SizedBox(height: 32),

          // Footer
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "PAYMENT INFO",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text("Bank: ${profile.bankName}", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("A/C: ${profile.accountNo}", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("IFSC: ${profile.ifscCode}", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("Branch: ${profile.branch}", style: const pw.TextStyle(fontSize: 8)),
                    if (profile.upiId.isNotEmpty) ...[
                      pw.Text(
                        "UPI ID: ${profile.upiId}",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      buildPaymentQRCode(
                        profile.upiId,
                        profile.companyName,
                        invoice.grandTotal,
                      ),
                    ],
                  ],
                ),
              ),
              pw.Column(
                children: [
                  pw.SizedBox(
                    width: 120,
                    height: 60,
                    child: pw.Stack(
                      alignment: pw.Alignment.center,
                      children: [
                        if (profile.stampPath != null &&
                            profile.stampPath!.isNotEmpty &&
                            File(profile.stampPath!).existsSync())
                          pw.Positioned(
                            left: profile.stampX,
                            top: profile.stampY,
                            child: pw.Image(
                              pw.MemoryImage(
                                File(profile.stampPath!).readAsBytesSync(),
                              ),
                              height: 60,
                              width: 60,
                            ),
                          ),
                        if (profile.signaturePath != null &&
                            profile.signaturePath!.isNotEmpty &&
                            File(profile.signaturePath!).existsSync())
                          pw.Positioned(
                            left: profile.signatureX,
                            top: profile.signatureY,
                            child: pw.Image(
                              pw.MemoryImage(
                                File(profile.signaturePath!).readAsBytesSync(),
                              ),
                              height: 40,
                            ),
                          ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 1),
                  pw.Text(
                    "Authorized Signatory",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
