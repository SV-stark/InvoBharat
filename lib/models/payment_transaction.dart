import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_transaction.freezed.dart';
part 'payment_transaction.g.dart';

@freezed
class PaymentTransaction with _$PaymentTransaction {
  const factory PaymentTransaction({
    required String id,
    required String invoiceId,
    required DateTime date,
    required double amount,
    required String
        paymentMode, // 'Cash', 'UPI', 'Bank Transfer', 'Cheque', 'Other'
    String? notes,
  }) = _PaymentTransaction;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionFromJson(json);
}
