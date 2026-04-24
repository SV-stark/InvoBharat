import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/number_to_words.dart';

void main() {
  group('numberToWords', () {
    test('numberToWords should convert small numbers correctly', () {
      expect(numberToWords(0), 'Zero');
      expect(numberToWords(5), 'Five Rupees Only');
      expect(numberToWords(15), 'Fifteen Rupees Only');
      expect(numberToWords(99), 'Ninety-Nine Rupees Only');
    });

    test('numberToWords should convert thousands correctly', () {
      expect(numberToWords(100), 'One Hundred Rupees Only');
      expect(numberToWords(1000), 'One Thousand Rupees Only');
      expect(numberToWords(1234), 'One Thousand Two Hundred Thirty-Four Rupees Only');
    });

    test('numberToWords should convert lakhs correctly', () {
      expect(numberToWords(100000), 'One Lakh Rupees Only');
      expect(numberToWords(550000), 'Five Lakh Fifty Thousand Rupees Only');
    });

    test('numberToWords should convert crores correctly', () {
      expect(numberToWords(10000000), 'One Crore Rupees Only');
      expect(numberToWords(120000000), 'Twelve Crore Rupees Only');
    });

    test('numberToWords should handle decimals correctly', () {
      expect(numberToWords(10.50), 'Ten Rupees and Fifty Paise Only');
      expect(numberToWords(0.75), 'Zero Rupees and Seventy-Five Paise Only');
    });
  });
}
