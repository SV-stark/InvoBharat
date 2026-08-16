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
    'Other',
  ];
  static const List<String> uqcs = [
    'NOS - Numbers',
    'PCS - Pieces',
    'KGS - Kilograms',
    'BOX - Box',
    'LTR - Litres',
    'MTR - Metres',
    'OTH - Others',
    'BAG - Bags',
    'BTL - Bottles',
    'CAN - Cans',
    'CTN - Cartons',
    'DOZ - Dozens',
    'PAC - Packs',
    'SET - Sets',
    'SQF - Square Feet',
    'SQM - Square Metres',
    'TBS - Tablets',
    'TON - Tonnes',
    'YDS - Yards',
  ];
}
