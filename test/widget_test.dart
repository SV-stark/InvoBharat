import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/main.dart';
import 'package:invobharat/screens/dashboard_screen.dart';
import 'package:invobharat/models/invoice.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          invoiceListProvider.overrideWith((ref) => Future.value(<Invoice>[])),
        ],
        child: const InvoBharatApp(),
      ),
    );

    // Wait for animations and async data to settle
    await tester.pump(); // Start Future
    await tester.pump(const Duration(seconds: 1)); // Allow time for Future
    await tester.pump(); // Rebuild with data

    // Verify that our title is present.
    expect(find.text('InvoBharat'), findsOneWidget);

    // Verify that "New Invoice" button is present.
    expect(find.text('New Invoice'), findsOneWidget);
  });
}
