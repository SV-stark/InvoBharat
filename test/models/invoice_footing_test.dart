import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';

void main() {
  group('Invoice and PDF footing with discounts', () {
    test('itemTaxableValue, taxes and itemTotalAmount foot to invoice totals', () {
      const item1 = InvoiceItem(
        id: '1',
        description: 'Service A',
        amount: 1000,
      );
      final invoice = Invoice(
        id: 'inv-1',
        invoiceDate: DateTime(2025),
        supplier: const Supplier(state: 'Delhi'),
        receiver: const Receiver(state: 'Delhi'),
        items: [item1],
        discountAmount: 500,
      );

      // Intrastate: CGST 9% and SGST 9%
      expect(invoice.isInterState, isFalse);
      expect(invoice.grossTaxableValue, equals(1000.0));
      expect(invoice.totalTaxableValue, equals(500.0));

      final itemTaxable = invoice.itemTaxableValue(item1);
      final itemCgst = invoice.itemCgstAmount(item1);
      final itemSgst = invoice.itemSgstAmount(item1);
      final itemIgst = invoice.itemIgstAmount(item1);
      final itemTotal = invoice.itemTotalAmount(item1);

      expect(itemTaxable, equals(500.0));
      expect(itemCgst, equals(45.0));
      expect(itemSgst, equals(45.0));
      expect(itemIgst, equals(0.0));
      expect(itemTotal, equals(590.0));

      // Check footing
      expect(invoice.totalCGST, equals(45.0));
      expect(invoice.totalSGST, equals(45.0));
      expect(invoice.totalIGST, equals(0.0));
      expect(invoice.grandTotal, equals(590.0));
      expect(itemTotal, equals(invoice.grandTotal));
    });

    test('interstate invoice with multiple items feet proportionally', () {
      const item1 = InvoiceItem(
        id: '1',
        description: 'Item 1',
        amount: 600,
      );
      const item2 = InvoiceItem(
        id: '2',
        description: 'Item 2',
        amount: 400,
        gstRate: 12,
      );
      final invoice = Invoice(
        id: 'inv-2',
        invoiceDate: DateTime(2025),
        supplier: const Supplier(state: 'Delhi'),
        receiver: const Receiver(state: 'Maharashtra'),
        items: [item1, item2],
        discountAmount: 200, // 20% discount on gross 1000
      );

      expect(invoice.isInterState, isTrue);
      expect(invoice.grossTaxableValue, equals(1000.0));
      expect(invoice.totalTaxableValue, equals(800.0));

      // item 1: 600 - 20% = 480 taxable, 18% IGST = 86.4, total = 566.4
      expect(invoice.itemTaxableValue(item1), equals(480.0));
      expect(invoice.itemIgstAmount(item1), equals(86.4));
      expect(invoice.itemTotalAmount(item1), equals(566.4));

      // item 2: 400 - 20% = 320 taxable, 12% IGST = 38.4, total = 358.4
      expect(invoice.itemTaxableValue(item2), equals(320.0));
      expect(invoice.itemIgstAmount(item2), equals(38.4));
      expect(invoice.itemTotalAmount(item2), equals(358.4));

      final sumItemTotals = invoice.itemTotalAmount(item1) + invoice.itemTotalAmount(item2);
      expect(sumItemTotals, closeTo(invoice.grandTotal, 0.01));
      expect(invoice.grandTotal, closeTo(800 + 86.4 + 38.4, 0.01));
    });

    test('InvoiceItem currency property defaults to INR and can be customized', () {
      const itemInr = InvoiceItem(amount: 100);
      expect(itemInr.currency, equals('INR'));

      const itemUsd = InvoiceItem(amount: 100, currency: 'USD');
      expect(itemUsd.currency, equals('USD'));
    });
  });
}
