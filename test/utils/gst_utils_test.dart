import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/gst_utils.dart';

void main() {
  group('GstUtils', () {
    test('isValidGstin should correctly validate GSTIN formats', () {
      expect(GstUtils.isValidGstin(''), true); // Optional field
      expect(GstUtils.isValidGstin('29AAAAA0000A1Z5'), true);
      expect(GstUtils.isValidGstin('29ABCDE1234F1Z5'), true);

      expect(GstUtils.isValidGstin('123'), false); // Too short
      expect(GstUtils.isValidGstin('29AAAAA0000A1Z'), false); // Too short
      expect(GstUtils.isValidGstin('29AAAAA0000A1Z55'), false); // Too long
      expect(
        GstUtils.isValidGstin('ZZAAAAA0000A1Z5'),
        false,
      ); // Invalid state code
    });

    test('getStateCode should return state code from valid GSTIN', () {
      expect(GstUtils.getStateCode('29ABCDE1234F1Z5'), '29');
      expect(GstUtils.getStateCode('07ABCDE1234F1Z5'), '07');
      expect(GstUtils.getStateCode('123'), null);
    });

    test('getPan should return PAN from valid GSTIN', () {
      expect(GstUtils.getPan('29ABCDE1234F1Z5'), 'ABCDE1234F');
      expect(GstUtils.getPan('07QWERT9999Q1Z0'), 'QWERT9999Q');
    });

    test('getStateName should return correct state name', () {
      expect(GstUtils.getStateName('29'), 'Karnataka');
      expect(GstUtils.getStateName('27'), 'Maharashtra');
      expect(GstUtils.getStateName('07'), 'Delhi');
      expect(GstUtils.getStateName('99'), 'Unknown State');
    });

    test('validate should return detailed result', () {
      final validResult = GstUtils.validate('29ABCDE1234F1Z5');
      expect(validResult.isValid, true);
      expect(validResult.stateCode, '29');
      expect(validResult.stateName, 'Karnataka');
      expect(validResult.pan, 'ABCDE1234F');

      final invalidResult = GstUtils.validate('123');
      expect(invalidResult.isValid, false);
      expect(invalidResult.errorMessage, 'GSTIN must be 15 characters');
    });
  });
}
