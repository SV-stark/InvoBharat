import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';

void main() {
  group('Invoice Tax Calculation', () {
    test('Intra-state (same state) should calculate CGST + SGST', () {
      final supplier = const Supplier(state: 'Karnataka');
      final invoice = Invoice(
        supplier: supplier,
        placeOfSupply: 'Karnataka',
        invoiceDate: DateTime.now(),
        receiver: const Receiver(),
        items: [
          const InvoiceItem(amount: 100, gstRate: 18),
        ],
      );

      expect(invoice.isInterState, false);
      expect(invoice.totalCGST, 9.0);
      expect(invoice.totalSGST, 9.0);
      expect(invoice.totalIGST, 0.0);
      expect(invoice.grandTotal, 118.0);
    });

    test('Inter-state (different state) should calculate IGST', () {
      final supplier = const Supplier(state: 'Karnataka');
      final invoice = Invoice(
        supplier: supplier,
        placeOfSupply: 'Maharashtra',
        invoiceDate: DateTime.now(),
        receiver: const Receiver(),
        items: [
          const InvoiceItem(amount: 100, gstRate: 18),
        ],
      );

      expect(invoice.isInterState, true);
      expect(invoice.totalCGST, 0.0);
      expect(invoice.totalSGST, 0.0);
      expect(invoice.totalIGST, 18.0);
      expect(invoice.grandTotal, 118.0);
    });

    test('Case insensitivity check', () {
      final supplier = const Supplier(state: 'Karnataka');
      final invoice = Invoice(
        supplier: supplier,
        placeOfSupply: 'KARNATAKA',
        invoiceDate: DateTime.now(),
        receiver: const Receiver(),
        items: [
          const InvoiceItem(amount: 100, gstRate: 18),
        ],
      );

      expect(invoice.isInterState, false);
    });

    test(
        'Empty state check (defaults to false/Intra usually or handles gracefully)',
        () {
      final invoice = Invoice(
        supplier: const Supplier(state: ''),
        placeOfSupply: 'Karnataka',
        invoiceDate: DateTime.now(),
        receiver: const Receiver(),
        items: [
          const InvoiceItem(amount: 100, gstRate: 18),
        ],
      );
      // If supplier state is empty, isInterState returns false logic in my code
      expect(invoice.isInterState, false);
    });
  });
}
