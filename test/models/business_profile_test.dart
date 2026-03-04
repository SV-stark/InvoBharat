import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/business_profile.dart';

void main() {
  group('BusinessProfile', () {
    test('should create a BusinessProfile with required fields', () {
      final profile = BusinessProfile(
        id: '123',
        companyName: 'Test Company',
        address: 'Test Address',
        gstin: '29AAAAA0000A1Z5',
        email: 'test@example.com',
        phone: '1234567890',
        state: 'Karnataka',
        pan: 'ABCDE1234F',
        colorValue: Colors.blue.toARGB32(),
      );

      expect(profile.id, '123');
      expect(profile.companyName, 'Test Company');
      expect(profile.address, 'Test Address');
      expect(profile.gstin, '29AAAAA0000A1Z5');
      expect(profile.email, 'test@example.com');
      expect(profile.phone, '1234567890');
      expect(profile.state, 'Karnataka');
      expect(profile.pan, 'ABCDE1234F');
      expect(profile.colorValue, Colors.blue.toARGB32());
      expect(profile.color.toARGB32(), Colors.blue.toARGB32());
      expect(profile.invoiceSeries, 'INV-');
      expect(profile.invoiceSequence, 1);
      expect(profile.currencySymbol, '₹');
    });

    test('defaults() should return a profile with default values', () {
      final profile = BusinessProfile.defaults();

      expect(profile.id, 'default');
      expect(profile.companyName, 'Your Company Name');
      expect(profile.state, 'Karnataka');
      expect(profile.colorValue, Colors.teal.toARGB32());
      expect(profile.invoiceSeries, 'INV-');
      expect(profile.invoiceSequence, 1);
    });

    test('toJson() should return a valid map', () {
      final profile = BusinessProfile(
        id: '123',
        companyName: 'Test Company',
        address: 'Test Address',
        gstin: 'GSTIN',
        email: 'email',
        phone: 'phone',
        state: 'state',
        pan: 'pan',
        colorValue: 100,
        upiId: 'upi@id',
        upiName: 'UPI Name',
      );

      final json = profile.toJson();

      expect(json['id'], '123');
      expect(json['companyName'], 'Test Company');
      expect(json['upiId'], 'upi@id');
      expect(json['upiName'], 'UPI Name');
    });

    test('fromJson() should create a profile from a valid map', () {
      final json = {
        'id': '123',
        'companyName': 'Test Company',
        'address': 'Test Address',
        'gstin': 'GSTIN',
        'email': 'email',
        'phone': 'phone',
        'state': 'state',
        'pan': 'pan',
        'colorValue': 100,
        'upiId': 'upi@id',
        'upiName': 'UPI Name',
      };

      final profile = BusinessProfile.fromJson(json);

      expect(profile.id, '123');
      expect(profile.companyName, 'Test Company');
      expect(profile.upiId, 'upi@id');
      expect(profile.upiName, 'UPI Name');
    });

    test('fromJson() should use default values for missing fields', () {
      final json = <String, dynamic>{};
      final profile = BusinessProfile.fromJson(json);

      expect(profile.id, 'default');
      expect(profile.invoiceSeries, 'INV-');
      expect(profile.invoiceSequence, 1);
      expect(profile.currencySymbol, '₹');
    });

    test('copyWith() should return a new instance with updated fields', () {
      final profile = BusinessProfile.defaults();
      final updatedProfile = profile.copyWith(
        companyName: 'Updated Name',
        invoiceSequence: 5,
      );

      expect(updatedProfile.companyName, 'Updated Name');
      expect(updatedProfile.invoiceSequence, 5);
      expect(updatedProfile.id, profile.id); // Should remain same
    });
  });
}
