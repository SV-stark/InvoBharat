import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/dashboard_actions.dart';

void main() {
  group('DashboardActions aging calculations', () {
    test('calculateAging falls back to invoiceDate when dueDate is null', () {
      final now = DateTime.now();
      // Invoice created 120 days ago with null dueDate
      final oldInvoice = Invoice(
        id: 'old-inv',
        invoiceDate: now.subtract(const Duration(days: 120)),
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [
          const InvoiceItem(amount: 1000, gstRate: 0),
        ],
      );

      final aging = DashboardActions.calculateAging([oldInvoice]);

      // When dueDate is null, it should NOT be "Current" (which it was when fallback was now)
      // It should be aged from invoiceDate into "90+ Days"
      expect(aging['Current'], equals(0.0));
      expect(aging['90+ Days'], equals(1000.0));
    });

    test('calculateAging places upcoming invoice into Current', () {
      final now = DateTime.now();
      final freshInvoice = Invoice(
        id: 'fresh-inv',
        invoiceDate: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 10)),
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [
          const InvoiceItem(amount: 500, gstRate: 0),
        ],
      );

      final aging = DashboardActions.calculateAging([freshInvoice]);
      expect(aging['Current'], equals(500.0));
    });
  });
}
