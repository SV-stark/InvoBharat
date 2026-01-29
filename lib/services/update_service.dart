import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Release {
  final String tagName;
  final String htmlUrl;
  final bool prerelease;
  final String? body;
  final String publishedAt;

  Release({
    required this.tagName,
    required this.htmlUrl,
    required this.prerelease,
    this.body,
    required this.publishedAt,
  });

  factory Release.fromJson(Map<String, dynamic> json) {
    return Release(
      tagName: json['tag_name'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      prerelease: json['prerelease'] ?? false,
      body: json['body'],
      publishedAt: json['published_at'] ?? '',
    );
  }
}

class UpdateService {
  static const String _repoOwner = 'SV-stark';
  static const String _repoName = 'InvoBharat';

  /// Fetches the latest stable and prerelease (beta/nightly) updates.
  /// Returns a map with keys 'stable' and 'beta' containing Release objects or null.
  static Future<Map<String, Release?>> checkForUpdates() async {
    try {
      final url = Uri.parse(
          'https://api.github.com/repos/$_repoOwner/$_repoName/releases');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final releases =
            jsonList.map((json) => Release.fromJson(json)).toList();

        Release? stableRelease;
        Release? betaRelease;

        // Determine current version to compare (optional, for now just showing available)
        // final packageInfo = await PackageInfo.fromPlatform();
        // final currentVersion = packageInfo.version;

        // Find latest stable
        try {
          stableRelease = releases.firstWhere((r) => !r.prerelease);
        } catch (e) {
          // No stable release found
        }

        // Find latest prerelease
        try {
          betaRelease = releases.firstWhere((r) => r.prerelease);
        } catch (e) {
          // No prerelease found
        }

        // If stable release is newer than latest prerelease, ignore beta?
        // Usually beta is newer. We just return both if available.

        return {
          'stable': stableRelease,
          'beta': betaRelease,
        };
      } else {
        throw Exception('Failed to load releases');
      }
    } catch (e) {
      // Handle network errors etc
      debugPrint('Error checking for updates: $e');
      return {
        'stable': null,
        'beta': null,
      };
    }
  }
}
