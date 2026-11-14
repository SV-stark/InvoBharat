import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/database/database.dart' as db;
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/payment_transaction.dart';
import 'package:invobharat/services/gstr3b_service.dart';
import 'package:invobharat/services/gstr_service.dart';
import 'package:invobharat/utils/einvoice_exporter.dart';

void main() {
  final sampleProfile = BusinessProfile.defaults().copyWith(
    id: 'prof-1',
    companyName: 'Acme India Pvt Ltd',
    address: 'Nariman Point, Mumbai - 400001',
    gstin: '27AAAAA0000A1Z5',
    state: 'Maharashtra',
  );

  final discountedInvoice = Invoice(
    id: 'inv-disc-1',
    profileId: 'prof-1',
    invoiceNo: 'INV-2026-001',
    invoiceDate: DateTime(2026, 4, 15),
    supplier: const Supplier(
      name: 'Acme India Pvt Ltd',
      address: 'Nariman Point, Mumbai - 400001',
      gstin: '27AAAAA0000A1Z5',
      state: 'Maharashtra',
    ),
    receiver: const Receiver(
      name: 'Beta Corp',
      address: 'Baner Road, Pune - 411045',
      gstin: '27BBBBB1111B1Z5',
      state: 'Maharashtra',
      stateCode: '27',
    ),
    placeOfSupply: 'Maharashtra',
    discountAmount: 200.0,
    currency: 'USD',
    isArchived: true,
    deliveryAddress: 'Plot 42, MIDC, Pune',
    items: const [
      InvoiceItem(
        id: 'item-1',
        description: 'Cloud Consulting',
        sacCode: '998314',
        amount: 1000.0,
      ),
    ],
  );

  group('Tax Math & Invoice-Level Discount Fixes', () {
    test('E-Invoice JSON does not double-subtract discountAmount', () {
      final jsonStr = EInvoiceExporter.generateEInvoiceJson(
        discountedInvoice,
        sampleProfile,
      );
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      final valDtls = parsed['ValDtls'] as Map<String, dynamic>;
      final itemList = parsed['ItemList'] as List<dynamic>;
      final firstItem = itemList.first as Map<String, dynamic>;

      // Gross = 1000, invoice discount = 200 -> Taxable = 800, CGST = 72, SGST = 72, Total = 944
      expect(valDtls['AssVal'], equals(800.0));
      expect(valDtls['CgstVal'], equals(72.0));
      expect(valDtls['SgstVal'], equals(72.0));
      expect(valDtls['TotInvVal'], equals(944.0));

      expect(firstItem['AssAmt'], equals(800.0));
      expect(firstItem['CgstAmt'], equals(72.0));
      expect(firstItem['SgstAmt'], equals(72.0));
      expect(firstItem['TotItemVal'], equals(944.0));
    });

    test('E-Way Bill JSON uses discounted item taxable & tax values', () {
      final jsonStr = EInvoiceExporter.generateEWayBillJson(
        discountedInvoice,
        sampleProfile,
      );
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      final billLists = parsed['billLists'] as List<dynamic>;
      final bill = billLists.first as Map<String, dynamic>;

      expect(bill['totalValue'], equals(800.0));
      expect(bill['cgstValue'], equals(72.0));
      expect(bill['sgstValue'], equals(72.0));
      expect(bill['totInvValue'], equals(944.0));
    });

    test('GSTR-1 and GSTR-3B CSVs use discounted taxable and tax amounts', () {
      final gstr1Csv = GstrService().generateGstr1Csv([discountedInvoice]);
      expect(gstr1Csv, contains('800.00'));
      expect(gstr1Csv, contains('944.00'));

      final gstr3bCsv = Gstr3bService().generateGstr3bCsv([discountedInvoice]);
      expect(gstr3bCsv, contains('800.00,0.00,72.00,72.00'));
    });

    test('GSTR-1 Portal JSON generates valid b2b and hsn sections', () {
      final jsonStr = GstrService().generateGstr1PortalJson(
        [discountedInvoice],
        gstin: '27AAAAA0000A1Z5',
        fp: '042026',
      );
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(parsed['gstin'], equals('27AAAAA0000A1Z5'));
      expect(parsed['fp'], equals('042026'));

      final b2b = parsed['b2b'] as List<dynamic>;
      expect(b2b.length, equals(1));
      final ctinEntry = b2b.first as Map<String, dynamic>;
      expect(ctinEntry['ctin'], equals('27BBBBB1111B1Z5'));

      final invList = ctinEntry['inv'] as List<dynamic>;
      final invEntry = invList.first as Map<String, dynamic>;
      expect(invEntry['val'], equals(944.0));

      final hsn = parsed['hsn'] as Map<String, dynamic>;
      final hsnData = hsn['data'] as List<dynamic>;
      expect(hsnData.length, equals(1));
      expect((hsnData.first as Map<String, dynamic>)['txval'], equals(800.0));
    });
  });

  group('Bill of Supply & TDS Deduction Support', () {
    test('Bill of Supply zeroes out CGST, SGST, and IGST', () {
      final bosInvoice = discountedInvoice.copyWith(
        type: InvoiceType.billOfSupply,
      );
      expect(bosInvoice.totalTaxableValue, equals(800.0));
      expect(bosInvoice.totalCGST, equals(0.0));
      expect(bosInvoice.totalSGST, equals(0.0));
      expect(bosInvoice.totalIGST, equals(0.0));
      expect(bosInvoice.grandTotal, equals(800.0));
    });

    test('TDS deducted is counted in totalPaid and settles balanceDue', () {
      final withTds = discountedInvoice.copyWith(
        payments: [
          PaymentTransaction(
            id: 'pay-1',
            invoiceId: 'inv-disc-1',
            date: DateTime(2026, 4, 20),
            amount: 864.0,
            tdsDeducted: 80.0,
            paymentMode: 'Bank Transfer',
          ),
        ],
      );

      expect(withTds.totalCashPaid, equals(864.0));
      expect(withTds.totalTdsDeducted, equals(80.0));
      expect(withTds.totalPaid, equals(944.0));
      expect(withTds.balanceDue, equals(0.0));
      expect(withTds.paymentStatus, equals('Paid'));
    });
  });

  group('SqlInvoiceRepository Data Integrity', () {
    late db.AppDatabase database;
    late SqlInvoiceRepository repository;

    setUp(() async {
      database = db.AppDatabase(NativeDatabase.memory());
      await database
          .into(database.businessProfiles)
          .insert(
            db.BusinessProfilesCompanion.insert(
              id: 'prof-1',
              companyName: 'Acme India Pvt Ltd',
              address: 'Mumbai',
              gstin: '27AAAAA0000A1Z5',
              state: 'Maharashtra',
              email: 'info@acme.in',
              phone: '9999999999',
              bankName: 'HDFC',
              accountNo: '123',
              ifscCode: 'HDFC0001234',
              branch: 'Fort',
              termsAndConditions: 'Net 15',
              pan: 'AAAAA0000A',
              colorValue: 0xFF0078D4,
              currencySymbol: '₹',
              invoiceSeries: 'INV-',
              invoiceSequence: 1,
              defaultNotes: '',
            ),
          );
      repository = SqlInvoiceRepository(database, 'prof-1');
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'preserves supplier.state, discountAmount, currency, isArchived, deliveryAddress, tdsDeducted, and deletes emptied payments',
      () async {
        final initialWithPayment = discountedInvoice.copyWith(
          payments: [
            PaymentTransaction(
              id: 'pay-1',
              invoiceId: 'inv-disc-1',
              date: DateTime(2026, 4, 16),
              amount: 500.0,
              tdsDeducted: 50.0,
              paymentMode: 'UPI',
            ),
          ],
        );

        await repository.saveInvoice(initialWithPayment);

        final allLoaded = await repository.getAllInvoices();
        expect(allLoaded.length, equals(1));
        final loaded = allLoaded.first;

        expect(loaded.supplier.state, equals('Maharashtra'));
        expect(loaded.discountAmount, equals(200.0));
        expect(loaded.currency, equals('USD'));
        expect(loaded.isArchived, isTrue);
        expect(loaded.deliveryAddress, equals('Plot 42, MIDC, Pune'));
        expect(loaded.payments.length, equals(1));
        expect(loaded.payments.first.tdsDeducted, equals(50.0));

        // Now save with empty payments list and verify payments are deleted from DB
        await repository.saveInvoice(loaded.copyWith(payments: const []));
        final afterClear = await repository.getInvoice(loaded.id!);
        expect(afterClear, isNotNull);
        expect(afterClear!.payments, isEmpty);
      },
    );
  });
}
