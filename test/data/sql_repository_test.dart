import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/data/sql_client_repository.dart';
import 'package:invobharat/data/sql_business_profile_repository.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/models/client.dart' as model;
import 'package:invobharat/models/business_profile.dart' as model;
import 'package:invobharat/models/invoice.dart' as model;
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase database;
  late SqlClientRepository clientRepo;
  late SqlBusinessProfileRepository profileRepo;
  late SqlInvoiceRepository invoiceRepo;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    clientRepo = SqlClientRepository(database);
    profileRepo = SqlBusinessProfileRepository(database);
    invoiceRepo = SqlInvoiceRepository(database, 'default');
  });

  tearDown(() async {
    await database.close();
  });

  group('SqlClientRepository', () {
    test('save and get client', () async {
      final client = model.Client(
        id: const Uuid().v4(),
        name: 'Test Client',
        email: 'client@test.com',
      );

      await clientRepo.saveClient(client);
      final retrieved = await clientRepo.getClient(client.id);

      expect(retrieved?.name, 'Test Client');
      expect(retrieved?.email, 'client@test.com');
    });

    test('delete client', () async {
      final id = const Uuid().v4();
      await clientRepo.saveClient(model.Client(id: id, name: 'Delete Me'));

      await clientRepo.deleteClient(id);
      final retrieved = await clientRepo.getClient(id);
      expect(retrieved, isNull);
    });
  });

  group('SqlBusinessProfileRepository', () {
    test('save and get profile', () async {
      final profile = model.BusinessProfile.defaults().copyWith(
        id: 'default',
        companyName: 'My Biz',
      );
      await profileRepo.saveProfile(profile);

      final retrieved = await profileRepo.getProfile('default');
      expect(retrieved?.companyName, 'My Biz');
    });
  });

  group('SqlInvoiceRepository', () {
    test('save and get invoice with items and payments', () async {
      await profileRepo.saveProfile(
        model.BusinessProfile.defaults().copyWith(id: 'default'),
      );
      const clientId = 'c1';
      await clientRepo.saveClient(
        const model.Client(id: clientId, name: 'Invoice Client'),
      );

      final invoice = model.Invoice(
        id: 'inv1',
        invoiceNo: 'INV-001',
        invoiceDate: DateTime.now(),
        supplier: const model.Supplier(name: 'Mock Supplier'),
        receiver: const model.Receiver(name: 'Invoice Client'),
        items: [
          const model.InvoiceItem(
            description: 'Item 1',
            amount: 100,
            quantity: 2,
          ),
        ],
      );

      await invoiceRepo.saveInvoice(invoice);

      final retrieved = await invoiceRepo.getInvoice('inv1');
      expect(retrieved?.invoiceNo, 'INV-001');
      expect(retrieved?.items.length, 1);
      expect(retrieved?.items.first.description, 'Item 1');
      expect(retrieved?.receiver.name, 'Invoice Client');
    });

    test('invoice sequence increment logic', () async {
      final profile = model.BusinessProfile.defaults().copyWith(
        id: 'default',
        invoiceSeries: 'INV-',
        invoiceSequence: 1,
      );
      await profileRepo.saveProfile(profile);

      final invoice = model.Invoice(
        invoiceNo: 'INV-001',
        invoiceDate: DateTime.now(),
        supplier: const model.Supplier(name: 'Mock Supplier'),
        receiver: const model.Receiver(name: 'Client'),
        items: [const model.InvoiceItem(amount: 10)],
      );

      await invoiceRepo.saveInvoice(invoice);

      final updatedProfile = await profileRepo.getProfile('default');
      expect(updatedProfile?.invoiceSequence, 2);
    });

    test('delete invoice should cleanup items and payments', () async {
      final invoice = model.Invoice(
        id: 'inv-to-delete',
        invoiceNo: 'DEL-001',
        invoiceDate: DateTime.now(),
        supplier: const model.Supplier(name: 'Mock Supplier'),
        receiver: const model.Receiver(name: 'Receiver'),
        items: [const model.InvoiceItem(amount: 10)],
      );

      await invoiceRepo.saveInvoice(invoice);
      await invoiceRepo.deleteInvoice('inv-to-delete');

      final retrieved = await invoiceRepo.getInvoice('inv-to-delete');
      expect(retrieved, isNull);

      final items = await database.select(database.invoiceItems).get();
      expect(items.any((final it) => it.invoiceId == 'inv-to-delete'), isFalse);
    });

    test('checkInvoiceExists functionality', () async {
      final invoice = model.Invoice(
        id: 'chk1',
        invoiceNo: 'CHK-001',
        invoiceDate: DateTime.now(),
        supplier: const model.Supplier(name: 'S'),
        receiver: const model.Receiver(name: 'R'),
        items: [],
      );
      await invoiceRepo.saveInvoice(invoice);

      expect(await invoiceRepo.checkInvoiceExists('CHK-001'), isTrue);
      expect(await invoiceRepo.checkInvoiceExists('CHK-002'), isFalse);
      expect(
        await invoiceRepo.checkInvoiceExists('CHK-001', excludeId: 'chk1'),
        isFalse,
      );
    });
  });
}
