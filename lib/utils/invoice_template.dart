import 'dart:typed_data';
import '../models/invoice.dart';
import '../models/business_profile.dart';

abstract class InvoiceTemplate {
  String get name;
  Future<Uint8List> generate(Invoice invoice, BusinessProfile profile);
}
