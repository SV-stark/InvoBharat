import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:invobharat/services/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getLibraryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;

  @override
  Future<List<String>?> getExternalCachePaths() async => [Directory.systemTemp.path];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => [Directory.systemTemp.path];

  @override
  Future<String?> getDownloadsPath() async => Directory.systemTemp.path;
}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

      final client = MockClient((final request) async {
        return http.Response(jsonEncode(mockData), 200);
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable']?.tagName, 'v1.1.0');
      expect(results['nightly']?.tagName, 'v1.2.0-beta');
      expect(results['stable']?.prerelease, isFalse);
      expect(results['nightly']?.prerelease, isTrue);
    });

    test('checkForUpdates handles empty results', () async {
      final client = MockClient((final request) async {
        return http.Response(jsonEncode([]), 200);
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable'], isNull);
      expect(results['nightly'], isNull);
    });

    test('checkForUpdates handles errors gracefully', () async {
      final client = MockClient((final request) async {
        return http.Response('Error', 500);
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable'], isNull);
      expect(results['nightly'], isNull);
    });

    test('checkForUpdates handles exception gracefully', () async {
      final client = MockClient((final request) async {
        throw Exception('Network error');
      });

      final results = await UpdateService.checkForUpdates(client: client);

      expect(results['stable'], isNull);
      expect(results['nightly'], isNull);
    });

    test('downloadAndInstallUpdate throws exception if no Windows installer is found', () async {
      final release = Release(
        tagName: 'v1.1.0',
        htmlUrl: 'https://github.com/stable',
        prerelease: false,
        publishedAt: '2023-10-01',
        assets: [
          ReleaseAsset(name: 'source_code.zip', browserDownloadUrl: 'https://github.com/zip'),
        ],
      );

      final client = MockClient((final request) async {
        return http.Response('OK', 200);
      });

      expect(
        () => UpdateService.downloadAndInstallUpdate(release, client: client),
        throwsA(isA<Exception>().having((final e) => e.toString(), 'message', contains('No Windows installer found in release'))),
      );
    });

    test('downloadAndInstallUpdate throws exception if download fails', () async {
      final release = Release(
        tagName: 'v1.1.0',
        htmlUrl: 'https://github.com/stable',
        prerelease: false,
        publishedAt: '2023-10-01',
        assets: [
          ReleaseAsset(name: 'installer.exe', browserDownloadUrl: 'https://github.com/installer.exe'),
        ],
      );

      final client = MockClient((final request) async {
        return http.Response('Not Found', 404);
      });

      expect(
        () => UpdateService.downloadAndInstallUpdate(release, client: client),
        throwsA(isA<Exception>().having((final e) => e.toString(), 'message', contains('Failed to download update: 404'))),
      );
    });

    test('downloadAndInstallUpdate successfully downloads and calls startProcess', () async {
      final release = Release(
        tagName: 'v1.1.0',
        htmlUrl: 'https://github.com/stable',
        prerelease: false,
        publishedAt: '2023-10-01',
        assets: [
          ReleaseAsset(name: 'installer.exe', browserDownloadUrl: 'https://github.com/installer.exe'),
        ],
      );

      final client = MockClient((final request) async {
        return http.Response('binary payload', 200);
      });

      String? executedPath;
      await UpdateService.downloadAndInstallUpdate(
        release,
        client: client,
        startProcess: (final path) async {
          executedPath = path;
        },
      );

      expect(executedPath, isNotNull);
      expect(executedPath, endsWith('installer.exe'));
      
      final downloadedFile = File(executedPath!);
      expect(await downloadedFile.exists(), isTrue);
      expect(await downloadedFile.readAsString(), 'binary payload');

      // Cleanup
      await downloadedFile.delete();
    });
  });
}
