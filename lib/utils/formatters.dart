import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  static String format(final double amount) {
    return _indianFormat.format(amount);
  }
}

extension DoubleFormatter on double {
  String toIndianFormat({
    final bool includeSymbol = false,
    final String symbol = '₹',
  }) {
    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: includeSymbol ? '$symbol ' : '',
      decimalDigits: 2,
    );
    return fmt.format(this);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    final TextEditingValue oldValue,
    final TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class MobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    final TextEditingValue oldValue,
    final TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 10) return oldValue;

    // We could add spaces like "99999 88888" but let's keep it simple for now
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// We can add more if needed, but for now these cover basic needs.
typedef GSTNumberFormatter = UpperCaseTextFormatter;
typedef PANNumberFormatter = UpperCaseTextFormatter;

extension InvoDateTimeFormatter on DateTime {
  String fiscalYear() {
    final int startYear = month >= 4 ? year : year - 1;
    final int endYear = startYear + 1;
    return "FY $startYear-${endYear.toString().substring(2)}";
  }

  String financialQuarter() {
    if (month >= 4 && month <= 6) return "Q1";
    if (month >= 7 && month <= 9) return "Q2";
    if (month >= 10 && month <= 12) return "Q3";
    return "Q4";
  }
}

extension DoubleToWords on double {
  String toChequeFormat() {
    if (this == 0) return "Zero Rupees Only";

    final int totalAmount = truncate();
    final int paise = ((this - totalAmount) * 100).round();

    String result = "${_convertNumberToWords(totalAmount)} Rupees";
    if (paise > 0) {
      result += " and ${_convertNumberToWords(paise)} Paise";
    }
    return "$result Only";
  }

  static String _convertNumberToWords(int number) {
    if (number == 0) return "Zero";

    final units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen",
    ];
    final tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety",
    ];

    String words = "";

    if ((number / 10000000).truncate() > 0) {
      words +=
          "${_convertNumberToWords((number / 10000000).truncate())} Crore ";
      number %= 10000000;
    }

    if ((number / 100000).truncate() > 0) {
      words += "${_convertNumberToWords((number / 100000).truncate())} Lakh ";
      number %= 100000;
    }

    if ((number / 1000).truncate() > 0) {
      words += "${_convertNumberToWords((number / 1000).truncate())} Thousand ";
      number %= 1000;
    }

    if ((number / 100).truncate() > 0) {
      words += "${_convertNumberToWords((number / 100).truncate())} Hundred ";
      number %= 100;
    }

    if (number > 0) {
      if (words != "") words += "and ";
      if (number < 20) {
        words += units[number];
      } else {
        words += tens[(number / 10).truncate()];
        if ((number % 10) > 0) words += "-${units[number % 10]}";
      }
    }

    return words.trim();
  }
}
