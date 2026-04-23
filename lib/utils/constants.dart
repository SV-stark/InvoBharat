import 'package:indian_formatters/indian_formatters.dart' as ind;

class AppStates {
  static List<String> get states => 
      ind.IndianStates.all.map((final s) => s.name).toList();
}

class AppConstants {
  static const String gstRate = '18';
  static const List<String> paymentModes = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Cheque',
    'Other'
  ];
}
