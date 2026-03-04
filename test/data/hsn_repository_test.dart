import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/data/hsn_repository.dart';

void main() {
  group('HsnRepository', () {
    final repository = HsnRepository();

    test('search should return results for valid code', () async {
      final results = await repository.search('998314');
      expect(results.length, 1);
      expect(results.first.description.contains('IT'), true);
    });

    test('search should return results for valid description', () async {
      final results = await repository.search('Audit');
      expect(results.isNotEmpty, true);
      expect(
        results.any((final e) => e.description.toLowerCase().contains('audit')),
        true,
      );
    });

    test('search should be case insensitive', () async {
      final resultsLower = await repository.search('design');
      final resultsUpper = await repository.search('DESIGN');
      expect(resultsLower.length, resultsUpper.length);
      expect(resultsLower.isNotEmpty, true);
    });

    test('search should return empty for no match', () async {
      final results = await repository.search('NONEXISTENT');
      expect(results.isEmpty, true);
    });

    test('search should return empty for empty query', () async {
      final results = await repository.search('');
      expect(results.isEmpty, true);
    });
  });
}
