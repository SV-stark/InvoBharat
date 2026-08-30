import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MinimalTemplate extends BasePdfTemplate {
  @override
  String get name => 'Minimal';

  @override
  Future<Uint8List> generate(
    final Invoice invoice,
    final BusinessProfile profile,
    final pw.Font font,
    final pw.Font fontBold, {
    final pw.Font? fontFallback,
    final String? title,
    final bool showHsnSummary = true,
  }) async {
    final pdf = pw.Document();
    final themeColor = PdfColor.fromInt(profile.colorValue);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          fontFallback: fontFallback != null ? [fontFallback] : const [],
        ),
        build: (final context) => [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                        style: const pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      profile.address,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      "GSTIN: ${profile.gstin}",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        buildStatusBadge(invoice, font: fontBold),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          title ?? "INVOICE",
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    buildField(
                      "No",
                      invoice.invoiceNo,
                      const pw.TextStyle(fontSize: 10),
                      const pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    buildField(
                      "Date",
                      DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                      const pw.TextStyle(fontSize: 10),
                      const pw.TextStyle(fontSize: 10),
                    ),
                    if (invoice.dueDate != null)
                      buildField(
                        "Due Date",
                        DateFormat('dd MMM yyyy').format(invoice.dueDate!),
                        const pw.TextStyle(fontSize: 10),
                        const pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          buildOriginalInvoiceInfo(invoice),
          buildEwayBillAndEinvoiceInfo(invoice, font, fontBold),
          pw.SizedBox(height: 32),

          // Bill To
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
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
                    pw.Divider(thickness: 1, color: themeColor),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.receiver.name,
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(invoice.receiver.address),
                    if (invoice.receiver.gstin.isNotEmpty)
                      pw.Text("GSTIN: ${invoice.receiver.gstin}"),
                    if (invoice.receiver.state.isNotEmpty)
                      pw.Text("State: ${invoice.receiver.state}"),
                  ],
                ),
              ),
              pw.SizedBox(width: 64),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "PLACE OF SUPPLY",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    pw.Divider(thickness: 1, color: themeColor),
                    pw.SizedBox(height: 4),
                    pw.Text(invoice.placeOfSupply),
                    pw.Text(
                      "Reverse Charge: ${invoice.reverseCharge == 'Y' ? 'YES' : 'NO'}",
                      style: pw.TextStyle(
                        fontWeight: invoice.reverseCharge == 'Y'
                            ? pw.FontWeight.bold
                            : pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 32),

          // Items Table
          buildItemsTable(invoice),
          if (showHsnSummary) buildHsnSummaryTable(invoice, font, fontBold),
          pw.SizedBox(height: 16),

          // Summary and Notes
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (invoice.comments.isNotEmpty) ...[
                      pw.Text(
                        "Notes",
                        style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.comments,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.SizedBox(height: 16),
                    ],
                    if (invoice.paymentTerms.isNotEmpty) ...[
                      pw.Text(
                        "Terms",
                        style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.paymentTerms,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(width: 32),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    buildSummaryRow(
                      "Taxable Value",
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
            headerColor: themeColor,
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 16),

          // Footer (Terms, Payment QR, Sign)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (profile.termsAndConditions.isNotEmpty) ...[
                      pw.Text(
                        "TERMS & CONDITIONS",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        profile.termsAndConditions,
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ],
                    if (invoice.comments.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "NOTES",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        invoice.comments,
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ],
                  ],
                ),
              ),
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
                      style: const pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Authorized Signatory",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
