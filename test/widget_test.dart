import 'dart:io' as io;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/main.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/data/invoice_repository.dart';

import 'package:invobharat/providers/invoice_repository_provider.dart';

class FakeInvoiceRepository implements InvoiceRepository {
  @override
  String get profileId => 'test_profile';

  @override
  Future<List<Invoice>> getAllInvoices() async {
    return [];
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          invoiceRepositoryProvider.overrideWithValue(FakeInvoiceRepository()),
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

    // Verify that "New Invoice" (Material) or "Create Invoice" (Fluent) button is present.
    if (io.Platform.isWindows) {
      expect(find.text('Create Invoice'), findsOneWidget);
    } else {
      expect(find.text('New Invoice'), findsOneWidget);
    }
  });
}
