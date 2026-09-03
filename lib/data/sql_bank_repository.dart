import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/bank_account.dart' as model;
import 'package:invobharat/data/bank_repository.dart';

class SqlBankRepository implements BankRepository {
  final AppDatabase database;

  SqlBankRepository(this.database);

  @override
  Future<void> saveBank(final model.BankAccount bank) async {
    final bankId = bank.id.isEmpty ? const Uuid().v4() : bank.id;
    final existingBanks = await getBanksByProfile(bank.profileId);
    final shouldBeDefault = bank.isDefault || existingBanks.isEmpty;

    await database.transaction(() async {
      if (shouldBeDefault) {
        // Set existing banks to non-default
        await (database.update(database.bankAccounts)
              ..where((final tbl) => tbl.profileId.equals(bank.profileId)))
            .write(const BankAccountsCompanion(isDefault: Value(false)));
      }

      await database
          .into(database.bankAccounts)
          .insertOnConflictUpdate(
            BankAccountsCompanion(
              id: Value(bankId),
              profileId: Value(bank.profileId),
              bankName: Value(bank.bankName),
              accountNo: Value(bank.accountNo),
              ifscCode: Value(bank.ifscCode),
              branch: Value(bank.branch),
              isDefault: Value(shouldBeDefault),
            ),
          );

      if (shouldBeDefault) {
        // Synchronize to business_profiles so future invoices immediately inherit updated bank
        await (database.update(database.businessProfiles)
              ..where((final tbl) => tbl.id.equals(bank.profileId)))
            .write(
          BusinessProfilesCompanion(
            bankName: Value(bank.bankName),
            accountNo: Value(bank.accountNo),
            ifscCode: Value(bank.ifscCode),
            branch: Value(bank.branch),
          ),
        );

        // Propagate bank updates to draft invoices
        await (database.update(database.invoices)
              ..where((final tbl) =>
                  tbl.profileId.equals(bank.profileId) &
                  tbl.status.equals('Draft')))
            .write(
          InvoicesCompanion(
            bankName: Value(bank.bankName),
            accountNo: Value(bank.accountNo),
            ifscCode: Value(bank.ifscCode),
            branch: Value(bank.branch),
          ),
        );
      }
    });
  }

  @override
  Future<model.BankAccount?> getBank(final String id) async {
    final query = database.select(database.bankAccounts)
      ..where((final tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToBank(row);
  }

  @override
  Future<List<model.BankAccount>> getBanksByProfile(
    final String profileId,
  ) async {
    final query = database.select(database.bankAccounts)
      ..where((final tbl) => tbl.profileId.equals(profileId));
    final rows = await query.get();
    return rows.map(_mapRowToBank).toList();
  }

  @override
  Future<void> deleteBank(final String id) async {
    await (database.delete(
      database.bankAccounts,
    )..where((final tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> setDefaultBank(
    final String profileId,
    final String bankId,
  ) async {
    await database.transaction(() async {
      // 1. Set all for this profile to non-default
      await (database.update(database.bankAccounts)
            ..where((final tbl) => tbl.profileId.equals(profileId)))
          .write(const BankAccountsCompanion(isDefault: Value(false)));

      // 2. Set this one as default
      await (database.update(database.bankAccounts)
            ..where((final tbl) => tbl.id.equals(bankId)))
          .write(const BankAccountsCompanion(isDefault: Value(true)));

      // 3. Sync to business_profiles and draft invoices
      final bank = await (database.select(database.bankAccounts)
            ..where((final tbl) => tbl.id.equals(bankId)))
          .getSingleOrNull();
      if (bank != null) {
        await (database.update(database.businessProfiles)
              ..where((final tbl) => tbl.id.equals(profileId)))
            .write(
          BusinessProfilesCompanion(
            bankName: Value(bank.bankName),
            accountNo: Value(bank.accountNo),
            ifscCode: Value(bank.ifscCode),
            branch: Value(bank.branch),
          ),
        );

        await (database.update(database.invoices)
              ..where((final tbl) =>
                  tbl.profileId.equals(profileId) &
                  tbl.status.equals('Draft')))
            .write(
          InvoicesCompanion(
            bankName: Value(bank.bankName),
            accountNo: Value(bank.accountNo),
            ifscCode: Value(bank.ifscCode),
            branch: Value(bank.branch),
          ),
        );
      }
    });
  }

  model.BankAccount _mapRowToBank(final BankAccountData row) {
    return model.BankAccount(
      id: row.id,
      profileId: row.profileId,
      bankName: row.bankName,
      accountNo: row.accountNo,
      ifscCode: row.ifscCode,
      branch: row.branch,
      isDefault: row.isDefault,
    );
  }
}
