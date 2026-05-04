// ignore_for_file: avoid_print
import 'package:indian_formatters/indian_formatters.dart';

void main() {
  final partialPan = 'ABCDE1234';
  String? validPan;
  for (int i = 0; i < 26; i++) {
    final char = String.fromCharCode(65 + i);
    final candidate = partialPan + char;
    if (IndianValidators.isPAN(candidate)) {
      validPan = candidate;
      break;
    }
  }
  print('Valid PAN: $validPan');

  final pan = 'ABCDE1234F';
  final states = {'29': 'Karnataka'};

  for (final entry in states.entries) {
    final stateCode = entry.key;
    final stateName = entry.value;
    final partial = '$stateCode${pan}1Z';

    String? validGstin;
    for (int i = 0; i < 36; i++) {
      final char = i < 10 ? i.toString() : String.fromCharCode(i - 10 + 65);
      final candidate = partial + char;
      if (IndianValidators.isGST(candidate)) {
        validGstin = candidate;
        break;
      }
    }
    print('$stateName ($stateCode): $validGstin');
  }
}
