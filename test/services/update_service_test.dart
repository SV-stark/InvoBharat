import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:invobharat/services/update_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
  });

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

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: mockData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final results = await UpdateService.checkForUpdates(dio: mockDio);

      expect(results['stable']?.tagName, 'v1.1.0');
      expect(results['beta']?.tagName, 'v1.2.0-beta');
      expect(results['stable']?.prerelease, isFalse);
      expect(results['beta']?.prerelease, isTrue);
    });

    test('checkForUpdates handles empty results', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final results = await UpdateService.checkForUpdates(dio: mockDio);

      expect(results['stable'], isNull);
      expect(results['beta'], isNull);
    });

    test('checkForUpdates handles errors gracefully', () async {
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final results = await UpdateService.checkForUpdates(dio: mockDio);

      expect(results['stable'], isNull);
      expect(results['beta'], isNull);
    });
  });
}
