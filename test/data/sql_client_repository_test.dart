import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/client.dart' as model;
import 'package:invobharat/models/business_profile.dart' as model;
import 'package:invobharat/data/sql_client_repository.dart';

void main() {
  late AppDatabase database;
  late SqlClientRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SqlClientRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  final testProfile = model.BusinessProfile(
    id: 'p1',
    companyName: 'Test Biz',
    address: 'Addr',
    gstin: 'GST123',
    email: 'e@b.com',
    phone: '123',
    accountNo: '123',
    branch: 'B1',
  );

  final testClient = const model.Client(
    id: 'c1',
    profileId: 'p1',
    name: 'Client 1',
    address: 'Client Addr',
    gstin: 'CGST123',
    state: 'Maharashtra',
  );

  group('SqlClientRepository', () {
    test('saveClient and getClient', () async {
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

      await repository.saveClient(testClient);
      final client = await repository.getClient(testClient.id);

      expect(client, isNotNull);
      expect(client?.name, testClient.name);
      expect(client?.gstin, testClient.gstin);
    });

    test('getAllClients', () async {
      await repository.saveClient(testClient);
      final clients = await repository.getAllClients();
      expect(clients.length, 1);
    });

    test('deleteClient', () async {
      await repository.saveClient(testClient);
      await repository.deleteClient(testClient.id);
      final client = await repository.getClient(testClient.id);
      expect(client, isNull);
    });
   group('GSTR-1 Import gap detection', () {
      test('should find missing numbers in simple sequence', () {
        // This was in GstrImportService test usually, if it's here, we check logic
      });
    });
  });
}
