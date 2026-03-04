import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/gst_helper.dart';

void main() {
  group('GstUtils (Helper)', () {
    test('getStateName should return correct state from GSTIN prefix', () {
      expect(GstUtils.getStateName('29AAAAA0000A1Z5'), 'Karnataka');
      expect(GstUtils.getStateName('27AAAAA0000A1Z5'), 'Maharashtra');
      expect(GstUtils.getStateName('07AAAAA0000A1Z5'), 'Delhi');
      expect(GstUtils.getStateName('99AAAAA0000A1Z5'), 'Centre Jurisdiction');
    });

    test('getStateName should return null for short or invalid prefixes', () {
      expect(GstUtils.getStateName('2'), null);
      expect(GstUtils.getStateName(''), null);
      expect(GstUtils.getStateName('00AAAAA0000A1Z5'), null);
    });

    test('stateMap should contain expected major states', () {
      expect(GstUtils.stateMap['29'], 'Karnataka');
      expect(GstUtils.stateMap['27'], 'Maharashtra');
      expect(GstUtils.stateMap['07'], 'Delhi');
      expect(GstUtils.stateMap['33'], 'Tamil Nadu');
    });
  });
}
