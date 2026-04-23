import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/number_to_words.dart';

void main() {
  group('numberToWords', () {
    test('numberToWords should convert small numbers correctly', () {
      expect(numberToWords(0), 'Zero');
      expect(numberToWords(5), 'Five Rupees');
      expect(numberToWords(15), 'Fifteen Rupees');
      expect(numberToWords(99), 'Ninety-Nine Rupees');
    });

    test('numberToWords should convert thousands correctly', () {
      expect(numberToWords(100), 'One Hundred Rupees');
      expect(numberToWords(1000), 'One Thousand Rupees');
      expect(numberToWords(1234), 'One Thousand Two Hundred Thirty-Four Rupees');
    });

    test('numberToWords should convert lakhs correctly', () {
      expect(numberToWords(100000), 'One Lakh Rupees');
      expect(numberToWords(550000), 'Five Lakh Fifty Thousand Rupees');
    });

    test('numberToWords should convert crores correctly', () {
      expect(numberToWords(10000000), 'One Crore Rupees');
      expect(numberToWords(120000000), 'Twelve Crore Rupees');
    });

    test('numberToWords should handle decimals correctly', () {
      expect(numberToWords(10.50), 'Ten Rupees and Fifty Paise');
      expect(numberToWords(0.75), 'Zero Rupees and Seventy-Five Paise');
    });
  });
}
