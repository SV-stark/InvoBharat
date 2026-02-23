import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:invobharat/services/update_service.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/SV-stark/InvoBharat');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _checkForUpdates(final BuildContext context) async {
    // Show loading
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Checking for updates...')));

    final updates = await UpdateService.checkForUpdates();
    if (!context.mounted) return;

    if (updates['stable'] == null && updates['beta'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No updates found or check failed.')),
      );
      return;
    }

    unawaited(
      showDialog(
        context: context,
        builder: (final context) => AlertDialog(
          title: const Text('Updates Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (updates['stable'] != null) ...[
                const Text(
                  'Stable Release:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text(updates['stable']!.tagName),
                  subtitle: Text(
                    'Published: ${updates['stable']!.publishedAt}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () =>
                        launchUrl(Uri.parse(updates['stable']!.htmlUrl)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (updates['beta'] != null) ...[
                const Text(
                  'Beta / Nightly:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text(updates['beta']!.tagName),
                  subtitle: Text('Published: ${updates['beta']!.publishedAt}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () =>
                        launchUrl(Uri.parse(updates['beta']!.htmlUrl)),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset(
            'logo.png', // Assuming logo.png is in the root of assets as per README
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 16),
          // App Name
          Text(
            'InvoBharat',
            style: GoogleFonts.outfit(
              // Using Outfit as requested in rules or consistent with modern UI
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Version
          const Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          const Divider(indent: 64, endIndent: 64),
          const SizedBox(height: 32),
          // Credits
          const Text('Made with ❤️ in India', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Developed by SV-stark',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          // Link
          FilledButton.icon(
            onPressed: _launchUrl,
            icon: const Icon(Icons.code),
            label: const Text('View on GitHub'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _checkForUpdates(context),
            icon: const Icon(Icons.update),
            label: const Text('Check for Updates'),
          ),
        ],
      ),
    );
  }
}
