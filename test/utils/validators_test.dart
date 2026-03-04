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
      expect(Validators.phone('1234567890'), null);
      expect(Validators.phone('9876543210'), null);

      expect(Validators.phone('12345'), 'Phone number too short');
      expect(Validators.phone('123456789'), 'Phone number too short');
    });

    test('gstin should validate GSTIN formats correctly', () {
      expect(Validators.gstin(null), null);
      expect(Validators.gstin(''), null);
      // Valid Karnataka GSTIN
      expect(Validators.gstin('29AAAAA0000A1Z5'), null);
      // Valid format with mixed chars
      expect(Validators.gstin('07ABCDE1234F1Z0'), null);

      expect(Validators.gstin('123'), 'Invalid GSTIN format');
      expect(
        Validators.gstin('29AAAAA0000A1Z'),
        'Invalid GSTIN format',
      ); // Too short
      expect(
        Validators.gstin('29AAAAA0000A1Z55'),
        'Invalid GSTIN format',
      ); // Too long
      expect(
        Validators.gstin('29AAAAA0000A1A5'),
        'Invalid GSTIN format',
      ); // Should have Z at 14th pos
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

      expect(Validators.pan('12345ABCDE'), 'Invalid PAN format');
      expect(Validators.pan('ABCDE1234'), 'Invalid PAN format');
      expect(Validators.pan('ABCDE1234FG'), 'Invalid PAN format');
      expect(
        Validators.pan('abcd1234f'),
        'Invalid PAN format',
      ); // Case sensitive? Regex shows [A-Z]
    });
  });
}
