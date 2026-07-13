import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';
import 'dart:io';

class ClassicTemplate extends BasePdfTemplate {
  @override
  String get name => 'Classic';

  @override
  Future<Uint8List> generate(
    final Invoice invoice,
    final BusinessProfile profile,
    final pw.Font font,
    final pw.Font fontBold, {
    final String? title,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    final black = PdfColors.black;

    String supplyType = title ?? "TAX INVOICE";
    if (title == null && invoice.receiver.gstin.isEmpty) {
      supplyType = "RETAIL INVOICE";
    }

    final logoPath = profile.logoPath;
    final hasLogo =
        logoPath != null && logoPath.isNotEmpty && File(logoPath).existsSync();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (final context) {
          return [
            // Header
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (hasLogo)
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(
                      pw.MemoryImage(File(logoPath).readAsBytesSync()),
                    ),
                  ),
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        profile.companyName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        profile.address,
                        style: const pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                      if (profile.gstin.isNotEmpty)
                        pw.Text(
                          "GSTIN: ${profile.gstin}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Phone: ${profile.phone}  |  Email: ${profile.email}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (hasLogo) pw.SizedBox(width: 80), // Balance
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 10),

            // Title
            pw.Center(
              child: pw.Text(
                supplyType,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Invoice Details & Bill To (2 Columns)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: Invoice Details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      buildField(
                        "Invoice No",
                        invoice.invoiceNo,
                        pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        const pw.TextStyle(),
                      ),
                      buildField(
                        "Date",
                        DateFormat('dd-MM-yyyy').format(invoice.invoiceDate),
                        pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        const pw.TextStyle(),
                      ),
                      if (invoice.dueDate != null)
                        buildField(
                          "Due Date",
                          DateFormat('dd-MM-yyyy').format(invoice.dueDate!),
                          pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red,
                          ),
                          const pw.TextStyle(),
                        ),
                      buildField(
                        "Place of Supply",
                        invoice.placeOfSupply,
                        pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        const pw.TextStyle(),
                      ),
                      buildField(
                        "Reverse Charge",
                        invoice.reverseCharge,
                        pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        const pw.TextStyle(),
                      ),
                    ],
                  ),
                ),
                // Right: Bill To
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Bill To:",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(invoice.receiver.name),
                      pw.Text(
                        invoice.receiver.address,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      if (invoice.receiver.gstin.isNotEmpty)
                        pw.Text(
                          "GSTIN: ${invoice.receiver.gstin}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      if (invoice.receiver.state.isNotEmpty)
                        pw.Text(
                          "State: ${invoice.receiver.state}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            buildOriginalInvoiceInfo(invoice),
            buildEwayBillAndEinvoiceInfo(invoice, font, fontBold),
            pw.SizedBox(height: 20),

            // Items Table
            buildItemsTable(
              invoice,
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              border: pw.TableBorder.all(color: black, width: 0.5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
            ),

            buildAmountInWords(invoice.grandTotal),

            pw.SizedBox(height: 10),

            // Summary and Footer Section
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(flex: 6, child: pw.SizedBox()),
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    children: [
                      buildSummaryRow(
                        "Taxable Value",
                        invoice.totalTaxableValue,
                        profile.currency,
                      ),
                      if (!invoice.isInterState) ...[
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
                      ] else
                        buildSummaryRow(
                          "IGST",
                          invoice.totalIGST,
                          profile.currency,
                        ),
                      if (invoice.discountAmount > 0)
                        buildSummaryRow(
                          "Discount",
                          -invoice.discountAmount,
                          profile.currency,
                        ),
                      pw.Divider(),
                      buildSummaryRow(
                        "Grand Total",
                        invoice.grandTotal,
                        profile.currency,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Terms and Notes
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (profile.termsAndConditions.isNotEmpty) ...[
                        pw.Text(
                          "Terms and Conditions:",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          profile.termsAndConditions,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                      if (invoice.comments.isNotEmpty) ...[
                        pw.SizedBox(height: 10),
                        pw.Text(
                          "Notes:",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          invoice.comments,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                // Bank and QR
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Bank Details:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        "Bank: ${invoice.bankName}",
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        "A/c No: ${invoice.accountNo}",
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        "IFSC: ${invoice.ifscCode}",
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        "Branch: ${invoice.branch}",
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      if (profile.upiId.isNotEmpty) ...[
                        pw.SizedBox(height: 5),
                        pw.Text(
                          "UPI ID: ${profile.upiId}",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Center(
                          child: buildPaymentQRCode(
                            profile.upiId,
                            profile.companyName,
                            invoice.grandTotal,
                            invoice.invoiceNo,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                // Signatory
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
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
                                    File(
                                      profile.signaturePath!,
                                    ).readAsBytesSync(),
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
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Authorized Signatory",
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
