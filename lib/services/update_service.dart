import 'package:dio/dio.dart';
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
  
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ),
  );

  static Future<Map<String, Release?>> checkForUpdates() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final releases =
            jsonList.map((json) => Release.fromJson(json)).toList();

        Release? stableRelease;
        Release? betaRelease;

        try {
          stableRelease = releases.firstWhere((r) => !r.prerelease);
        } catch (e) {
          // No stable release found
        }

        try {
          betaRelease = releases.firstWhere((r) => r.prerelease);
        } catch (e) {
          // No prerelease found
        }

        return {
          'stable': stableRelease,
          'beta': betaRelease,
        };
      } else {
        throw Exception('Failed to load releases');
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return {
        'stable': null,
        'beta': null,
      };
    }
  }
}
