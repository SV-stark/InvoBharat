import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/widgets/about_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('AboutTab displays correct content', (
    final WidgetTester tester,
  ) async {
    // Mock PackageInfo
    PackageInfo.setMockInitialValues(
      appName: 'InvoBharat',
      packageName: 'com.example.invobharat',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'sig',
    );

    // Build the AboutTab widget with ProviderScope.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AboutTab())),
      ),
    );

    // Verify "InvoBharat" text is present.
    expect(find.text('InvoBharat'), findsOneWidget);

    // Wait for FutureBuilder
    await tester.pumpAndSettle();

    // Verify "Version 1.0.0" text is present.
    expect(find.text('Version 1.0.0'), findsOneWidget);

    // Verify "Made with ❤️ in India" text is present.
    expect(find.text('Made with ❤️ in India'), findsOneWidget);

    // Verify "Developed by SV-stark" text is present.
    expect(find.text('Developed by SV-stark'), findsOneWidget);

    // Verify "View on GitHub" button is present.
    expect(find.text('View on GitHub'), findsOneWidget);
    expect(find.byIcon(Icons.code), findsOneWidget);
  });
}
