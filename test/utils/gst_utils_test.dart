import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/gst_utils.dart';

void main() {
  group('GstUtils', () {
    test('isValidGstin should correctly validate GSTIN formats', () {
      expect(GstUtils.isValidGstin(''), true); // Optional field
      // Using a real valid GSTIN for testing (with correct checksum T)
      expect(GstUtils.isValidGstin('27AAPFU0939F1ZT'), true);

      expect(GstUtils.isValidGstin('123'), false); // Too short
      expect(GstUtils.isValidGstin('27AAPFU0939F1Z'), false); // Too short
      expect(GstUtils.isValidGstin('27AAPFU0939F1ZVV'), false); // Too long
    });

    test('getStateCode should return state code from valid GSTIN', () {
      expect(GstUtils.getStateCode('27AAPFU0939F1ZT'), '27');
      expect(GstUtils.getStateCode('07AAPFU0939F1ZX'), '07');
      expect(GstUtils.getStateCode('123'), null);
    });

    test('getPan should return PAN from valid GSTIN', () {
      expect(GstUtils.getPan('27AAPFU0939F1ZT'), 'AAPFU0939F');
    });

    test('getStateName should return correct state name', () {
      expect(GstUtils.getStateName('29AAPFU0939F1ZR'), 'Karnataka');
      expect(GstUtils.getStateName('27AAPFU0939F1ZT'), 'Maharashtra');
      expect(GstUtils.getStateName('07AAPFU0939F1ZX'), 'Delhi');
    });

    test('validate should return detailed result', () {
      final validResult = GstUtils.validate('27AAPFU0939F1ZT');
      expect(validResult.isValid, true);
      expect(validResult.stateCode, '27');
      expect(validResult.stateName, 'Maharashtra');
      expect(validResult.pan, 'AAPFU0939F');

      final invalidResult = GstUtils.validate('123');
      expect(invalidResult.isValid, false);
      expect(invalidResult.errorMessage, 'Invalid GST number');
    });
  });
}
