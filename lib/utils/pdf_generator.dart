import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/invoice_template.dart';
import 'package:invobharat/utils/pdf/templates/modern_template.dart';
import 'package:invobharat/utils/pdf/templates/professional_template.dart';
import 'package:invobharat/utils/pdf/templates/minimal_template.dart';
import 'package:invobharat/utils/pdf/templates/classic_template.dart';
import 'package:invobharat/utils/pdf/templates/corporate_template.dart';
import 'package:invobharat/utils/pdf/templates/creative_template.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path/path.dart' as p;

// ── Font warm-up flag ──────────────────────────────────────────────────────
bool _fontsWarmedUp = false;

class PdfGeneratorParams {
  final Invoice invoice;
  final BusinessProfile profile;
  final String? title;

  PdfGeneratorParams({
    required this.invoice,
    required this.profile,
    this.title,
  });
}

// ── Isolate worker ────────────────────────────────────────────────────────
Future<Uint8List> _generatePdfInIsolate(final PdfGeneratorParams params) async {
  pw.Font font;
  pw.Font fontBold;
  try {
    final regularData = await rootBundle.load('fonts/NotoSans-Regular.ttf');
    font = pw.Font.ttf(regularData.buffer.asByteData());

    final boldData = await rootBundle.load('fonts/NotoSans-Bold.ttf');
    fontBold = pw.Font.ttf(boldData.buffer.asByteData());
  } catch (_) {
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
      effectiveTitle = 'DELIVERY CHALLAN';
    } else if (params.invoice.type == InvoiceType.creditNote) {
      effectiveTitle = 'CREDIT NOTE';
    } else if (params.invoice.type == InvoiceType.debitNote) {
      effectiveTitle = 'DEBIT NOTE';
    } else if (params.invoice.receiver.gstin.isEmpty) {
      effectiveTitle = 'RETAIL INVOICE';
    } else {
      effectiveTitle = 'TAX INVOICE';
    }
  }

  return template.generate(
    params.invoice,
    params.profile,
    font,
    fontBold,
    title: effectiveTitle,
  );
}

// ── Public API ─────────────────────────────────────────────────────────────
Future<Uint8List> generateInvoicePdf(
  final Invoice invoice,
  final BusinessProfile profile, {
  final String? title,
}) async {
  final params = PdfGeneratorParams(
    invoice: invoice,
    profile: profile,
    title: title,
  );

  return Isolate.run(() => _generatePdfInIsolate(params));
}

/// Saves the generated PDF using native file saver
Future<String?> saveInvoicePdf(
  final Uint8List bytes,
  final String fileName,
) async {
  final extension = p.extension(fileName).replaceAll('.', '');
  final nameOnly = p.basenameWithoutExtension(fileName);
  
  return FileSaver.instance.saveFile(
    name: nameOnly,
    bytes: bytes,
    fileExtension: extension.isEmpty ? 'pdf' : extension,
    mimeType: MimeType.pdf,
  );
}

Future<void> warmUpFonts() async {
  if (_fontsWarmedUp) return;
  _fontsWarmedUp = true;
  try {
    await rootBundle.load('fonts/NotoSans-Regular.ttf');
  } catch (_) {
    _fontsWarmedUp = false;
  }
}
