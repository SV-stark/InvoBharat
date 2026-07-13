import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';

class CorporateTemplate extends BasePdfTemplate {
  @override
  String get name => 'Corporate';

  @override
  Future<Uint8List> generate(
    final Invoice invoice,
    final BusinessProfile profile,
    final pw.Font font,
    final pw.Font fontBold, {
    final String? title,
    final bool showHsnSummary = true,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    final themeColor = PdfColor.fromInt(profile.colorValue);
    final white = PdfColors.white;

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
        margin: pw.EdgeInsets.zero, // Full bleed for header
        build: (final context) {
          return [
            // Header Bar
            pw.Container(
              color: themeColor,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 30,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (hasLogo)
                          pw.Container(
                            height: 60,
                            margin: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Image(
                              pw.MemoryImage(File(logoPath).readAsBytesSync()),
                            ),
                          )
                        else
                          pw.Text(
                            profile.companyName,
                            style: pw.TextStyle(
                              color: white,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          supplyType,
                          style: pw.TextStyle(
                            color: white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          "Invoice #: ${invoice.invoiceNo}",
                          style: pw.TextStyle(color: white, fontSize: 10),
                        ),
                        pw.Text(
                          "Date: ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}",
                          style: pw.TextStyle(color: white, fontSize: 10),
                        ),
                        if (invoice.dueDate != null)
                          pw.Text(
                            "Due Date: ${DateFormat('dd MMM yyyy').format(invoice.dueDate!)}",
                            style: pw.TextStyle(
                              color: white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body Content
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 20,
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // From
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "FROM",
                              style: const pw.TextStyle(
                                color: PdfColors.grey600,
                                fontSize: 9,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              profile.companyName,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              profile.address,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                            if (profile.gstin.isNotEmpty)
                              pw.Text(
                                "GSTIN: ${profile.gstin}",
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            pw.Text(
                              "Phone: ${profile.phone}",
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      // To
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "BILL TO",
                              style: const pw.TextStyle(
                                color: PdfColors.grey600,
                                fontSize: 9,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              invoice.receiver.name,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
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
                      // Other Info
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            "INFO",
                            style: const pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 9,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          buildField(
                            "Place of Supply",
                            invoice.placeOfSupply,
                            const pw.TextStyle(fontSize: 9),
                            const pw.TextStyle(fontSize: 9),
                          ),
                          if (invoice.reverseCharge == 'Y')
                            pw.Text(
                              "Reverse Charge: YES",
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  buildOriginalInvoiceInfo(invoice),
                  buildEwayBillAndEinvoiceInfo(invoice, font, fontBold),
                  pw.SizedBox(height: 30),

                  // Items Table
                  buildItemsTable(
                    invoice,
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                    border: const pw.TableBorder(
                      bottom: pw.BorderSide(color: PdfColors.grey300),
                      horizontalInside: pw.BorderSide(color: PdfColors.grey100),
                    ),
                  ),
                  if (showHsnSummary) buildHsnSummaryTable(invoice, font, fontBold),
                  buildAmountInWords(invoice.grandTotal),
                  pw.SizedBox(height: 20),

                  // Totals
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 6,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (profile.termsAndConditions.isNotEmpty) ...[
                              pw.Text(
                                "Terms",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              pw.Text(
                                profile.termsAndConditions,
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                            if (invoice.comments.isNotEmpty) ...[
                              pw.SizedBox(height: 10),
                              pw.Text(
                                "Notes",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              pw.Text(
                                invoice.comments,
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                          ),
                          child: pw.Column(
                            children: [
                              buildSummaryRow(
                                "Taxable Value",
                                invoice.totalTaxableValue,
                                profile.currencySymbol,
                              ),
                              if (!invoice.isInterState) ...[
                                buildSummaryRow(
                                  "CGST",
                                  invoice.totalCGST,
                                  profile.currencySymbol,
                                ),
                                buildSummaryRow(
                                  "SGST",
                                  invoice.totalSGST,
                                  profile.currencySymbol,
                                ),
                              ] else
                                buildSummaryRow(
                                  "IGST",
                                  invoice.totalIGST,
                                  profile.currencySymbol,
                                ),
                              if (invoice.discountAmount > 0)
                                buildSummaryRow(
                                  "Discount",
                                  -invoice.discountAmount,
                                  profile.currencySymbol,
                                ),
                              pw.Divider(color: PdfColors.white),
                              buildSummaryRow(
                                "Total",
                                invoice.grandTotal,
                                profile.currencySymbol,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 40),

                  // Footer (Payment + Sign)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.SizedBox()), // Empty left

                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            pw.Text(
                              "Payment Details",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            pw.SizedBox(height: 5),
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
                            if (profile.upiId.isNotEmpty) ...[
                              pw.SizedBox(height: 5),
                              pw.Text(
                                "UPI ID: ${profile.upiId}",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: themeColor,
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
                                          File(
                                            profile.stampPath!,
                                          ).readAsBytesSync(),
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
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 10),
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
            ),
          ];
        },
        footer: (final context) => pw.Container(
          color: PdfColors.grey200,
          padding: const pw.EdgeInsets.all(10),
          child: pw.Center(
            child: pw.Text(
              "Thank you for your business!",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: themeColor,
              ),
            ),
          ),
        ),
      ),
    );

    return pdf.save();
  }
}
