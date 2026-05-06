import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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

  static Future<Map<String, Release?>> checkForUpdates({
    final http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        Uri.parse(
          'https://api.github.com/repos/$_repoOwner/$_repoName/releases',
        ),
        headers: {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'User-Agent': 'InvoBharat-App',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final releases =
            jsonList.map((final json) => Release.fromJson(json)).toList();

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
      } else {
        throw Exception('Failed to load releases: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return {'stable': null, 'nightly': null};
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  static Future<void> downloadAndInstallUpdate(final Release release) async {
    if (!Platform.isWindows) return;

    final asset = release.assets.firstWhere(
      (final a) => a.name.endsWith('.exe') || a.name.endsWith('.msi'),
      orElse: () => throw Exception('No Windows installer found in release'),
    );

    final tempDir = await getTemporaryDirectory();
    final savePath = '${tempDir.path}/${asset.name}';

    final response = await http.get(Uri.parse(asset.browserDownloadUrl));
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);

      // Run the installer
      await Process.start(savePath, [], mode: ProcessStartMode.detached);
      exit(0); // Exit app to let installer run
    } else {
      throw Exception('Failed to download update: ${response.statusCode}');
    }
  }
}
