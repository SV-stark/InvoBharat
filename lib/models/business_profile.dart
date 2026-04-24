import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'business_profile.freezed.dart';
part 'business_profile.g.dart';

@unfreezed
abstract class BusinessProfile with _$BusinessProfile {
  factory BusinessProfile({
    required final String id,
    required final String companyName,
    required final String address,
    required final String gstin,
    required final String email,
    required final String phone,
    @Default('') final String state,
    @Default('') final String pan,
    @Default('INV-') final String invoiceSeries,
    @Default(1) final int invoiceSequence,
    @Default('₹') final String currency,
    @Default('') final String termsAndConditions,
    @Default('') final String defaultNotes,
    @Default('') final String bankName,
    @Default('') final String accountNo,
    @Default('') final String ifscCode,
    @Default('') final String branch,
    @Default('') final String upiId,
    @Default('') final String upiName,
    @Default('') final String? logoPath,
    @Default('') final String? signaturePath,
    @Default('') final String? stampPath,
    @Default(0.0) final double stampX,
    @Default(0.0) final double stampY,
    @Default(0.0) final double signatureX,
    @Default(0.0) final double signatureY,
    @Default(0xFF009688) final int colorValue,
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
