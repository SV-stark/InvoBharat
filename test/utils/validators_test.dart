import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required should return message if value is null or empty', () {
      expect(Validators.required(null), 'Required');
      expect(Validators.required(''), 'Required');
      expect(Validators.required('  '), 'Required');
      expect(Validators.required('Value'), null);
      expect(Validators.required('', message: 'Custom'), 'Custom');
    });

    test('email should validate email formats correctly', () {
      expect(Validators.email(null), null);
      expect(Validators.email(''), null);
      expect(Validators.email('test@example.com'), null);
      expect(Validators.email('user.name+tag@domain.co.uk'), null);

      expect(Validators.email('invalid-email'), 'Invalid email address');
      expect(Validators.email('test@'), 'Invalid email address');
      expect(Validators.email('@example.com'), 'Invalid email address');
      expect(Validators.email('test@example'), 'Invalid email address');
    });

    test('phone should validate minimum length', () {
      expect(Validators.phone(null), null);
      expect(Validators.phone(''), null);
      expect(Validators.phone('9876543210'), null);

      expect(
        Validators.phone('12345'),
        'Invalid mobile number',
      );
      expect(
        Validators.phone('123456789'),
        'Invalid mobile number',
      );
    });

    test('gstin should validate GSTIN formats correctly', () {
      expect(Validators.gstin(null), null);
      expect(Validators.gstin(''), null);
      // Valid Maharashtra GSTIN
      expect(Validators.gstin('27AAPFU0939F1ZV'), null);

      expect(
        Validators.gstin('123'),
        'Invalid GST number',
      );
      expect(
        Validators.gstin('27AAPFU0939F1Z'),
        'Invalid GST number',
      ); // Too short
    });

    test('doubleValue should validate numeric inputs', () {
      expect(Validators.doubleValue(null), null);
      expect(Validators.doubleValue(''), null);
      expect(Validators.doubleValue('10.5'), null);
      expect(Validators.doubleValue('100'), null);
      expect(Validators.doubleValue('0'), null);

      expect(Validators.doubleValue('abc'), 'Invalid number');
      expect(Validators.doubleValue('-5.5'), 'Must be positive');
      expect(Validators.doubleValue('1,000'), 'Invalid number');
    });

    test('pan should validate PAN formats correctly', () {
      expect(Validators.pan(null), null);
      expect(Validators.pan(''), null);
      expect(Validators.pan('ABCDE1234F'), null);

      expect(
        Validators.pan('12345ABCDE'),
        'Invalid PAN number',
      );
      expect(
        Validators.pan('ABCDE1234'),
        'Invalid PAN number',
      );
    });

    test('aadhaar should validate correctly', () {
      expect(Validators.aadhaar(null), null);
      expect(Validators.aadhaar(''), null);
      // Valid Aadhaar requires Verhoeff check, using a known valid-format one is hard, 
      // but let's test invalid one.
      expect(Validators.aadhaar('123456789012'), 'Invalid Aadhaar number');
    });
  });
}
