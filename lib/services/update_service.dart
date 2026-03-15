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

  factory Release.fromJson(final Map<String, dynamic> json) {
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

  static Future<Map<String, Release?>> checkForUpdates({final http.Client? client}) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        Uri.parse('https://api.github.com/repos/$_repoOwner/$_repoName/releases'),
        headers: {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'User-Agent': 'InvoBharat-App',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final releases = jsonList
            .map((final json) => Release.fromJson(json))
            .toList();

        Release? stableRelease;
        Release? betaRelease;

        try {
          stableRelease = releases.firstWhere((final r) => !r.prerelease);
        } catch (e) {
          // No stable release found
        }

        try {
          betaRelease = releases.firstWhere((final r) => r.prerelease);
        } catch (e) {
          // No prerelease found
        }

        return {'stable': stableRelease, 'beta': betaRelease};
      } else {
        throw Exception('Failed to load releases: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return {'stable': null, 'beta': null};
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
