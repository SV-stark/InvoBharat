// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemTemplateImpl _$$ItemTemplateImplFromJson(Map<String, dynamic> json) =>
    _$ItemTemplateImpl(
      id: json['id'] as String,
      description: json['description'] as String,
      unit: json['unit'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 18.0,
      codeType: json['codeType'] as String? ?? 'SAC',
      sacCode: json['sacCode'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$ItemTemplateImplToJson(_$ItemTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'unit': instance.unit,
      'amount': instance.amount,
      'gstRate': instance.gstRate,
      'codeType': instance.codeType,
      'sacCode': instance.sacCode,
      'quantity': instance.quantity,
    };
