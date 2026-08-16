import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/formatters.dart';

void main() {
  group('MobileNumberFormatter', () {
    final formatter = MobileNumberFormatter();

    test('strips non-digit characters', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '(987) 654-3210',
        selection: TextSelection.collapsed(offset: 14),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '9876543210');
    });

    test('preserves cursor offset during inline typing', () {
      const oldValue = TextEditingValue(
        text: '9876543210',
        selection: TextSelection.collapsed(offset: 4),
      );
      // User types '9' at offset 4: '98769543210' (11 digits, so rejected/truncated)
      const newValueOverLimit = TextEditingValue(
        text: '98769543210',
        selection: TextSelection.collapsed(offset: 5),
      );
      final overLimitResult = formatter.formatEditUpdate(oldValue, newValueOverLimit);
      expect(overLimitResult.text, '9876543210');

      // User edits inside an 8-digit number: '98764321' -> inserts '5' at offset 4 -> '987654321'
      const oldValue8 = TextEditingValue(
        text: '98764321',
        selection: TextSelection.collapsed(offset: 4),
      );
      const newValue9 = TextEditingValue(
        text: '987654321',
        selection: TextSelection.collapsed(offset: 5),
      );
      final result = formatter.formatEditUpdate(oldValue8, newValue9);
      expect(result.text, '987654321');
      expect(result.selection.baseOffset, 5);
    });
  });

  group('InvoDateTimeFormatter', () {
    test('fiscalYear calculates FY correctly', () {
      final aprilDate = DateTime(2025, 4);
      expect(aprilDate.fiscalYear(), 'FY 2025-26');

      final marchDate = DateTime(2026, 3, 31);
      expect(marchDate.fiscalYear(), 'FY 2025-26');
    });

    test('financialQuarter calculates quarters accurately', () {
      expect(DateTime(2025, 4, 15).financialQuarter(), 'Q1');
      expect(DateTime(2025, 8, 15).financialQuarter(), 'Q2');
      expect(DateTime(2025, 11, 15).financialQuarter(), 'Q3');
      expect(DateTime(2026, 1, 15).financialQuarter(), 'Q4');
    });
  });
}
