import 'package:drift/drift.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/business_profile.dart' as model;
import 'package:invobharat/data/business_profile_repository.dart';

class SqlBusinessProfileRepository implements BusinessProfileRepository {
  final AppDatabase database;

  SqlBusinessProfileRepository(this.database);

  @override
  Future<List<model.BusinessProfile>> getAllProfiles() async {
    final rows = await database.select(database.businessProfiles).get();
    return rows.map((final row) => _mapRowToModel(row)).toList();
  }

  @override
  Future<model.BusinessProfile?> getProfile(final String id) async {
    final query = database.select(database.businessProfiles)
      ..where((final t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _mapRowToModel(row) : null;
  }

  model.BusinessProfile _mapRowToModel(final dynamic row) {
    return model.BusinessProfile(
      id: row.id,
      companyName: row.companyName,
      address: row.address,
      gstin: row.gstin,
      email: row.email,
      phone: row.phone,
      state: row.state,
      colorValue: row.colorValue,
      logoPath: row.logoPath,
      invoiceSeries: row.invoiceSeries,
      invoiceSequence: row.invoiceSequence,
      signaturePath: row.signaturePath,
      stampPath: row.stampPath,
      termsAndConditions: row.termsAndConditions,
      defaultNotes: row.defaultNotes,
      currency: row.currencySymbol,
      bankName: row.bankName,
      accountNo: row.accountNo,
      ifscCode: row.ifscCode,
      branch: row.branch,
      upiId: row.upiId,
      upiName: row.upiName,
      pan: row.pan,
      stampX: row.stampX,
      stampY: row.stampY,
      signatureX: row.signatureX,
      signatureY: row.signatureY,
    );
  }

  @override
  Future<int> saveProfile(final model.BusinessProfile profile) async {
    return await database
        .into(database.businessProfiles)
        .insertOnConflictUpdate(
          BusinessProfilesCompanion(
            id: Value(profile.id),
            companyName: Value(profile.companyName),
            address: Value(profile.address),
            gstin: Value(profile.gstin),
            email: Value(profile.email),
            phone: Value(profile.phone),
            state: Value(profile.state),
            colorValue: Value(profile.colorValue),
            logoPath: Value(profile.logoPath),
            invoiceSeries: Value(profile.invoiceSeries),
            invoiceSequence: Value(profile.invoiceSequence),
            signaturePath: Value(profile.signaturePath),
            stampPath: Value(profile.stampPath),
            termsAndConditions: Value(profile.termsAndConditions),
            defaultNotes: Value(profile.defaultNotes),
            currencySymbol: Value(profile.currency),
            bankName: Value(profile.bankName),
            accountNo: Value(profile.accountNo),
            ifscCode: Value(profile.ifscCode),
            branch: Value(profile.branch),
            upiId: Value(profile.upiId),
            upiName: Value(profile.upiName),
            pan: Value(profile.pan),
            stampX: Value(profile.stampX),
            stampY: Value(profile.stampY),
            signatureX: Value(profile.signatureX),
            signatureY: Value(profile.signatureY),
          ),
        );
  }

  @override
  Future<void> deleteProfile(final String id) async {
    await (database.delete(database.businessProfiles)
          ..where((final t) => t.id.equals(id)))
        .go();
  }

}
