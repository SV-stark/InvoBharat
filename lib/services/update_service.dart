import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class Release {
  final String tagName;
  final String htmlUrl;
  final bool prerelease;
  final String? body;
  final String publishedAt;
  final List<ReleaseAsset> assets;

  Release({
    required this.tagName,
    required this.htmlUrl,
    required this.prerelease,
    this.body,
    required this.publishedAt,
    required this.assets,
  });

  factory Release.fromJson(final Map<String, dynamic> json) {
    return Release(
      tagName: json['tag_name'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      prerelease: json['prerelease'] ?? false,
      body: json['body'],
      publishedAt: json['published_at'] ?? '',
      assets: (json['assets'] as List? ?? [])
          .map((final a) => ReleaseAsset.fromJson(a))
          .toList(),
    );
  }

  DateTime get date => DateTime.parse(publishedAt);
}

class ReleaseAsset {
  final String name;
  final String browserDownloadUrl;

  ReleaseAsset({required this.name, required this.browserDownloadUrl});

  factory ReleaseAsset.fromJson(final Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] ?? '',
      browserDownloadUrl: json['browser_download_url'] ?? '',
    );
  }
}

class UpdateService {
  static const String _repoOwner = 'SV-stark';
  static const String _repoName = 'InvoBharat';

  static const String _cacheKey = 'update_service_cached_releases';
  static const String _cacheTimeKey = 'update_service_last_check_time';

  static Future<Map<String, Release?>> checkForUpdates({
    final http.Client? client,
    final bool forceRefresh = false,
  }) async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error getting SharedPreferences: $e');
    }

    final cachedReleasesStr = prefs?.getString(_cacheKey);
    final lastCheckTimeStr = prefs?.getString(_cacheTimeKey);

    if (!forceRefresh &&
        lastCheckTimeStr != null &&
        cachedReleasesStr != null) {
      try {
        final lastCheckTime = DateTime.parse(lastCheckTimeStr);
        if (DateTime.now().difference(lastCheckTime).inHours < 2) {
          final List<dynamic> jsonList = jsonDecode(cachedReleasesStr);
          final releases = jsonList
              .map((final json) => Release.fromJson(json))
              .toList();
          return _parseReleases(releases);
        }
      } catch (e) {
        debugPrint('Error parsing cached releases: $e');
      }
    }

    final shouldCloseClient = client == null;
    final httpClient = client ?? http.Client();
    http.Response? response;
    int attempt = 0;
    const int maxAttempts = 3;

    try {
      while (attempt < maxAttempts) {
        attempt++;
        try {
          response = await httpClient
              .get(
                Uri.parse(
                  'https://api.github.com/repos/$_repoOwner/$_repoName/releases',
                ),
                headers: {
                  'Accept': 'application/vnd.github+json',
                  'X-GitHub-Api-Version': '2022-11-28',
                  'User-Agent': 'InvoBharat-App',
                },
              )
              .timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            break;
          }
        } catch (e) {
          debugPrint('Update check attempt $attempt failed: $e');
        }

        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }

    if (response != null && response.statusCode == 200) {
      try {
        final body = response.body;
        if (prefs != null) {
          await prefs.setString(_cacheKey, body);
          await prefs.setString(
            _cacheTimeKey,
            DateTime.now().toIso8601String(),
          );
        }

        final List<dynamic> jsonList = jsonDecode(body);
        final releases = jsonList
            .map((final json) => Release.fromJson(json))
            .toList();
        return _parseReleases(releases);
      } catch (e) {
        debugPrint('Error decoding response: $e');
      }
    }

    // Fallback to cache on network failure
    if (cachedReleasesStr != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(cachedReleasesStr);
        final releases = jsonList
            .map((final json) => Release.fromJson(json))
            .toList();
        return _parseReleases(releases);
      } catch (e) {
        debugPrint('Error parsing cached releases on fallback: $e');
      }
    }

    return {'stable': null, 'nightly': null};
  }

  static Map<String, Release?> _parseReleases(final List<Release> releases) {
    Release? stableRelease;
    Release? nightlyRelease;

    try {
      stableRelease = releases.firstWhere((final r) => !r.prerelease);
    } catch (e) {
      // No stable release found
    }

    try {
      nightlyRelease = releases.firstWhere((final r) => r.prerelease);
    } catch (e) {
      // No nightly found
    }

    return {'stable': stableRelease, 'nightly': nightlyRelease};
  }

  static Future<void> downloadAndInstallUpdate(
    final Release release, {
    final http.Client? client,
    @visibleForTesting final Future<void> Function(String path)? startProcess,
  }) async {
    if (!Platform.isWindows &&
        !Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    final asset = release.assets.firstWhere(
      (final a) => a.name.endsWith('.exe') || a.name.endsWith('.msi'),
      orElse: () => throw Exception('No Windows installer found in release'),
    );

    final tempDir = await getTemporaryDirectory();
    final savePath = p.join(tempDir.path, asset.name);

    final shouldCloseClient = client == null;
    final httpClient = client ?? http.Client();
    try {
      final request = http.Request('GET', Uri.parse(asset.browserDownloadUrl));
      final streamedResponse = await httpClient.send(request);
      if (streamedResponse.statusCode == 200) {
        final file = File(savePath);
        final sink = file.openWrite();
        await streamedResponse.stream.pipe(sink);
        await sink.flush();
        await sink.close();

        // Check for checksum in assets or release body
        String? expectedChecksum;
        final checksumAsset = release.assets.cast<ReleaseAsset?>().firstWhere(
          (final a) =>
              a != null &&
              (a.name == '${asset.name}.sha256' ||
                  a.name == '${asset.name}.sha256sum' ||
                  a.name.endsWith('.sha256')),
          orElse: () => null,
        );

        if (checksumAsset != null) {
          final checksumRes = await httpClient.get(
            Uri.parse(checksumAsset.browserDownloadUrl),
          );
          if (checksumRes.statusCode == 200) {
            expectedChecksum = checksumRes.body
                .trim()
                .split(RegExp(r'\s+'))
                .first;
          }
        } else if (release.body != null) {
          final match = RegExp(
            r'sha256\s*[:=]\s*([a-f0-9]{64})',
            caseSensitive: false,
          ).firstMatch(release.body!);
          if (match != null) {
            expectedChecksum = match.group(1);
          }
        }

        if (expectedChecksum != null && expectedChecksum.isNotEmpty) {
          final fileBytes = await file.readAsBytes();
          final computedHash = crypto.sha256.convert(fileBytes).toString();
          if (computedHash.toLowerCase() != expectedChecksum.toLowerCase()) {
            if (await file.exists()) await file.delete();
            throw Exception(
              'Security Error: Installer checksum verification failed. Expected: $expectedChecksum, Actual: $computedHash',
            );
          }
        }

        // Run the installer
        if (startProcess != null) {
          await startProcess(savePath);
        } else {
          await Process.start(savePath, [], mode: ProcessStartMode.detached);
          exit(0); // Exit app to let installer run
        }
      } else {
        throw Exception(
          'Failed to download update: ${streamedResponse.statusCode}',
        );
      }
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }
}
