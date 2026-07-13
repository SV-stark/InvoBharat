import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';

class CreativeTemplate extends BasePdfTemplate {
  @override
  String get name => 'Creative';

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
        margin: pw.EdgeInsets.zero,
        build: (final context) {
          return [
            pw.FullPage(
              ignoreMargins: true,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Sidebar (Left)
                  pw.Container(
                    width: 180, // Fixed width sidebar
                    height: PdfPageFormat.a4.height,
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
                                pw.MemoryImage(
                                  File(logoPath).readAsBytesSync(),
                                ),
                                fit: pw.BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          pw.Text(
                            profile.companyName,
                            style: pw.TextStyle(
                              color: white,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        pw.SizedBox(height: 20),
                        pw.Text(
                          "ADDRESS",
                          style: pw.TextStyle(
                            color: white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          profile.address,
                          style: pw.TextStyle(color: white, fontSize: 9),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Text(
                          "CONTACT",
                          style: pw.TextStyle(
                            color: white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (profile.phone.isNotEmpty)
                          pw.Text(
                            profile.phone,
                            style: pw.TextStyle(color: white, fontSize: 9),
                          ),
                        if (profile.email.isNotEmpty)
                          pw.Text(
                            profile.email,
                            style: pw.TextStyle(color: white, fontSize: 9),
                          ),
                        pw.SizedBox(height: 15),
                        pw.Text(
                          "GSTIN",
                          style: pw.TextStyle(
                            color: white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          profile.gstin,
                          style: pw.TextStyle(color: white, fontSize: 9),
                        ),
                        pw.Spacer(),
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
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  supplyType.toUpperCase(),
                                  style: pw.TextStyle(
                                    color: themeColor,
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.SizedBox(width: 10),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text(
                                    "# ${invoice.invoiceNo}",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pw.Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(invoice.invoiceDate),
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                  if (invoice.dueDate != null)
                                    pw.Text(
                                      "Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate!)}",
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        color: PdfColors.red,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          pw.Divider(color: themeColor, thickness: 2),
                          pw.SizedBox(height: 20),

                          // Bill To
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Billed To:",
                                      style: const pw.TextStyle(
                                        color: PdfColors.grey600,
                                        fontSize: 10,
                                      ),
                                    ),
                                    pw.Text(
                                      invoice.receiver.name,
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 14,
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
                                  ],
                                ),
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text(
                                    "Supply Details:",
                                    style: const pw.TextStyle(
                                      color: PdfColors.grey600,
                                      fontSize: 10,
                                    ),
                                  ),
                                  pw.Text(
                                    "Place: ${invoice.placeOfSupply}",
                                    style: const pw.TextStyle(fontSize: 10),
                                  ),
                                  if (invoice.reverseCharge == 'Y')
                                    pw.Text(
                                      "Reverse Charge: YES",
                                      style: pw.TextStyle(
                                        fontSize: 10,
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

                          // Items
                          buildItemsTable(
                            invoice,
                            headerDecoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(color: PdfColors.grey400),
                              ),
                            ),
                            headerStyle: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: themeColor,
                              fontSize: 9,
                            ),
                          ),
                          buildAmountInWords(invoice.grandTotal),
                          pw.SizedBox(height: 30),

                          // Calculation Row
                          pw.Row(
                            children: [
                              pw.Expanded(child: pw.SizedBox()),
                              pw.Expanded(
                                child: pw.Column(
                                  children: [
                                    buildSummaryRow(
                                      "Sub Total",
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
                          pw.SizedBox(height: 20),

                          // Footer Row (3 Columns)
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              // Column 1: Terms & Notes
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    if (profile
                                        .termsAndConditions
                                        .isNotEmpty) ...[
                                      pw.Text(
                                        "Terms",
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          color: themeColor,
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
                                        "Notes",
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          color: themeColor,
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
                              pw.SizedBox(width: 10),
                              // Column 2: Bank & QR
                              pw.Expanded(
                                child: pw.Column(
                                  children: [
                                    pw.Text(
                                      "Bank Details",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: themeColor,
                                      ),
                                    ),
                                    pw.Text(
                                      "Bank: ${invoice.bankName}\nA/c: ${invoice.accountNo}\nIFSC: ${invoice.ifscCode}",
                                      style: const pw.TextStyle(fontSize: 9),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                    if (profile.upiId.isNotEmpty) ...[
                                      pw.SizedBox(height: 8),
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
                              pw.SizedBox(width: 10),
                              // Column 3: Signature
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
                                              File(
                                                profile.stampPath!,
                                              ).existsSync())
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
                                              profile
                                                  .signaturePath!
                                                  .isNotEmpty &&
                                              File(
                                                profile.signaturePath!,
                                              ).existsSync())
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
                                    pw.Text(
                                      "For ${profile.companyName}",
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        color: themeColor,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      "Authorized Signature",
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontStyle: pw.FontStyle.italic,
                                        color: PdfColors.grey600,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
