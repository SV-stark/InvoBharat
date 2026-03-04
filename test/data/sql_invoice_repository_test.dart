import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/models/invoice.dart' as model;
import 'package:invobharat/models/payment_transaction.dart';

void main() {
  late AppDatabase db;
  late SqlInvoiceRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = SqlInvoiceRepository(db);

    // Seed default business profile
    await db
        .into(db.businessProfiles)
        .insert(
          BusinessProfilesCompanion.insert(
            id: 'default',
            companyName: 'Test Company',
            address: 'Test Address',
            gstin: '29AAAAA0000A1Z5',
            email: 'test@example.com',
            phone: '1234567890',
            state: 'Karnataka',
            colorValue: 0xFF0000FF,
            invoiceSeries: 'INV-',
            invoiceSequence: 1,
            termsAndConditions: 'T&C',
            defaultNotes: 'Notes',
            currencySymbol: '₹',
            bankName: 'Test Bank',
            accountNumber: '12345',
            ifscCode: 'IFSC',
            branchName: 'Branch',
            pan: 'ABCDE1234F',
          ),
        );

    // Seed a client
    await db
        .into(db.clients)
        .insert(
          ClientsCompanion.insert(
            id: 'client-1',
            profileId: 'default',
            name: 'Test Client',
            address: 'Client Address',
            gstin: '27BBBBB1111B1Z0',
            pan: 'BBBBB1111B',
            state: 'Maharashtra',
            stateCode: '27',
            email: 'client@example.com',
            phone: '9876543210',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('SqlInvoiceRepository', () {
    final testInvoice = model.Invoice(
      invoiceNo: 'INV-001',
      invoiceDate: DateTime(2024, 1, 1),
      supplier: const model.Supplier(
        name: 'Test Company',
        address: 'Test Address',
        gstin: '29AAAAA0000A1Z5',
      ),
      receiver: const model.Receiver(
        name: 'Test Client',
        address: 'Client Address',
        gstin: '27BBBBB1111B1Z0',
        state: 'Maharashtra',
        stateCode: '27',
      ),
      items: [
        const model.InvoiceItem(
          description: 'Item 1',
          amount: 100.0,
          quantity: 2.0,
          gstRate: 18.0,
        ),
      ],
      payments: [
        PaymentTransaction(
          id: '', // Let repo generate unique ID
          invoiceId: '',
          date: DateTime(2024, 1, 1),
          amount: 50.0,
          paymentMode: 'Cash',
        ),
      ],
    );

    test('saveInvoice should insert invoice, items and payments', () async {
      await repository.saveInvoice(testInvoice);

      final invoices = await db.select(db.invoices).get();
      expect(invoices.length, 1);
      expect(invoices.first.invoiceNo, 'INV-001');

      final items = await db.select(db.invoiceItems).get();
      expect(items.length, 1);
      expect(items.first.description, 'Item 1');

      final payments = await db.select(db.payments).get();
      expect(payments.length, 1);
      expect(payments.first.amount, 50.0);
    });

    test('getInvoice should retrieve full invoice model', () async {
      final id = 'inv-uuid-1';
      final invoiceWithId = testInvoice.copyWith(id: id);
      await repository.saveInvoice(invoiceWithId);

      final retrieved = await repository.getInvoice(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.invoiceNo, 'INV-001');
      expect(retrieved.items.length, 1);
      expect(retrieved.payments.length, 1);
      expect(retrieved.receiver.name, 'Test Client');
    });

    test('getAllInvoices should return list', () async {
      await repository.saveInvoice(
        testInvoice.copyWith(id: '1', invoiceNo: 'INV-001'),
      );
      await repository.saveInvoice(
        testInvoice.copyWith(id: '2', invoiceNo: 'INV-002'),
      );

      final all = await repository.getAllInvoices();
      expect(all.length, 2);
    });

    test('deleteInvoice should remove all related data', () async {
      final id = 'del-me';
      await repository.saveInvoice(testInvoice.copyWith(id: id));

      await repository.deleteInvoice(id);

      expect(await repository.getInvoice(id), isNull);
      expect((await db.select(db.invoiceItems).get()).isEmpty, true);
      expect((await db.select(db.payments).get()).isEmpty, true);
    });

    test('checkInvoiceExists should work correctly', () async {
      await repository.saveInvoice(
        testInvoice.copyWith(id: '1', invoiceNo: 'INV-101'),
      );

      expect(await repository.checkInvoiceExists('INV-101'), true);
      expect(await repository.checkInvoiceExists('INV-102'), false);

      // Exclude current ID
      expect(
        await repository.checkInvoiceExists('INV-101', excludeId: '1'),
        false,
      );
    });

    test(
      'saveInvoice should increment business profile sequence if no matches pattern',
      () async {
        // Expected no is INV-001 (sequence 1)
        await repository.saveInvoice(testInvoice);

        final profile = await (db.select(
          db.businessProfiles,
        )..where((t) => t.id.equals('default'))).getSingle();
        expect(profile.invoiceSequence, 2);
      },
    );

    test('Credit Note should auto-link payment to original invoice', () async {
      // 1. Create original invoice
      final originalId = 'orig-id';
      final originalInv = testInvoice.copyWith(
        id: originalId,
        invoiceNo: 'INV-ORG',
      );
      await repository.saveInvoice(originalInv);

      // 2. Create Credit Note
      final cnId = 'cn-id';
      final creditNote = testInvoice.copyWith(
        id: cnId,
        invoiceNo: 'CN-001',
        type: model.InvoiceType.creditNote,
        originalInvoiceNumber: 'INV-ORG',
      );

      await repository.saveInvoice(creditNote);

      // 3. Verify original invoice now has a "Credit Note" payment
      final originalAfter = await repository.getInvoice(originalId);
      expect(
        originalAfter!.payments.any((p) => p.paymentMode == 'Credit Note'),
        true,
      );

      final cnPayment = originalAfter.payments.firstWhere(
        (p) => p.paymentMode == 'Credit Note',
      );
      expect(cnPayment.id, 'CN-PAY-$cnId');
    });
  });
}
