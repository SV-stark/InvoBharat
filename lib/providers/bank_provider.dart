import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/data/bank_repository.dart';
import 'package:invobharat/data/sql_bank_repository.dart';
import 'package:invobharat/models/bank_account.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/database_provider.dart';

final bankRepositoryProvider = Provider<BankRepository>((final ref) {
  final db = ref.watch(databaseProvider);
  return SqlBankRepository(db);
});

final bankListProvider =
    AsyncNotifierProvider<BankListNotifier, List<BankAccount>>(
      BankListNotifier.new,
    );

class BankListNotifier extends AsyncNotifier<List<BankAccount>> {
  @override
  Future<List<BankAccount>> build() async {
    final profile = ref.watch(businessProfileProvider);
    final repository = ref.watch(bankRepositoryProvider);
    return await repository.getBanksByProfile(profile.id);
  }

  Future<void> saveBank(final BankAccount bank) async {
    final repository = ref.read(bankRepositoryProvider);
    await repository.saveBank(bank);
    ref.invalidateSelf();
  }

  Future<void> deleteBank(final String id) async {
    final repository = ref.read(bankRepositoryProvider);
    await repository.deleteBank(id);
    ref.invalidateSelf();
  }

  Future<void> setDefaultBank(final String bankId) async {
    final profile = ref.read(businessProfileProvider);
    final repository = ref.read(bankRepositoryProvider);
    await repository.setDefaultBank(profile.id, bankId);
    ref.invalidateSelf();
  }
}
