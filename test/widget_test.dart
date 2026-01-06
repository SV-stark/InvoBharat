import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/main.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: InvoBharatApp()));

    // Wait for animations and async data to settle
    await tester.pumpAndSettle();

    // Verify that our title is present.
    expect(find.text('InvoBharat'), findsOneWidget);

    // Verify that "New Invoice" button is present.
    expect(find.text('New Invoice'), findsOneWidget);
  });
}
