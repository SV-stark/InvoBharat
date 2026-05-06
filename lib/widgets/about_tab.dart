import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:invobharat/services/update_service.dart';
import 'package:invobharat/providers/app_config_provider.dart';

class AboutTab extends ConsumerWidget {
  const AboutTab({super.key});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/SV-stark/InvoBharat');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _checkForUpdates(
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final config = ref.read(appConfigProvider);
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Checking for updates...')));

    final updates = await UpdateService.checkForUpdates();
    if (!context.mounted) return;

    final Release? latest =
        config.updateChannel == UpdateChannel.stable
            ? updates['stable']
            : updates['nightly'];

    if (latest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No updates found for this channel.')),
      );
      return;
    }

    bool updateAvailable = false;
    if (config.updateChannel == UpdateChannel.stable) {
      // Simple version comparison (e.g., 1.0.1 > 1.0.0)
      updateAvailable = latest.tagName.compareTo(currentVersion) > 0;
    } else {
      // For nightly, we'll just check if it's newer than some baseline or always show if date is recent
      // As a simplification, we show it if it's a prerelease and tag is different from current
      updateAvailable = latest.tagName != currentVersion;
    }

    if (!updateAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You are on the latest version.')));
      return;
    }

    unawaited(
      showDialog(
        context: context,
        builder: (final context) {
          bool isDownloading = false;
          return StatefulBuilder(
            builder: (final context, final setDialogState) {
              return AlertDialog(
                title: Text(
                  config.updateChannel == UpdateChannel.stable
                      ? 'New Version Available'
                      : 'New Nightly Build Available',
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current: $currentVersion'),
                    Text('Latest: ${latest.tagName}'),
                    const SizedBox(height: 10),
                    Text('Published: ${latest.publishedAt}'),
                    if (latest.body != null) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Changelog:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        latest.body!,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isDownloading) ...[
                      const SizedBox(height: 20),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 10),
                      const Text("Downloading and preparing update..."),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isDownloading ? null : () => Navigator.pop(context),
                    child: const Text('Later'),
                  ),
                  FilledButton(
                    onPressed:
                        isDownloading
                            ? null
                            : () async {
                              setDialogState(() => isDownloading = true);
                              try {
                                await UpdateService.downloadAndInstallUpdate(
                                  latest,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Update failed: $e')),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                    child: const Text('Update Now'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('logo.png', width: 120, height: 120),
          const SizedBox(height: 16),
          const Text(
            'InvoBharat',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (final context, final snapshot) {
              final version = snapshot.data?.version ?? '...';
              return Text(
                'Version $version',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              );
            },
          ),
          const SizedBox(height: 32),
          const Divider(indent: 64, endIndent: 64),
          const SizedBox(height: 32),
          const Text('Made with ❤️ in India', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Developed by SV-stark',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _launchUrl,
            icon: const Icon(Icons.code),
            label: const Text('View on GitHub'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _checkForUpdates(context, ref),
            icon: const Icon(Icons.update),
            label: const Text('Check for Updates'),
          ),
        ],
      ),
    );
  }
}
