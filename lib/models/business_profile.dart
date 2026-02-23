import 'package:flutter/material.dart';

class BusinessProfile {
  String id;
  String companyName;
  String address;
  String gstin;
  String email;
  String phone;
  String state;
  String pan;
  int colorValue; // Store Color as int
  String? logoPath;
  String invoiceSeries;
  int invoiceSequence;
  String? signaturePath;
  String? stampPath;
  String termsAndConditions;
  String defaultNotes;
  String currencySymbol;

  // Bank Details
  String bankName;
  String accountNumber;
  String ifscCode;
  String branchName;

  // UPI
  String? upiId;
  String? upiName;

  BusinessProfile({
    required this.id,
    required this.companyName,
    required this.address,
    required this.gstin,
    required this.email,
    required this.phone,
    required this.state,
    required this.pan,
    required this.colorValue,
    this.logoPath,
    this.invoiceSeries = 'INV-',
    this.invoiceSequence = 1,
    this.signaturePath,
    this.stampPath,
    this.termsAndConditions = '',
    this.defaultNotes = '',
    this.currencySymbol = '₹',
    this.bankName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.branchName = '',
    this.upiId,
    this.upiName,
  });

  Color get color => Color(colorValue);

  factory BusinessProfile.defaults() {
    return BusinessProfile(
      id: "default", // Will be replaced by UUID for new profiles usually
      companyName: "Your Company Name",
      address: "",
      gstin: "",
      email: "",
      phone: "",
      state: "Karnataka",
      pan: "",
      colorValue: Colors.teal.toARGB32(),
      termsAndConditions:
          "1. All disputes are subject to local jurisdiction.\n2. Interest @ 18% p.a. will be charged on delayed payment.",
      defaultNotes: "Thank you for your business!",
      upiId: "",
      upiName: "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'address': address,
      'gstin': gstin,
      'email': email,
      'phone': phone,
      'state': state,
      'pan': pan,
      'colorValue': colorValue,
      'logoPath': logoPath,
      'invoiceSeries': invoiceSeries,
      'invoiceSequence': invoiceSequence,
      'signaturePath': signaturePath,
      'stampPath': stampPath,
      'termsAndConditions': termsAndConditions,
      'defaultNotes': defaultNotes,
      'currencySymbol': currencySymbol,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'upiId': upiId,
      'upiName': upiName,
    };
  }

  factory BusinessProfile.fromJson(final Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'] ?? 'default', // Backward compatibility
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      gstin: json['gstin'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
      pan: json['pan'] ?? '',
      colorValue: json['colorValue'] ?? Colors.teal.toARGB32(),
      logoPath: json['logoPath'],
      invoiceSeries: json['invoiceSeries'] ?? 'INV-',
      invoiceSequence: json['invoiceSequence'] ?? 1,
      signaturePath: json['signaturePath'],
      stampPath: json['stampPath'],
      termsAndConditions: json['termsAndConditions'] ?? '',
      defaultNotes: json['defaultNotes'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '₹',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      branchName: json['branchName'] ?? '',
      upiId: json['upiId'],
      upiName: json['upiName'],
    );
  }

  BusinessProfile copyWith({
    final String? id,
    final String? companyName,
    final String? address,
    final String? gstin,
    final String? email,
    final String? phone,
    final String? state,
    final String? pan,
    final int? colorValue,
    final String? logoPath,
    final String? invoiceSeries,
    final int? invoiceSequence,
    final String? signaturePath,
    final String? stampPath,
    final String? termsAndConditions,
    final String? defaultNotes,
    final String? currencySymbol,
    final String? bankName,
    final String? accountNumber,
    final String? ifscCode,
    final String? branchName,
    final String? upiId,
    final String? upiName,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      pan: pan ?? this.pan,
      colorValue: colorValue ?? this.colorValue,
      logoPath: logoPath ?? this.logoPath,
      invoiceSeries: invoiceSeries ?? this.invoiceSeries,
      invoiceSequence: invoiceSequence ?? this.invoiceSequence,
      signaturePath: signaturePath ?? this.signaturePath,
      stampPath: stampPath ?? this.stampPath,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      upiId: upiId ?? this.upiId,
      upiName: upiName ?? this.upiName,
    );
  }
}
