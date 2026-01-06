import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';

abstract class InvoiceTemplate {
  String get name;
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile);
}
