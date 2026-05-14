import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';

void main() {
  group('Comprehensive GST Logic Tests', () {
    const defaultSupplier = Supplier(state: 'Maharashtra');
    const defaultReceiver = Receiver(state: 'Maharashtra');

    test('Intrastate Calculation (Same State)', () {
      final invoice = Invoice(
        supplier: defaultSupplier,
        receiver: defaultReceiver,
        placeOfSupply: 'Maharashtra',
        invoiceDate: DateTime.now(),
        items: [
          const InvoiceItem(amount: 1000), // CGST 90, SGST 90
        ],
      );

      expect(invoice.isInterState, isFalse);
      expect(invoice.totalCGST, 90.0);
      expect(invoice.totalSGST, 90.0);
      expect(invoice.totalIGST, 0.0);
      expect(invoice.grandTotal, 1180.0);
    });

    test('Interstate Calculation (Different State)', () {
      final invoice = Invoice(
        supplier: defaultSupplier,
        receiver: const Receiver(state: 'Karnataka'),
        placeOfSupply: 'Karnataka',
        invoiceDate: DateTime.now(),
        items: [
          const InvoiceItem(amount: 1000), // IGST 180
        ],
      );

      expect(invoice.isInterState, isTrue);
      expect(invoice.totalCGST, 0.0);
      expect(invoice.totalSGST, 0.0);
      expect(invoice.totalIGST, 180.0);
      expect(invoice.grandTotal, 1180.0);
    });

    test('Whitespace and Case Insensitivity', () {
      final invoice = Invoice(
        supplier: const Supplier(state: '  Tamil Nadu  '),
        receiver: defaultReceiver,
        placeOfSupply: 'tamil nadu',
        invoiceDate: DateTime.now(),
        items: [const InvoiceItem(amount: 100, gstRate: 12)],
      );

      expect(
        invoice.isInterState,
        isFalse,
        reason: 'Should handle whitespace and casing',
      );
      expect(invoice.totalCGST, 6.0);
    });

    test('Multiple Items with Mixed GST Rates', () {
      final invoice = Invoice(
        supplier: defaultSupplier,
        placeOfSupply: 'Maharashtra',
        invoiceDate: DateTime.now(),
        receiver: defaultReceiver,
        items: [
          const InvoiceItem(amount: 1000), // CGST 90, SGST 90
          const InvoiceItem(
            amount: 500,
            quantity: 2,
            gstRate: 5,
          ), // Taxable 1000, CGST 25, SGST 25
        ],
      );

      expect(invoice.totalTaxableValue, 2000.0);
      expect(invoice.totalCGST, 115.0); // 90 + 25
      expect(invoice.totalSGST, 115.0);
      expect(invoice.grandTotal, 2230.0);
    });

    test('Discount Application', () {
      final invoice = Invoice(
        supplier: defaultSupplier,
        placeOfSupply: 'Maharashtra',
        invoiceDate: DateTime.now(),
        receiver: defaultReceiver,
        discountAmount: 100.0,
        items: [
          const InvoiceItem(amount: 1000), // Taxable 1000, GST 180, Total 1180
        ],
      );

      expect(invoice.grandTotal, 1080.0); // 1180 - 100
    });

    test('Precision and Rounding (Money2 integration check)', () {
      // Testing with values that might cause floating point issues if not handled by Money2
      final invoice = Invoice(
        supplier: defaultSupplier,
        placeOfSupply: 'Maharashtra',
        invoiceDate: DateTime.now(),
        receiver: defaultReceiver,
        items: [
          const InvoiceItem(amount: 33.33),
          // Taxable: 33.33
          // GST: 5.9994 -> Should round based on currency (INR usually 2 decimal)
        ],
      );

      // 33.33 * 0.09 = 2.9997 -> Rounded to 3.00
      // CGST: 3.00, SGST: 3.00, Total GST: 6.00
      // Grand Total: 33.33 + 6.00 = 39.33

      expect(invoice.totalCGST, 3.00);
      expect(invoice.totalSGST, 3.00);
      expect(invoice.grandTotal, 39.33);
    });

    test('Edge Case: Empty State Strings', () {
      final invoice = Invoice(
        supplier: const Supplier(),
        invoiceDate: DateTime.now(),
        receiver: defaultReceiver,
        items: [const InvoiceItem(amount: 100)],
      );

      expect(
        invoice.isInterState,
        isFalse,
        reason: 'Defaults to Intrastate if states are missing',
      );
      expect(invoice.totalCGST, 9.0);
    });
  });
}
