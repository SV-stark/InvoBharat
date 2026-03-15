import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:invobharat/services/update_service.dart';

void main() {
  group('UpdateService', () {
    test('checkForUpdates returns correct stable and beta releases', () async {
      final mockData = [
        {
          'tag_name': 'v1.1.0',
          'html_url': 'https://github.com/stable',
          'prerelease': false,
          'published_at': '2023-10-01',
        },
        {
          'tag_name': 'v1.2.0-beta',
          'html_url': 'https://github.com/beta',
          'prerelease': true,
          'published_at': '2023-11-01',
        },
      ];

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockData), 200);
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable']?.tagName, 'v1.1.0');
      expect(results['beta']?.tagName, 'v1.2.0-beta');
      expect(results['stable']?.prerelease, isFalse);
      expect(results['beta']?.prerelease, isTrue);
    });

    test('checkForUpdates handles empty results', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([]), 200);
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable'], isNull);
      expect(results['beta'], isNull);
    });

    test('checkForUpdates handles errors gracefully', () async {
      final client = MockClient((request) async {
        return http.Response('Error', 500);
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable'], isNull);
      expect(results['beta'], isNull);
    });

    test('checkForUpdates handles exception gracefully', () async {
      final client = MockClient((request) async {
        throw Exception('Network error');
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable'], isNull);
      expect(results['beta'], isNull);
    });
  });
}
