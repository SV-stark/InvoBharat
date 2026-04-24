import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';
import 'package:invobharat/utils/number_to_words.dart';
import 'dart:io';

class ProfessionalTemplate extends BasePdfTemplate {
  @override
  String get name => 'Professional';

  @override
  Future<Uint8List> generate(
    final Invoice invoice,
    final BusinessProfile profile,
    final pw.Font font,
    final pw.Font fontBold, {
    final String? title,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (final context) => [
          // Header (Business Name and Invoice Title)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (profile.logoPath != null &&
                      profile.logoPath!.isNotEmpty &&
                      File(profile.logoPath!).existsSync())
                    pw.Image(
                      pw.MemoryImage(
                        File(profile.logoPath!).readAsBytesSync(),
                      ),
                      height: 60,
                    )
                  else
                    pw.Text(
                      profile.companyName,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  pw.SizedBox(height: 4),
                  pw.Text(profile.address, style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    "GSTIN: ${profile.gstin}",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text("Email: ${profile.email}", style: const pw.TextStyle(fontSize: 9)),
                  pw.Text("Phone: ${profile.phone}", style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    title ?? "TAX INVOICE",
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  buildField(
                    "Invoice No",
                    invoice.invoiceNo,
                    const pw.TextStyle(fontSize: 10),
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  buildField(
                    "Invoice Date",
                    DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                    const pw.TextStyle(fontSize: 10),
                    const pw.TextStyle(fontSize: 10),
                  ),
                  if (invoice.dueDate != null)
                    buildField(
                      "Due Date",
                      DateFormat('dd MMM yyyy').format(invoice.dueDate!),
                      const pw.TextStyle(fontSize: 10),
                      pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700,
                      ),
                    ),
                  buildField(
                    "Place of Supply",
                    invoice.placeOfSupply,
                    const pw.TextStyle(fontSize: 10),
                    const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 32),

          // Client and Payment Summary
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      child: pw.Text(
                        "BILL TO",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice.receiver.name,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
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
              pw.SizedBox(width: 32),
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      width: double.infinity,
                      child: pw.Text(
                        "SUMMARY",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    buildSummaryRow(
                      "Taxable Value",
                      invoice.totalTaxableValue,
                      profile.currency,
                    ),
                    if (invoice.isInterState)
                      buildSummaryRow(
                        "IGST Total",
                        invoice.totalIGST,
                        profile.currency,
                      )
                    else ...[
                      buildSummaryRow(
                        "CGST Total",
                        invoice.totalCGST,
                        profile.currency,
                      ),
                      buildSummaryRow(
                        "SGST Total",
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
                    pw.Divider(thickness: 1, color: PdfColors.grey400),
                    buildSummaryRow(
                      "GRAND TOTAL",
                      invoice.grandTotal,
                      profile.currency,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 32),

          // Items Table
          buildItemsTable(
            invoice,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          ),
          pw.SizedBox(height: 24),

          // Amount in Words
          pw.Text(
            "Amount in words: ${numberToWords(invoice.grandTotal)}",
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 32),

          // Terms and Bank Details
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "TERMS & CONDITIONS",
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.paymentTerms.isNotEmpty
                          ? invoice.paymentTerms
                          : "1. Please pay within 15 days of invoice date.\n2. Goods once sold will not be taken back.",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    if (invoice.comments.isNotEmpty) ...[
                      pw.SizedBox(height: 16),
                      pw.Text(
                        "NOTES",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.comments,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(width: 32),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "PAYMENT DETAILS",
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text("Bank Name: ${profile.bankName}", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("Account No: ${profile.accountNo}", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("IFSC Code: ${profile.ifscCode}", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("Branch: ${profile.branch}", style: const pw.TextStyle(fontSize: 8)),
                    if (profile.upiId.isNotEmpty)
                      pw.Text(
                        "UPI ID: ${profile.upiId}",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 64),

          // Signature Area
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
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
                  pw.Text(
                    "For ${profile.companyName}",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    "Authorized Signatory",
                    style: const pw.TextStyle(fontSize: 10),
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
