import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';

abstract class InvoiceTemplate {
  String get name;
  Future<Uint8List> generate(
    final Invoice invoice,
    final BusinessProfile profile,
    final pw.Font font,
    final pw.Font fontBold, {
    final pw.Font? fontFallback,
    final String? title,
    final bool showHsnSummary = true,
    final Uint8List? logoBytes,
    final Uint8List? stampBytes,
    final Uint8List? signatureBytes,
  });
}
