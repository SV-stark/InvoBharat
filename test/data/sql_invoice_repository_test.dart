import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/invoice.dart' as model;
import 'package:invobharat/models/business_profile.dart' as model;
import 'package:invobharat/data/sql_invoice_repository.dart';

void main() {
  late AppDatabase database;
  late SqlInvoiceRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SqlInvoiceRepository(database, 'default');
  });

  tearDown(() async {
    await database.close();
  });

  final testProfile = model.BusinessProfile(
    id: 'default',
    companyName: 'Test Biz',
    address: 'Addr',
    gstin: 'GST123',
    email: 'e@b.com',
    phone: '123',
    accountNo: '123',
    branch: 'B1',
  );

  final testInvoice = model.Invoice(
    id: 'inv1',
    invoiceNo: 'INV-001',
    invoiceDate: DateTime.now(),
    supplier: const model.Supplier(name: 'Supplier'),
    receiver: const model.Receiver(name: 'Receiver'),
    items: [
      const model.InvoiceItem(description: 'Item 1', amount: 100),
    ],
  );

  group('SqlInvoiceRepository', () {
    test('saveInvoice and getInvoice', () async {
      await database.into(database.businessProfiles).insert(
            BusinessProfilesCompanion.insert(
              id: testProfile.id,
              companyName: testProfile.companyName,
              address: testProfile.address,
              gstin: testProfile.gstin,
              email: testProfile.email,
              phone: testProfile.phone,
              state: testProfile.state,
              colorValue: testProfile.colorValue,
              invoiceSeries: testProfile.invoiceSeries,
              invoiceSequence: testProfile.invoiceSequence,
              termsAndConditions: testProfile.termsAndConditions,
              defaultNotes: testProfile.defaultNotes,
              currencySymbol: testProfile.currency,
              bankName: testProfile.bankName,
              accountNo: testProfile.accountNo,
              ifscCode: testProfile.ifscCode,
              branch: testProfile.branch,
              pan: testProfile.pan,
            ),
          );

      await repository.saveInvoice(testInvoice);
      final invoice = await repository.getInvoice(testInvoice.id!);

      expect(invoice, isNotNull);
      expect(invoice?.invoiceNo, testInvoice.invoiceNo);
      expect(invoice?.items.length, 1);
    });

    test('getAllInvoices', () async {
      await repository.saveInvoice(testInvoice);
      final invoices = await repository.getAllInvoices();
      expect(invoices.length, 1);
    });

    test('deleteInvoice', () async {
      await repository.saveInvoice(testInvoice);
      await repository.deleteInvoice(testInvoice.id!);
      final invoice = await repository.getInvoice(testInvoice.id!);
      expect(invoice, isNull);
    });
  });
}
