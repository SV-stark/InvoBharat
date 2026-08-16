import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/einvoice_exporter.dart';

void main() {
  final profile = BusinessProfile(
    id: 'test_p',
    companyName: 'Bharat Traders Pvt Ltd',
    address: '123 MG Road, Connaught Place, New Delhi 110001',
    gstin: '07AAAAA0000A1Z5',
    email: 'info@bharattraders.com',
    phone: '9876543210',
    state: 'Delhi',
    currency: 'INR',
  );

  final invoice = Invoice(
    id: 'inv_101',
    invoiceNo: 'INV-101',
    invoiceDate: DateTime(2026, 8, 15),
    placeOfSupply: 'Maharashtra',
    supplier: const Supplier(
      name: 'Bharat Traders Pvt Ltd',
      address: '123 MG Road, Connaught Place, New Delhi 110001',
      gstin: '07AAAAA0000A1Z5',
      state: 'Delhi',
    ),
    receiver: const Receiver(
      name: 'Mumbai Tech Solutions',
      address: '456 Nariman Point, Mumbai, Maharashtra 400021',
      gstin: '27BBBBB1111B1Z2',
      state: 'Maharashtra',
      stateCode: '27',
    ),
    vehicleNo: 'DL01AB1234',
    ewayBillNo: 'EWB998877',
    items: const [
      InvoiceItem(
        description: 'Software Consulting',
        sacCode: '998311',
        quantity: 2,
        unit: 'HRS',
        amount: 5000,
        discount: 500,
      ),
    ],
  );

  group('EInvoiceExporter Tests', () {
    test('generateEInvoiceJson creates valid IRP JSON schema payload', () {
      final jsonStr = EInvoiceExporter.generateEInvoiceJson(invoice, profile);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(map['Version'], '1.1');
      expect(map['TranDtls']['TaxSch'], 'GST');
      expect(map['TranDtls']['SupTyp'], 'B2B');
      expect(map['DocDtls']['Typ'], 'INV');
      expect(map['DocDtls']['No'], 'INV-101');
      expect(map['SellerDtls']['Gstin'], '07AAAAA0000A1Z5');
      expect(map['BuyerDtls']['Gstin'], '27BBBBB1111B1Z2');
      expect(map['BuyerDtls']['Pos'], '27');
      expect(map['ItemList'].length, 1);
      expect(map['ItemList'][0]['HsnCd'], '998311');
      expect(map['ItemList'][0]['TotAmt'], 10000.0);
      expect(map['ItemList'][0]['Discount'], 500.0);
      expect(map['ItemList'][0]['PreTaxVal'], 9500.0);
      expect(map['ItemList'][0]['IgstAmt'], 1710.0);
      expect(map['ValDtls']['TotInvVal'], 11210.0);
    });

    test('generateEWayBillJson creates valid NIC schema payload with billLists and vehicle', () {
      final jsonStr = EInvoiceExporter.generateEWayBillJson(invoice, profile);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(map['version'], '1.0.0621');
      expect(map['billLists'], isA<List>());
      final bill = (map['billLists'] as List)[0] as Map<String, dynamic>;

      expect(bill['userGstin'], '07AAAAA0000A1Z5');
      expect(bill['supplyType'], 'O');
      expect(bill['docType'], 'INV');
      expect(bill['docNo'], 'INV-101');
      expect(bill['fromGstin'], '07AAAAA0000A1Z5');
      expect(bill['toGstin'], '27BBBBB1111B1Z2');
      expect(bill['vehicleNo'], 'DL01AB1234');
      expect(bill['transDocNo'], 'EWB998877');
      expect(bill['itemList'].length, 1);
      expect(bill['itemList'][0]['hsnCode'], 998311);
      expect(bill['itemList'][0]['taxableAmount'], 9500.0);
      expect(bill['itemList'][0]['igstRate'], 18.0);
      expect(bill['totInvValue'], 11210.0);
    });

    test('Credit Note generates CRN docType in E-Invoice and E-Way Bill', () {
      final creditNote = invoice.copyWith(
        type: InvoiceType.creditNote,
        invoiceNo: 'CN-001',
      );

      final eInvStr = EInvoiceExporter.generateEInvoiceJson(creditNote, profile);
      final eInvMap = jsonDecode(eInvStr) as Map<String, dynamic>;
      expect(eInvMap['DocDtls']['Typ'], 'CRN');

      final ewbStr = EInvoiceExporter.generateEWayBillJson(creditNote, profile);
      final ewbMap = jsonDecode(ewbStr) as Map<String, dynamic>;
      expect((ewbMap['billLists'] as List)[0]['docType'], 'CRN');
    });
  });
}
