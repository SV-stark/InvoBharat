import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/data/sql_business_profile_repository.dart';
import 'package:invobharat/models/business_profile.dart' as model;

void main() {
  late AppDatabase db;
  late SqlBusinessProfileRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = SqlBusinessProfileRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SqlBusinessProfileRepository', () {
    final testProfile = model.BusinessProfile(
      id: 'prof-1',
      companyName: 'Company 1',
      address: 'Addr 1',
      gstin: '29AAAAA0000A1Z5',
      email: 'a@b.com',
      phone: '123',
      state: 'State',
      pan: 'PAN',
      colorValue: 0,
    );

    test('saveProfile should insert or update profile', () async {
      await repository.saveProfile(testProfile);

      final profiles = await repository.getAllProfiles();
      expect(profiles.length, 1);
      expect(profiles.first.companyName, 'Company 1');

      final updated = testProfile.copyWith(companyName: 'Updated');
      await repository.saveProfile(updated);

      final secondCheck = await repository.getAllProfiles();
      expect(secondCheck.length, 1);
      expect(secondCheck.first.companyName, 'Updated');
    });

    test('getProfile should retrieve profile', () async {
      await repository.saveProfile(testProfile);
      final p = await repository.getProfile('prof-1');
      expect(p, isNotNull);
      expect(p!.companyName, 'Company 1');
    });

    test('deleteProfile should remove profile', () async {
      await repository.saveProfile(testProfile);
      await repository.deleteProfile('prof-1');
      expect(await repository.getProfile('prof-1'), isNull);
    });
  });
}
