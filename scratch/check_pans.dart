import 'package:indian_formatters/indian_formatters.dart';

void main() {
  const pan1 = 'ABCDE1234F';
  const pan2 = 'ABCDE1234O';
  
  print('PAN 1 ($pan1) Valid: ${IndianValidators.isPAN(pan1)}');
  print('PAN 2 ($pan2) Valid: ${IndianValidators.isPAN(pan2)}');
}
