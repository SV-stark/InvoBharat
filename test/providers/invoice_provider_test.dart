import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_provider.dart';

void main() {
  group('InvoiceNotifier', () {
    late ProviderContainer container;
    final mockProfile = BusinessProfile.defaults().copyWith(
      companyName: 'Mock Corp',
      address: 'Mock Street',
      gstin: '29AAAAA0000A1Z5',
      state: 'Karnataka',
    );

    setUp(() {
      container = ProviderContainer(
        overrides: [businessProfileProvider.overrideWithValue(mockProfile)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be populated from businessProfileProvider', () {
      final invoice = container.read(invoiceProvider);

      expect(invoice.supplier.name, 'Mock Corp');
      expect(invoice.supplier.state, 'Karnataka');
      expect(invoice.items.length, 1);
      expect(invoice.invoiceNo, startsWith('INV-'));
    });

    test('updateDate should update the invoice date', () {
      final newDate = DateTime(2025, 12, 25);
      container.read(invoiceProvider.notifier).updateDate(newDate);

      final invoice = container.read(invoiceProvider);
      expect(invoice.invoiceDate, newDate);
    });

    test('updateReceiverGstin should auto-populate receiver state', () {
      // 27 is Maharashtra
      container
          .read(invoiceProvider.notifier)
          .updateReceiverGstin('27AAAAA0000A1Z5');

      final invoice = container.read(invoiceProvider);
      expect(invoice.receiver.gstin, '27AAAAA0000A1Z5');
      expect(invoice.receiver.state, 'Maharashtra');
    });

    test('addItem and removeItem should manage items list', () {
      final notifier = container.read(invoiceProvider.notifier);

      notifier.addItem();
      expect(container.read(invoiceProvider).items.length, 2);

      notifier.removeItem(0);
      expect(container.read(invoiceProvider).items.length, 1);

      // Should not remove the last item based on logic in InvoiceNotifier
      notifier.removeItem(0);
      expect(container.read(invoiceProvider).items.length, 1);
    });

    test('updateItemAmount should update specific item price', () {
      final notifier = container.read(invoiceProvider.notifier);

      notifier.updateItemAmount(0, '500.50');

      final invoice = container.read(invoiceProvider);
      expect(invoice.items[0].amount, 500.50);
      expect(invoice.totalTaxableValue, 500.50);
    });

    test('reset should restore defaults from profile', () {
      final notifier = container.read(invoiceProvider.notifier);

      notifier.updateReceiverName('Someone');
      expect(container.read(invoiceProvider).receiver.name, 'Someone');

      notifier.reset();
      expect(container.read(invoiceProvider).receiver.name, '');
    });
  });
}
