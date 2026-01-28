// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Estimate _$EstimateFromJson(Map<String, dynamic> json) => _Estimate(
      id: json['id'] as String,
      estimateNo: json['estimateNo'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      supplier: Supplier.fromJson(json['supplier'] as Map<String, dynamic>),
      receiver: Receiver.fromJson(json['receiver'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String? ?? '',
      terms: json['terms'] as String? ?? '',
      status: json['status'] as String? ?? 'Draft',
    );

Map<String, dynamic> _$EstimateToJson(_Estimate instance) => <String, dynamic>{
      'id': instance.id,
      'estimateNo': instance.estimateNo,
      'date': instance.date.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'supplier': instance.supplier,
      'receiver': instance.receiver,
      'items': instance.items,
      'notes': instance.notes,
      'terms': instance.terms,
      'status': instance.status,
    };
