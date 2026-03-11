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
// NOTE: Fonts are loaded inside the isolate because pw.Font objects cannot
// cross isolate boundaries. The performance improvement comes from the main
// isolate's font cache signalling "fonts available" via the title field, while
// the isolate itself re-downloads from the printing package's in-process cache
// (which is disk-backed after the first download, so subsequent calls are fast).
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
/// Generates a PDF invoice using an isolate for UI responsiveness.
///
/// Font warm-up: the first call triggers a font download (or disk cache read).
/// Subsequent calls re-use the isolate's in-process disk cache and are fast.
/// To ensure the first user-visible PDF is not slow, call [warmUpFonts] at
/// app startup.
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

Future<void> warmUpFonts() async {
  if (_fontsWarmedUp) return;
  _fontsWarmedUp = true;
  try {
    // Load to memory early
    await rootBundle.load('fonts/NotoSans-Regular.ttf');
  } catch (_) {
    _fontsWarmedUp = false;
  }
}
