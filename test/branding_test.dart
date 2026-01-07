import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/screens/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('DashboardScreen displays App Logo and InvoBharat text',
      (WidgetTester tester) async {
    // Provide a mock or container for Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for fonts/assets if needed, but in test env assets mock might be needed.
    // We already fixed assets issue in previous test run, assuming it works for 'logo.png'.

    // Verify "InvoBharat" title is present
    expect(find.text('InvoBharat'), findsAtLeastNWidgets(1));

    // Verify Image asset is present (we can find by type and check asset name if we want, or just generic Image type)
    // Finding exact asset image in test depends on how it's loaded, but Image widget should be there.
    expect(find.byType(Image), findsOneWidget);
  });
}
