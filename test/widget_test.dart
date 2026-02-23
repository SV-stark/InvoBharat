import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/main.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/data/invoice_repository.dart';

import 'package:invobharat/providers/invoice_repository_provider.dart';

class FakeInvoiceRepository implements InvoiceRepository {
  String get profileId => 'test_profile';

  @override
  Future<List<Invoice>> getAllInvoices() async {
    return [];
  }

  @override
  Future<Invoice?> getInvoice(final String id) async {
    return null;
  }

  @override
  Future<void> deleteAll() async {}

  @override
  Future<void> saveInvoice(final Invoice invoice) async {}

  @override
  dynamic noSuchMethod(final Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Dashboard loads correctly', (final WidgetTester tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // Verify that "InvoBharat" title is present.
    expect(find.text('InvoBharat'), findsAtLeast(1));

    // Verify that "New Invoice" button is present.
    expect(find.text('New Invoice'), findsWidgets);
  });
}
