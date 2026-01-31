import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw; // Restore this
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart';
import 'invoice_template.dart';
import 'pdf/templates/modern_template.dart';
import 'pdf/templates/professional_template.dart';
import 'pdf/templates/minimal_template.dart';

Future<Uint8List> generateInvoicePdf(Invoice invoice, BusinessProfile profile,
    {String? title}) async {
  pw.Font font;
  pw.Font fontBold;
  try {
    font = await PdfGoogleFonts.notoSansRegular();
    fontBold = await PdfGoogleFonts.notoSansBold();
  } catch (e) {
    // Fallback if offline or error
    font = pw.Font.helvetica();
    fontBold = pw.Font.helveticaBold();
  }

  InvoiceTemplate template;
  switch (invoice.style) {
    case 'Professional':
      template = ProfessionalTemplate();
      break;
    case 'Minimal':
      template = MinimalTemplate();
      break;
    case 'Modern':
    default:
      template = ModernTemplate();
      break;
  }

  String? effectiveTitle = title;
  if (effectiveTitle == null) {
    if (invoice.type == InvoiceType.deliveryChallan) {
      effectiveTitle = "DELIVERY CHALLAN";
    } else if (invoice.type == InvoiceType.creditNote) {
      effectiveTitle = "CREDIT NOTE";
    } else if (invoice.type == InvoiceType.debitNote) {
      effectiveTitle = "DEBIT NOTE";
    } else {
      effectiveTitle = "TAX INVOICE";
    }
  }

  return template.generate(invoice, profile, font, fontBold,
      title: effectiveTitle);
}
