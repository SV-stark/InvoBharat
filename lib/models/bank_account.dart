import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_account.freezed.dart';
part 'bank_account.g.dart';

@freezed
abstract class BankAccount with _$BankAccount {
  const factory BankAccount({
    required String id,
    required String profileId,
    required String bankName,
    required String accountNo,
    required String ifscCode,
    required String branch,
    @Default(false) bool isDefault,
  }) = _BankAccount;

  factory BankAccount.fromJson(final Map<String, dynamic> json) =>
      _$BankAccountFromJson(json);
}
