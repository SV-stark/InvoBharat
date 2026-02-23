String numberToWords(final double number) {
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
    "Nineteen"
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
    "Ninety"
  ];

  String convertLessThanOneThousand(final int n) {
    if (n == 0) return "";
    if (n < 20) {
      return units[n];
    } else if (n < 100) {
      return "${tens[n ~/ 10]} ${units[n % 10]}";
    } else {
      return "${units[n ~/ 100]} Hundred ${convertLessThanOneThousand(n % 100)}";
    }
  }

  // Indian Numbering System:
  // 10,00,00,000 (Ten Crores)
  // 1,00,00,000 (One Crore)
  // 10,00,000 (Ten Lakhs)
  // 1,00,000 (One Lakh)

  // Handling up to Crores for typical invoice needs
  final int integerPart = number.truncate();
  final int decimalPart = ((number - integerPart) * 100).round();

  String result = "";

  void convertPart(int n) {
    if (n >= 10000000) {
      result += "${convertLessThanOneThousand(n ~/ 10000000)} Crore ";
      n %= 10000000;
    }

    if (n >= 100000) {
      result += "${convertLessThanOneThousand(n ~/ 100000)} Lakh ";
      n %= 100000;
    }

    if (n >= 1000) {
      result += "${convertLessThanOneThousand(n ~/ 1000)} Thousand ";
      n %= 1000;
    }

    result += convertLessThanOneThousand(n);
  }

  convertPart(integerPart);

  if (result.isEmpty) result = "Zero";

  if (decimalPart > 0) {
    result += " and "; // Separator
    // Reset for decimal, but reuse logic?
    // convertLessThanOneThousand is scoped, but `result` is shared.
    // We need to append to result manually or reuse function carefully.
    // Actually `convertLessThanOneThousand` returns string, so we can use it directly.
    result += "${convertLessThanOneThousand(decimalPart)} Paise";
  }

  return result.trim().replaceAll(RegExp(r'\s+'), ' ');
}
