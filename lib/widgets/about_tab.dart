import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/SV-stark/InvoBharat');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(indent: 64, endIndent: 64),
          const SizedBox(height: 32),
          // Credits
          const Text(
            'Made with ❤️ in India',
            style: TextStyle(fontSize: 18),
          ),
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
        ],
      ),
    );
  }
}
