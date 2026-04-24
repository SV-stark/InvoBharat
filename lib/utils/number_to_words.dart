import 'package:indian_formatters/indian_formatters.dart';

String numberToWords(final double number) {
  if (number == 0) return "Zero";
  
  // indian_formatters provides forCheque which is perfect for "Rupees and Paise Only"
  // It is the standard legal format for Indian invoices.
  
  return IndianCurrencyFormatter.forCheque(number);
}
