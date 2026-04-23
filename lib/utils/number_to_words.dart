import 'package:indian_formatters/indian_formatters.dart';

String numberToWords(final double number) {
  if (number == 0) return "Zero";
  
  // indian_formatters provides forCheque which is perfect for "Rupees and Paise Only"
  // or formatWords for "Rupees and Paise".
  // The original implementation was returning "X Rupees and Y Paise".
  
  return IndianCurrencyFormatter.forCheque(number)
      .replaceAll('Only', '')
      .trim();
}
