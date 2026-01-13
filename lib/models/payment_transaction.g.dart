// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentTransactionImpl _$$PaymentTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentTransactionImpl(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['paymentMode'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$PaymentTransactionImplToJson(
        _$PaymentTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'paymentMode': instance.paymentMode,
      'notes': instance.notes,
    };
