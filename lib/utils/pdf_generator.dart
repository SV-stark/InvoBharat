import 'dart:isolate';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import 'invoice_template.dart';
import 'pdf/templates/modern_template.dart';
import 'pdf/templates/professional_template.dart';
import 'pdf/templates/minimal_template.dart';
import 'pdf/templates/classic_template.dart';
import 'pdf/templates/corporate_template.dart';
import 'pdf/templates/creative_template.dart';

class PdfGeneratorParams {
  final Invoice invoice;
  final BusinessProfile profile;
  final String? title;

  PdfGeneratorParams({required this.invoice, required this.profile, this.title});
}

Future<Uint8List> _generatePdfInIsolate(PdfGeneratorParams params) async {
  pw.Font font;
  pw.Font fontBold;
  try {
    font = await PdfGoogleFonts.notoSansRegular();
    fontBold = await PdfGoogleFonts.notoSansBold();
  } catch (e) {
    font = pw.Font.helvetica();
    fontBold = pw.Font.helveticaBold();
  }

  InvoiceTemplate template;
  switch (params.invoice.style) {
    case 'Professional':
      template = ProfessionalTemplate();
      break;
    case 'Minimal':
      template = MinimalTemplate();
      break;
    case 'Classic':
      template = ClassicTemplate();
      break;
    case 'Corporate':
      template = CorporateTemplate();
      break;
    case 'Creative':
      template = CreativeTemplate();
      break;
    case 'Modern':
    default:
      template = ModernTemplate();
      break;
  }

  String? effectiveTitle = params.title;
  if (effectiveTitle == null) {
    if (params.invoice.type == InvoiceType.deliveryChallan) {
      effectiveTitle = "DELIVERY CHALLAN";
    } else if (params.invoice.type == InvoiceType.creditNote) {
      effectiveTitle = "CREDIT NOTE";
    } else if (params.invoice.type == InvoiceType.debitNote) {
      effectiveTitle = "DEBIT NOTE";
    } else {
      effectiveTitle = "TAX INVOICE";
    }
  }

  return template.generate(params.invoice, params.profile, font, fontBold,
      title: effectiveTitle);
}

Future<Uint8List> generateInvoicePdf(Invoice invoice, BusinessProfile profile,
    {String? title}) async {
  final params = PdfGeneratorParams(
    invoice: invoice,
    profile: profile,
    title: title,
  );
  
  return await Isolate.run(() => _generatePdfInIsolate(params));
}
