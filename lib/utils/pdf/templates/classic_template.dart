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
    final pw.Font? fontFallback,
    final String? title,
    final bool showHsnSummary = true,
    final Uint8List? logoBytes,
    final Uint8List? stampBytes,
    final Uint8List? signatureBytes,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
        fontFallback: fontFallback != null ? [fontFallback] : const [],
      ),
    );

    final black = PdfColors.black;

    String supplyType = title ?? "TAX INVOICE";
    if (title == null && invoice.receiver.gstin.isEmpty) {
      supplyType = "RETAIL INVOICE";
    }

    final pw.MemoryImage? logoImage = logoBytes != null
        ? pw.MemoryImage(logoBytes)
        : null;
    final pw.MemoryImage? stampImage = stampBytes != null
        ? pw.MemoryImage(stampBytes)
        : null;
    final pw.MemoryImage? signatureImage = signatureBytes != null
        ? pw.MemoryImage(signatureBytes)
        : null;

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
                if (logoImage != null)
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(logoImage),
                  ),
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        profile.companyName.toUpperCase(),
                        style: const pw.TextStyle(
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
                if (logoImage != null) pw.SizedBox(width: 80), // Balance
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 10),

            // Title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                buildStatusBadge(invoice, font: fontBold),
                pw.SizedBox(width: 8),
                pw.Text(
                  supplyType,
                  style: const pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ],
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
                        const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        const pw.TextStyle(),
                      ),
                      buildField(
                        "Date",
                        DateFormat('dd-MM-yyyy').format(invoice.invoiceDate),
                        const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        const pw.TextStyle(),
                      ),
                      if (invoice.dueDate != null)
                        buildField(
                          "Due Date",
                          DateFormat('dd-MM-yyyy').format(invoice.dueDate!),
                          const pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red,
                          ),
                          const pw.TextStyle(),
                        ),
                      buildField(
                        "Place of Supply",
                        invoice.placeOfSupply,
                        const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        const pw.TextStyle(),
                      ),
                      buildField(
                        "Reverse Charge",
                        invoice.reverseCharge == 'Y' ? "Yes" : "No",
                        const pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
                        style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
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
              headerStyle: const pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              border: pw.TableBorder.all(color: black, width: 0.5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
            ),
            if (showHsnSummary) buildHsnSummaryTable(invoice, font, fontBold),

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
            pw.SizedBox(height: 16),
            buildAmountInWords(invoice.grandTotal),
            buildBankDetailsSection(
              invoice,
              profile,
              font: font,
              fontBold: fontBold,
            ),
            pw.SizedBox(height: 16),
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
                          style: const pw.TextStyle(
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
                        pw.SizedBox(height: 8),
                        pw.Text(
                          "Notes:",
                          style: const pw.TextStyle(
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
                // QR Code in Middle
                pw.Expanded(
                  child: profile.upiId.isNotEmpty
                      ? pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            buildPaymentQRCode(
                              profile.upiId,
                              profile.companyName,
                              invoice.grandTotal,
                              invoice.invoiceNo,
                            ),
                          ],
                        )
                      : pw.SizedBox(),
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
                            if (stampImage != null)
                              pw.Positioned(
                                left: profile.stampX,
                                top: profile.stampY,
                                child: pw.Image(
                                  stampImage,
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                            if (signatureImage != null)
                              pw.Positioned(
                                left: profile.signatureX,
                                top: profile.signatureY,
                                child: pw.Image(signatureImage, height: 40),
                              ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "For ${profile.companyName}",
                        style: const pw.TextStyle(
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
