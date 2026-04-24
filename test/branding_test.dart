import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/screens/dashboard_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('DashboardScreen displays App Logo and InvoBharat text',
      (final WidgetTester tester) async {
    // Provide a mock or container for Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify "InvoBharat" title is present
    expect(find.text('InvoBharat'), findsAtLeastNWidgets(1));

    // Verify Image asset is present (we can find by type and check asset name if we want, or just generic Image type)
    // Finding exact asset image in test depends on how it's loaded, but Image widget should be there.
    expect(find.byType(Image), findsOneWidget);

    // Add pump with duration to allow one frame of animation/state to settle
    // without timing out on infinite animations (like Skeletonizer)
    await tester.pump(const Duration(seconds: 1));
  });
}
