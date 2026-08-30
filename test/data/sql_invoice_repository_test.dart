import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/invoice.dart' as model;
import 'package:invobharat/models/business_profile.dart' as model;
import 'package:invobharat/data/sql_invoice_repository.dart';

void main() {
  late AppDatabase database;
  late SqlInvoiceRepository repository;

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
    items: [const model.InvoiceItem(description: 'Item 1', amount: 100)],
  );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = SqlInvoiceRepository(database, 'default');
    await database
        .into(database.businessProfiles)
        .insert(
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
  });

  tearDown(() async {
    await database.close();
  });

  group('SqlInvoiceRepository', () {
    test('saveInvoice and getInvoice', () async {
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

    test('getMaxSequenceForPrefix dynamically tracks max in active FY and isolates across FYs', () async {
      final now = DateTime.now();
      final currentFYStartYear = now.month >= 4 ? now.year : now.year - 1;

      // Invoice in current FY: INV-029
      final inv29 = testInvoice.copyWith(
        id: 'inv29',
        invoiceNo: 'INV-029',
        invoiceDate: DateTime(currentFYStartYear, 6, 15),
      );
      await repository.saveInvoice(inv29);

      int maxSeq = await repository.getMaxSequenceForPrefix('INV-', invoiceDate: inv29.invoiceDate);
      expect(maxSeq, 29);

      // Invoice in previous FY: INV-050
      final invPrevFY = testInvoice.copyWith(
        id: 'inv_prev',
        invoiceNo: 'INV-050',
        invoiceDate: DateTime(currentFYStartYear - 1, 6, 15),
      );
      await repository.saveInvoice(invPrevFY);

      // Current FY should still report 29, ignoring the previous FY's 50!
      maxSeq = await repository.getMaxSequenceForPrefix('INV-', invoiceDate: inv29.invoiceDate);
      expect(maxSeq, 29);

      // Previous FY should report 50
      final maxPrev = await repository.getMaxSequenceForPrefix('INV-', invoiceDate: invPrevFY.invoiceDate);
      expect(maxPrev, 50);

      // Deletion of inv29 reclaims the sequence
      await repository.deleteInvoice(inv29.id!);
      final maxAfterDelete = await repository.getMaxSequenceForPrefix('INV-', invoiceDate: inv29.invoiceDate);
      expect(maxAfterDelete, 0);
    });

    test('Update invoice replaces items and payments cleanly without foreign key issues', () async {
      await repository.saveInvoice(testInvoice);
      
      // Update the invoice with new items and payments
      final updatedInvoice = testInvoice.copyWith(
        items: [
          const model.InvoiceItem(description: 'Updated Item A', amount: 200),
          const model.InvoiceItem(description: 'Updated Item B', amount: 300),
        ],
      );
      await repository.saveInvoice(updatedInvoice);
      
      final fetched = await repository.getInvoice(testInvoice.id!);
      expect(fetched, isNotNull);
      expect(fetched?.items.length, 2);
      expect(fetched?.items.first.description, 'Updated Item A');
    });

    test('Credit Note and Debit Note persistence with original invoice linkage', () async {
      final creditNote = testInvoice.copyWith(
        id: 'cn1',
        invoiceNo: 'CN-001',
        type: model.InvoiceType.creditNote,
        originalInvoiceNumber: 'INV-001',
        originalInvoiceDate: DateTime(2026, 1, 10),
      );

      await repository.saveInvoice(creditNote);
      final fetched = await repository.getInvoice('cn1');

      expect(fetched, isNotNull);
      expect(fetched?.type, model.InvoiceType.creditNote);
      expect(fetched?.originalInvoiceNumber, 'INV-001');
      expect(fetched?.originalInvoiceDate, DateTime(2026, 1, 10));
    });
  });
}
