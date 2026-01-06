import 'package:flutter/material.dart';

class BusinessProfile {
  String companyName;
  String address;
  String gstin;
  String email;
  String phone;
  int colorValue; // Store Color as int
  String? logoPath;
  String invoiceSeries;
  int invoiceSequence;
  String? signaturePath;
  String termsAndConditions;
  String defaultNotes;
  String currencySymbol;

  BusinessProfile({
    required this.companyName,
    required this.address,
    required this.gstin,
    required this.email,
    required this.phone,
    required this.colorValue,
    this.logoPath,
    this.invoiceSeries = 'INV-',
    this.invoiceSequence = 1,
    this.signaturePath,
    this.termsAndConditions = '',
    this.defaultNotes = '',
    this.currencySymbol = '₹',
  });

  Color get color => Color(colorValue);

  factory BusinessProfile.defaults() {
    return BusinessProfile(
      companyName: "Your Company Name",
      address: "Your Business Address",
      gstin: "29XXXXX0000X0Z1",
      email: "email@example.com",
      phone: "9876543210",
      colorValue: Colors.teal.toARGB32(),
      invoiceSeries: "INV-",
      invoiceSequence: 1,
      termsAndConditions:
          "1. All disputes are subject to local jurisdiction.\n2. Interest @ 18% p.a. will be charged on delayed payment.",
      defaultNotes: "Thank you for your business!",
      currencySymbol: "₹",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'address': address,
      'gstin': gstin,
      'email': email,
      'phone': phone,
      'colorValue': colorValue,
      'logoPath': logoPath,
      'invoiceSeries': invoiceSeries,
      'invoiceSequence': invoiceSequence,
      'signaturePath': signaturePath,
      'termsAndConditions': termsAndConditions,
      'defaultNotes': defaultNotes,
      'currencySymbol': currencySymbol,
    };
  }

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      gstin: json['gstin'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      colorValue: json['colorValue'] ?? Colors.teal.toARGB32(),
      logoPath: json['logoPath'],
      invoiceSeries: json['invoiceSeries'] ?? 'INV-',
      invoiceSequence: json['invoiceSequence'] ?? 1,
      signaturePath: json['signaturePath'],
      termsAndConditions: json['termsAndConditions'] ?? '',
      defaultNotes: json['defaultNotes'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '₹',
    );
  }

  BusinessProfile copyWith({
    String? companyName,
    String? address,
    String? gstin,
    String? email,
    String? phone,
    int? colorValue,
    String? logoPath,
    String? invoiceSeries,
    int? invoiceSequence,
    String? signaturePath,
    String? termsAndConditions,
    String? defaultNotes,
    String? currencySymbol,
  }) {
    return BusinessProfile(
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      colorValue: colorValue ?? this.colorValue,
      logoPath: logoPath ?? this.logoPath,
      invoiceSeries: invoiceSeries ?? this.invoiceSeries,
      invoiceSequence: invoiceSequence ?? this.invoiceSequence,
      signaturePath: signaturePath ?? this.signaturePath,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}
