import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/data/sql_client_repository.dart';
import 'package:invobharat/models/client.dart' as model;

void main() {
  late AppDatabase db;
  late SqlClientRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = SqlClientRepository(db);

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
  });

  tearDown(() async {
    await db.close();
  });

  group('SqlClientRepository', () {
    final testClient = const model.Client(
      id: 'client-1',
      name: 'Test Client',
      address: 'Client Address',
      gstin: '27BBBBB1111B1Z0',
      pan: 'BBBBB1111B',
      state: 'Maharashtra',
      stateCode: '27',
      email: 'client@example.com',
      phone: '9876543210',
    );

    test('saveClient should insert or update client', () async {
      await repository.saveClient(testClient);

      final clients = await db.select(db.clients).get();
      expect(clients.length, 1);
      expect(clients.first.name, 'Test Client');

      // Update
      final updated = testClient.copyWith(name: 'Updated Name');
      await repository.saveClient(updated);

      final updatedClients = await db.select(db.clients).get();
      expect(updatedClients.length, 1);
      expect(updatedClients.first.name, 'Updated Name');
    });

    test('getClient should retrieve client', () async {
      await repository.saveClient(testClient);

      final retrieved = await repository.getClient('client-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Client');
    });

    test('getAllClients should return all', () async {
      await repository.saveClient(
        testClient.copyWith(id: '1', name: 'Client 1'),
      );
      await repository.saveClient(
        testClient.copyWith(id: '2', name: 'Client 2'),
      );

      final all = await repository.getAllClients();
      expect(all.length, 2);
    });

    test('deleteClient should remove client', () async {
      await repository.saveClient(testClient);
      await repository.deleteClient('client-1');

      final retrieved = await repository.getClient('client-1');
      expect(retrieved, isNull);
    });
  });
}
