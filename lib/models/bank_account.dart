import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_account.freezed.dart';
part 'bank_account.g.dart';

@freezed
abstract class BankAccount with _$BankAccount {
  const factory BankAccount({
    required final String id,
    required final String profileId,
    required final String bankName,
    required final String accountNo,
    required final String ifscCode,
    required final String branch,
    @Default(false) final bool isDefault,
  }) = _BankAccount;

  factory BankAccount.fromJson(final Map<String, dynamic> json) =>
      _$BankAccountFromJson(json);
}
