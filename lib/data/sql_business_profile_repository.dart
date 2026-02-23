import 'package:drift/drift.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/business_profile.dart' as model;
import 'package:invobharat/data/business_profile_repository.dart';

class SqlBusinessProfileRepository implements BusinessProfileRepository {
  final AppDatabase database;

  SqlBusinessProfileRepository(this.database);

  @override
  Future<void> saveProfile(final model.BusinessProfile profile) async {
    await database
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
            currencySymbol: Value(profile.currencySymbol),
            bankName: Value(profile.bankName),
            accountNumber: Value(profile.accountNumber),
            ifscCode: Value(profile.ifscCode),
            branchName: Value(profile.branchName),
            upiId: Value(profile.upiId),
            upiName: Value(profile.upiName),
            pan: Value(profile.pan),
          ),
        );
  }

  @override
  Future<List<model.BusinessProfile>> getAllProfiles() async {
    final rows = await database.select(database.businessProfiles).get();
    return rows
        .map(
          (final row) => model.BusinessProfile(
            id: row.id,
            companyName: row.companyName,
            address: row.address,
            gstin: row.gstin,
            email: row.email,
            phone: row.phone,
            state: row.state,
            pan: row.pan,
            colorValue: row.colorValue,
            logoPath: row.logoPath,
            invoiceSeries: row.invoiceSeries,
            invoiceSequence: row.invoiceSequence,
            signaturePath: row.signaturePath,
            stampPath: row.stampPath,
            termsAndConditions: row.termsAndConditions,
            defaultNotes: row.defaultNotes,
            currencySymbol: row.currencySymbol,
            bankName: row.bankName,
            accountNumber: row.accountNumber,
            ifscCode: row.ifscCode,
            branchName: row.branchName,
            upiId: row.upiId,
            upiName: row.upiName,
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteProfile(final String id) async {
    await (database.delete(
      database.businessProfiles,
    )..where((final t) => t.id.equals(id))).go();
  }

  @override
  Future<model.BusinessProfile?> getProfile(final String id) async {
    final row = await (database.select(
      database.businessProfiles,
    )..where((final t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return model.BusinessProfile(
      id: row.id,
      companyName: row.companyName,
      address: row.address,
      gstin: row.gstin,
      email: row.email,
      phone: row.phone,
      state: row.state,
      pan: row.pan,
      colorValue: row.colorValue,
      logoPath: row.logoPath,
      invoiceSeries: row.invoiceSeries,
      invoiceSequence: row.invoiceSequence,
      signaturePath: row.signaturePath,
      stampPath: row.stampPath,
      termsAndConditions: row.termsAndConditions,
      defaultNotes: row.defaultNotes,
      currencySymbol: row.currencySymbol,
      bankName: row.bankName,
      accountNumber: row.accountNumber,
      ifscCode: row.ifscCode,
      branchName: row.branchName,
      upiId: row.upiId,
      upiName: row.upiName,
    );
  }
}
