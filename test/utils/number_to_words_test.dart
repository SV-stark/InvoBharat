import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/number_to_words.dart';

void main() {
  group('numberToWords', () {
    test('should convert small numbers correctly', () {
      expect(numberToWords(0), 'Zero');
      expect(numberToWords(5), 'Five');
      expect(numberToWords(15), 'Fifteen');
      expect(numberToWords(42), 'Forty Two');
      expect(numberToWords(100), 'One Hundred');
      expect(numberToWords(105), 'One Hundred Five');
      expect(numberToWords(999), 'Nine Hundred Ninety Nine');
    });

    test('should convert thousands correctly', () {
      expect(numberToWords(1000), 'One Thousand');
      expect(numberToWords(1500), 'One Thousand Five Hundred');
      expect(numberToWords(10000), 'Ten Thousand');
      expect(
        numberToWords(99999),
        'Ninety Nine Thousand Nine Hundred Ninety Nine',
      );
    });

    test('should convert lakhs correctly', () {
      expect(numberToWords(100000), 'One Lakh');
      expect(numberToWords(150000), 'One Lakh Fifty Thousand');
      expect(
        numberToWords(9999999),
        'Ninety Nine Lakh Ninety Nine Thousand Nine Hundred Ninety Nine',
      );
    });

    test('should convert crores correctly', () {
      expect(numberToWords(10000000), 'One Crore');
      expect(numberToWords(100000000), 'Ten Crore');
    });

    test('should handle decimals correctly', () {
      expect(numberToWords(10.50), 'Ten and Fifty Paise');
      expect(
        numberToWords(100.05),
        'One Hundred and Five Paise',
      ); // .round() makes it 5
      expect(numberToWords(0.99), 'Zero and Ninety Nine Paise');
    });
  });
}
