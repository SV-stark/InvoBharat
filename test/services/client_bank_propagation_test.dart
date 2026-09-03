import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:invobharat/database/database.dart' hide Client, Invoice;
import 'package:invobharat/data/sql_client_repository.dart';
import 'package:invobharat/data/sql_bank_repository.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/data/sql_business_profile_repository.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/models/bank_account.dart';
import 'package:invobharat/models/business_profile.dart' as model_bp;
import 'package:invobharat/models/invoice.dart' as model_inv;

void main() {
  late AppDatabase db;
  late SqlClientRepository clientRepo;
  late SqlBankRepository bankRepo;
  late SqlInvoiceRepository invoiceRepo;
  late SqlBusinessProfileRepository profileRepo;
  const testProfileId = 'test_prof_1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clientRepo = SqlClientRepository(db, testProfileId);
    bankRepo = SqlBankRepository(db);
    invoiceRepo = SqlInvoiceRepository(db, testProfileId);
    profileRepo = SqlBusinessProfileRepository(db);

    // Seed test profile
    await profileRepo.saveProfile(
      model_bp.BusinessProfile(
        id: testProfileId,
        companyName: 'Acme Corp',
        address: '123 Main St',
        gstin: '07AAAAA0000A1Z5',
        email: 'acme@example.com',
        phone: '9876543210',
        state: 'Delhi',
        colorValue: 0xFF000000,
        currency: 'INR',
        bankName: 'Old Bank',
        accountNo: '11111',
        ifscCode: 'OLDB0001',
        branch: 'Old Branch',
        pan: 'AAAAA0000A',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Client & Bank Update Propagation Tests', () {
    test('Editing saved client propagates updated details to draft invoices', () async {
      // 1. Create client
      const client = Client(
        id: 'client_1',
        name: 'Original Client Name',
        address: 'Old Address',
        gstin: '07BBBBB1111B1Z1',
        email: 'client@example.com',
        phone: '1234567890',
        state: 'Delhi',
        profileId: testProfileId,
      );
      await clientRepo.saveClient(client);

      // 2. Create draft invoice for this client
      final draftInvoice = model_inv.Invoice(
        id: 'inv_draft_1',
        profileId: testProfileId,
        invoiceNo: 'INV-001',
        invoiceDate: DateTime.now(),
        supplier: const model_inv.Supplier(name: 'Acme Corp'),
        receiver: model_inv.Receiver(
          name: client.name,
          address: client.address,
          gstin: client.gstin,
          email: client.email,
          phone: client.phone,
          state: client.state,
        ),
      );
      await invoiceRepo.saveInvoice(draftInvoice);

      // Verify invoice exists with original details
      var invoices = await invoiceRepo.getAllInvoices();
      expect(invoices.length, 1);
      expect(invoices.first.receiver.name, 'Original Client Name');
      expect(invoices.first.receiver.address, 'Old Address');

      // 3. Edit client details
      final updatedClient = client.copyWith(
        name: 'Updated Client Name Pvt Ltd',
        address: '456 New Road, Suite 100',
        phone: '9998887776',
      );
      await clientRepo.saveClient(updatedClient);

      // 4. Verify draft invoice was automatically updated
      invoices = await invoiceRepo.getAllInvoices();
      expect(invoices.first.receiver.name, 'Updated Client Name Pvt Ltd');
      expect(invoices.first.receiver.address, '456 New Road, Suite 100');
      expect(invoices.first.receiver.phone, '9998887776');
    });

    test('Adding or editing default bank propagates to profile and draft invoices', () async {
      // 1. Create a draft invoice (inherits Old Bank from profile)
      final draftInvoice = model_inv.Invoice(
        id: 'inv_draft_bank',
        profileId: testProfileId,
        invoiceNo: 'INV-002',
        invoiceDate: DateTime.now(),
        supplier: const model_inv.Supplier(name: 'Acme Corp'),
        receiver: const model_inv.Receiver(name: 'Some Client'),
        bankName: 'Old Bank',
        accountNo: '11111',
        ifscCode: 'OLDB0001',
        branch: 'Old Branch',
      );
      await invoiceRepo.saveInvoice(draftInvoice);

      // 2. Save a new bank account as default
      const newBank = BankAccount(
        id: 'bank_hdfc',
        profileId: testProfileId,
        bankName: 'HDFC Bank',
        accountNo: '50100234567890',
        ifscCode: 'HDFC0001234',
        branch: 'Connaught Place',
        isDefault: true,
      );
      await bankRepo.saveBank(newBank);

      // 3. Verify business profile was synchronized with the new bank
      final profile = await profileRepo.getProfile(testProfileId);
      expect(profile?.bankName, 'HDFC Bank');
      expect(profile?.accountNo, '50100234567890');
      expect(profile?.ifscCode, 'HDFC0001234');
      expect(profile?.branch, 'Connaught Place');

      // 4. Verify draft invoice was updated with the new bank
      final invoices = await invoiceRepo.getAllInvoices();
      final targetInvoice = invoices.firstWhere((inv) => inv.id == 'inv_draft_bank');
      expect(targetInvoice.bankName, 'HDFC Bank');
      expect(targetInvoice.accountNo, '50100234567890');
      expect(targetInvoice.ifscCode, 'HDFC0001234');
      expect(targetInvoice.branch, 'Connaught Place');
    });
  });
}
