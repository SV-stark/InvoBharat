import 'dart:typed_data';
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart';
import 'invoice_template.dart';
import 'pdf/templates/modern_template.dart';
import 'pdf/templates/professional_template.dart';
import 'pdf/templates/minimal_template.dart';

Future<Uint8List> generateInvoicePdf(
    Invoice invoice, BusinessProfile profile) async {
  final font = await PdfGoogleFonts.notoSansRegular();
  final fontBold = await PdfGoogleFonts.notoSansBold();

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

  return template.generate(invoice, profile, font, fontBold);
}
