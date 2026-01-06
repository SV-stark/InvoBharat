import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import 'invoice_template.dart';

// --- FACTORY ---
Future<Uint8List> generateInvoicePdf(Invoice invoice, BusinessProfile profile) async {
  // TODO: Add logic to switch based on user preference. For now, defaulting to Modern if color is not default teal, else Professional.
  // Actually, let's just use Modern as default for now to show off the change.
  // Ideally, we'd pass a "templateName" string.
  
  final template = ModernTemplate(); 
  // final template = ProfessionalTemplate();
  
  return template.generate(invoice, profile);
}


// --- TEMPLATES ---

class ProfessionalTemplate implements InvoiceTemplate {
  @override
  String get name => 'Professional';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile) async {
     final pdf = pw.Document();
     // Reuse existing logic (simplified)
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => _buildContent(invoice, profile),
      ));
      return pdf.save();
  }
  
  pw.Widget _buildContent(Invoice invoice, BusinessProfile profile) {
      // ... (Keeping the original logic mostly, but hooking up profile)
      // For brevity, using a simplified version of the original layout
      return pw.Column(children: [
          pw.Text("TAX INVOICE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          pw.Divider(),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text("Supplier: ${profile.companyName}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(profile.address),
                  pw.Text("GSTIN: ${profile.gstin}"),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text("Invoice No: ${invoice.invoiceNo}"),
                  pw.Text("Date: ${DateFormat('dd/MM/yyyy').format(invoice.invoiceDate)}"),
              ])
          ]),
          pw.SizedBox(height: 20),
          _buildTable(invoice),
          pw.Spacer(),
          pw.Text("Authorized Signatory"),
      ]);
  }

  pw.Widget _buildTable(Invoice invoice) {
      // Simplified table for Professional
       return pw.TableHelper.fromTextArray(
        headers: ['Item', 'Amount'],
        data: invoice.items.map((i) => [i.description, i.totalAmount.toStringAsFixed(2)]).toList(),
      );
  }
}

class ModernTemplate implements InvoiceTemplate {
  @override
  String get name => 'Modern';

  @override
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile) async {
    final pdf = pw.Document();
    final themeColor = PdfColor.fromInt(profile.colorValue);
    final themeColor = PdfColor.fromInt(profile.colorValue);

    pw.MemoryImage? logoImage;
    if (profile.logoPath != null) {
        final file = File(profile.logoPath!);
        if (await file.exists()) {
             logoImage = pw.MemoryImage(await file.readAsBytes());
        }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            children: [
              // Header
              pw.Container(
                color: themeColor,
                padding: const pw.EdgeInsets.all(20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("INVOICE", style: pw.TextStyle(color: PdfColors.white, fontSize: 32, fontWeight: pw.FontWeight.bold)),
                    if (logoImage != null) pw.Container(height: 50, width: 50, child: pw.Image(logoImage))
                    else pw.Text(profile.companyName, style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ]
                )
              ),
              
              pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(children: [
                      // Info Row
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              pw.Text("Billed To:", style: pw.TextStyle(color: themeColor, fontWeight: pw.FontWeight.bold)),
                              pw.Text(invoice.receiver.name),
                              pw.Text("GSTIN: ${invoice.receiver.gstin}"),
                          ]),
                          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                              pw.Text("Invoice #${invoice.invoiceNo}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(invoice.invoiceDate)}"),
                          ])
                      ]),
                      pw.SizedBox(height: 30),
                      
                      // Table
                      pw.TableHelper.fromTextArray(
                          headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                          headerDecoration: pw.BoxDecoration(color: themeColor),
                          oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                          headers: ['Description', 'Qty', 'Price', 'Total'],
                          data: invoice.items.map((item) => [
                              item.description,
                              "1", // Qty placeholder
                              item.amount.toStringAsFixed(2),
                              item.totalAmount.toStringAsFixed(2)
                          ]).toList(),
                      ),
                      
                      pw.SizedBox(height: 20),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                          pw.Text("Total: ", style: pw.TextStyle(fontSize: 18)),
                          pw.Text("Rs. ${invoice.grandTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: themeColor)),
                      ]),
                  ])
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Container(
                  color: PdfColors.grey200,
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Center(child: pw.Text("Thank you for your business!", style: pw.TextStyle(color: PdfColors.grey800)))
              )
            ]
          );
        },
      ),
    );

    return pdf.save();
  }
}
