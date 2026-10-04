import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'business_profile.freezed.dart';
part 'business_profile.g.dart';

@unfreezed
abstract class BusinessProfile with _$BusinessProfile {
  factory BusinessProfile({
    required String id,
    required String companyName,
    required String address,
    required String gstin,
    required String email,
    required String phone,
    @Default('') String state,
    @Default('') String pan,
    @Default('INV-') String invoiceSeries,
    @Default(1) int invoiceSequence,
    @Default('₹') String currency,
    @Default('') String termsAndConditions,
    @Default('') String defaultNotes,
    @Default('') String bankName,
    @Default('') String accountNo,
    @Default('') String ifscCode,
    @Default('') String branch,
    @Default('') String upiId,
    @Default('') String upiName,
    @Default('') String? logoPath,
    @Default('') String? signaturePath,
    @Default('') String? stampPath,
    @Default(0.0) double stampX,
    @Default(0.0) double stampY,
    @Default(0.0) double signatureX,
    @Default(0.0) double signatureY,
    @Default(0xFF009688) int colorValue,
  }) = _BusinessProfile;

  factory BusinessProfile.fromJson(final Map<String, dynamic> json) =>
      _$BusinessProfileFromJson(json);

  factory BusinessProfile.defaults() => BusinessProfile(
    id: 'default',
    companyName: 'Your Company Name',
    address: '',
    gstin: '',
    email: '',
    phone: '',
    colorValue: Colors.teal.toARGB32(),
  );
}

extension BusinessProfileExt on BusinessProfile {
  Color get color => Color(colorValue);
  String get currencySymbol => currency;
  // Aliases for compatibility
  String get accountNumber => accountNo;
  String get branchName => branch;
}
