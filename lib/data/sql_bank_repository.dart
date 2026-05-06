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
    await database
        .into(database.bankAccounts)
        .insertOnConflictUpdate(
          BankAccountsCompanion(
            id: Value(bank.id.isEmpty ? const Uuid().v4() : bank.id),
            profileId: Value(bank.profileId),
            bankName: Value(bank.bankName),
            accountNo: Value(bank.accountNo),
            ifscCode: Value(bank.ifscCode),
            branch: Value(bank.branch),
            isDefault: Value(bank.isDefault),
          ),
        );
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
