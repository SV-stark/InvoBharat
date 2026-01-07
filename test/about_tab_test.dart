import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/widgets/about_tab.dart';

void main() {
  testWidgets('AboutTab displays correct content', (WidgetTester tester) async {
    // Build the AboutTab widget.
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: AboutTab())));

    // Verify "InvoBharat" text is present.
    expect(find.text('InvoBharat'), findsOneWidget);

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
