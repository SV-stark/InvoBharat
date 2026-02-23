import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf/templates/base_template.dart';

class ClassicTemplate extends BasePdfTemplate {
  @override
  String get name => 'Classic';

  @override
  Future<Uint8List> generate(
      final Invoice invoice, final BusinessProfile profile, final pw.Font font, final pw.Font fontBold,
      {final String? title}) async {
    // Try to load a serif font for the classic look
    pw.Font serifFont;
    pw.Font serifBold;
    try {
      serifFont = await PdfGoogleFonts.tinosRegular();
      serifBold = await PdfGoogleFonts.tinosBold();
    } catch (e) {
      serifFont = pw.Font.times();
      serifBold = pw.Font.timesBold();
    }

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: serifFont,
        bold: serifBold,
      ),
    );

    final black = PdfColors.black;

    String supplyType = title ?? "TAX INVOICE";
    if (title == null && invoice.receiver.gstin.isEmpty) {
      supplyType = "RETAIL INVOICE";
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (final context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Center Aligned
              pw.Center(
                child: pw.Text(
                  profile.companyName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  profile.address,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (profile.gstin.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    "GSTIN: ${profile.gstin}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  "Phone: ${profile.phone}  |  Email: ${profile.email}",
                  style: const pw.TextStyle(fontSize: 10),
                ),
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
                            const pw.TextStyle()),
                        buildField(
                            "Date",
                            DateFormat('dd-MM-yyyy')
                                .format(invoice.invoiceDate),
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            const pw.TextStyle()),
                        buildField(
                            "Place of Supply",
                            invoice.placeOfSupply,
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            const pw.TextStyle()),
                        buildField(
                            "Reverse Charge",
                            invoice.reverseCharge,
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            const pw.TextStyle()),
                      ],
                    ),
                  ),
                  // Right: Bill To
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Bill To:",
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.receiver.name),
                        pw.Text(invoice.receiver.address,
                            style: const pw.TextStyle(fontSize: 10)),
                        if (invoice.receiver.gstin.isNotEmpty)
                          pw.Text("GSTIN: ${invoice.receiver.gstin}",
                              style: const pw.TextStyle(fontSize: 10)),
                        if (invoice.receiver.state.isNotEmpty)
                          pw.Text("State: ${invoice.receiver.state}",
                              style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Items Table - Simple borders
              buildItemsTable(
                invoice,
                headerStyle:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 9),
                border: pw.TableBorder.all(color: black, width: 0.5),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
              ),

              pw.SizedBox(height: 10),

              // Footer Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 6,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Bank Details:",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text("Bank: ${invoice.bankName}",
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text("A/c No: ${invoice.accountNo}",
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text("IFSC: ${invoice.ifscCode}",
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text("Branch: ${invoice.branch}",
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 10),
                        pw.Text("Terms and Conditions:",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.Text(profile.termsAndConditions,
                            style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      children: [
                        buildSummaryRow("Taxable Value",
                            invoice.totalTaxableValue, profile.currencySymbol),
                        if (!invoice.isInterState) ...[
                          buildSummaryRow("CGST", invoice.totalCGST,
                              profile.currencySymbol),
                          buildSummaryRow("SGST", invoice.totalSGST,
                              profile.currencySymbol),
                        ] else
                          buildSummaryRow("IGST", invoice.totalIGST,
                              profile.currencySymbol),
                        pw.Divider(),
                        buildSummaryRow("Grand Total", invoice.grandTotal,
                            profile.currencySymbol,
                            isBold: true),
                        pw.SizedBox(height: 20),
                        pw.Text("For ${profile.companyName}",
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right),
                        pw.SizedBox(height: 30),
                        pw.Text("Authorized Signatory",
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
