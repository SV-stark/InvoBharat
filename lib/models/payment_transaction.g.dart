// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentTransaction _$PaymentTransactionFromJson(Map<String, dynamic> json) =>
    _PaymentTransaction(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['paymentMode'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PaymentTransactionToJson(_PaymentTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'paymentMode': instance.paymentMode,
      'notes': instance.notes,
    };
