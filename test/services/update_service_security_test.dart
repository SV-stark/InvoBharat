import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:invobharat/services/update_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getLibraryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;

  @override
  Future<List<String>?> getExternalCachePaths() async => [
    Directory.systemTemp.path,
  ];

  @override
  Future<List<String>?> getExternalStoragePaths({
    final StorageDirectory? type,
  }) async => [Directory.systemTemp.path];

  @override
  Future<String?> getDownloadsPath() async => Directory.systemTemp.path;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  group('UpdateService security and checksum checks', () {
    const validPayload = 'test payload';
    const validHash = '813ca5285c28ccee5cab8b10ebda9c908fd6d78ed9dc94cc65ea6cb67a7f13ae';

    test('ignores unrelated *.sha256 file and uses matching checksum', () async {
      // Release has unrelated linux.tar.gz.sha256 with bad hash, but body has the valid installer hash
      final release = Release(
        tagName: 'v1.2.0',
        htmlUrl: 'https://github.com/test',
        prerelease: false,
        publishedAt: '2024-01-01',
        body: 'SHA256: $validHash',
        assets: [
          ReleaseAsset(
            name: 'InvoBharat-Setup.exe',
            browserDownloadUrl: 'https://github.com/InvoBharat-Setup.exe',
          ),
          ReleaseAsset(
            name: 'other-tool-linux.tar.gz.sha256',
            browserDownloadUrl: 'https://github.com/other-tool.sha256',
          ),
        ],
      );

      final client = MockClient((final request) async {
        if (request.url.path.endsWith('.exe')) {
          return http.Response(validPayload, 200);
        }
        if (request.url.path.endsWith('.sha256')) {
          return http.Response('bogus_hash_for_other_platform', 200);
        }
        return http.Response('not found', 404);
      });

      String? executed;
      await UpdateService.downloadAndInstallUpdate(
        release,
        client: client,
        startProcess: (final p) async {
          executed = p;
        },
      );

      // Should succeed because unrelated .sha256 was correctly ignored
      expect(executed, isNotNull);
      final f = File(executed!);
      if (await f.exists()) await f.delete();
    });

    test('accepts exact asset.name.sha256 checksum file', () async {
      final release = Release(
        tagName: 'v1.2.0',
        htmlUrl: 'https://github.com/test',
        prerelease: false,
        publishedAt: '2024-01-01',
        assets: [
          ReleaseAsset(
            name: 'installer.exe',
            browserDownloadUrl: 'https://github.com/installer.exe',
          ),
          ReleaseAsset(
            name: 'installer.exe.sha256',
            browserDownloadUrl: 'https://github.com/installer.exe.sha256',
          ),
        ],
      );

      final client = MockClient((final request) async {
        if (request.url.path.endsWith('.exe')) {
          return http.Response(validPayload, 200);
        }
        if (request.url.path.endsWith('installer.exe.sha256')) {
          return http.Response('$validHash  installer.exe', 200);
        }
        return http.Response('not found', 404);
      });

      String? executed;
      await UpdateService.downloadAndInstallUpdate(
        release,
        client: client,
        startProcess: (final p) async {
          executed = p;
        },
      );

      expect(executed, isNotNull);
      final f = File(executed!);
      if (await f.exists()) await f.delete();
    });
  });
}
