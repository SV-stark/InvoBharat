import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/gst_utils.dart';

void main() {
  group('GstUtils tests', () {
    test('getStateName should return correct state name for valid prefixes', () {
      expect(GstUtils.getStateName('07AAAAA0000A1Z5'), 'Delhi');
      expect(GstUtils.getStateName('27AAAAA0000A1Z5'), 'Maharashtra');
      expect(GstUtils.getStateName('29AAAAA0000A1Z5'), 'Karnataka');
      expect(GstUtils.getStateName('33AAAAA0000A1Z5'), 'Tamil Nadu');
    });

    test('getStateName should return null for short or invalid prefixes', () {
      expect(GstUtils.getStateName('2'), null);
      expect(GstUtils.getStateName(''), null);
      expect(GstUtils.getStateName('00AAAAA0000A1Z5'), null);
    });

    test('isValidGstin should correctly validate GSTIN formats', () {
      expect(GstUtils.isValidGstin('27AAAAA0000A1Z5'), true);
      expect(GstUtils.isValidGstin('27AAAAA0000A1Z'), false);
      expect(GstUtils.isValidGstin(''), true);
      expect(GstUtils.isValidGstin('INVALID'), false);
    });
  });
}
