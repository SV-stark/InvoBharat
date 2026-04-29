import 'package:indian_formatters/indian_formatters.dart';

void main() {
  const gstin = '02AAKAT7315E1ZP';
  const prefix = '02AAKAT7315E1Z';
  
  print('Is Valid: ${IndianValidators.isGST(gstin)}');
  print('Validation Error: ${IndianValidators.validateGST(gstin)}');
  print('Correct Checksum: ${IndianValidators.calculateGSTChecksum(prefix)}');
}
