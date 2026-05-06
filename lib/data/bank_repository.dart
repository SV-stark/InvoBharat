import 'package:invobharat/models/bank_account.dart';

abstract class BankRepository {
  Future<void> saveBank(final BankAccount bank);
  Future<BankAccount?> getBank(final String id);
  Future<List<BankAccount>> getBanksByProfile(final String profileId);
  Future<void> deleteBank(final String id);
  Future<void> setDefaultBank(final String profileId, final String bankId);
}
