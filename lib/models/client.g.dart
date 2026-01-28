// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Client _$ClientFromJson(Map<String, dynamic> json) => _Client(
      id: json['id'] as String,
      name: json['name'] as String,
      profileId: json['profileId'] as String? ?? 'default',
      gstin: json['gstin'] as String? ?? '',
      address: json['address'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      primaryContact: json['primaryContact'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pan: json['pan'] as String? ?? '',
      stateCode: json['stateCode'] as String? ?? '',
    );

Map<String, dynamic> _$ClientToJson(_Client instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profileId': instance.profileId,
      'gstin': instance.gstin,
      'address': instance.address,
      'email': instance.email,
      'phone': instance.phone,
      'primaryContact': instance.primaryContact,
      'notes': instance.notes,
      'state': instance.state,
      'pan': instance.pan,
      'stateCode': instance.stateCode,
    };
