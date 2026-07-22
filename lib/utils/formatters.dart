import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:indian_formatters/indian_formatters.dart';
import 'package:money2/money2.dart';

class CurrencyFormatter {
  static final _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  static String format(final double amount) {
    return _indianFormat.format(amount);
  }

  static Money toMoney(final double amount, [final String currencyCode = 'INR']) {
    final currency = Currencies().find(currencyCode) ?? CommonCurrencies().inr;
    return Money.fromNumWithCurrency(amount, currency);
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

  Money toMoney([final String currencyCode = 'INR']) {
    return CurrencyFormatter.toMoney(this, currencyCode);
  }

  String toIndianWords() {
    return IndianCurrencyFormatter.forCheque(this);
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
    return IndianCurrencyFormatter.forCheque(this);
  }
}
