import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/payment_transaction.dart';

void main() {
  group('Supplier & Receiver', () {
    test('Supplier fromJson/toJson', () {
      final supplier = const Supplier(name: 'Sup', state: 'Karnataka');
      final json = supplier.toJson();
      expect(json['name'], 'Sup');
      expect(Supplier.fromJson(json).state, 'Karnataka');
    });

    test('Receiver fromJson/toJson', () {
      final receiver = const Receiver(name: 'Rec', email: 'test@test.com');
      final json = receiver.toJson();
      expect(json['email'], 'test@test.com');
      expect(Receiver.fromJson(json).name, 'Rec');
    });
  });

  group('InvoiceItem', () {
    const item = InvoiceItem(
      description: 'Test Item',
      amount: 100,
      quantity: 2,
      discount: 10,
    );

    test('netAmount calculation', () {
      // (100 * 2) - 10 = 190
      expect(item.netAmount, 190.0);
    });

    test('tax calculations for intra-state', () {
      expect(item.cgstRate, 9.0);
      expect(item.sgstRate, 9.0);
      // 190 * 0.09 = 17.1
      expect(item.calculateCgst(false), closeTo(17.1, 0.001));
      expect(item.calculateSgst(false), closeTo(17.1, 0.001));
      expect(item.calculateIgst(false), 0.0);
    });

    test('tax calculations for inter-state', () {
      // 190 * 0.18 = 34.2
      expect(item.calculateIgst(true), closeTo(34.2, 0.001));
      expect(item.calculateCgst(true), 0.0);
      expect(item.calculateSgst(true), 0.0);
    });

    test('totalAmount calculation', () {
      // 190 * 1.18 = 224.2
      expect(item.totalAmount, closeTo(224.2, 0.001));
    });
  });

  group('Invoice', () {
    final supplier = const Supplier(state: 'Karnataka');
    final receiver = const Receiver(state: 'Maharashtra');
    final date = DateTime(2025);

    final item1 = const InvoiceItem(
      amount: 100,
    ); // Net 100
    final item2 = const InvoiceItem(
      amount: 200,
      gstRate: 12,
    ); // Net 200

    test('isInterState detection', () {
      final intraInvoice = Invoice(
        supplier: supplier,
        receiver: receiver,
        placeOfSupply: 'Karnataka',
        invoiceDate: date,
      );
      expect(intraInvoice.isInterState, false);

      final interInvoice = Invoice(
        supplier: supplier,
        receiver: receiver,
        placeOfSupply: 'Maharashtra',
        invoiceDate: date,
      );
      expect(interInvoice.isInterState, true);
    });

    test('grandTotal calculation for intra-state', () {
      final invoice = Invoice(
        supplier: supplier,
        receiver: receiver,
        placeOfSupply: 'Karnataka',
        invoiceDate: date,
        items: [item1, item2],
        discountAmount: 10,
      );

      // item1: 100 net, 9 CGST, 9 SGST
      // item2: 200 net, 12 CGST, 12 SGST
      // Total taxable: 300
      // Total CGST: 9 + 12 = 21
      // Total SGST: 9 + 12 = 21
      // Total IGST: 0
      // Grand Total: 300 + 21 + 21 - 10 = 332
      expect(invoice.totalTaxableValue, 300.0);
      expect(invoice.totalCGST, 21.0);
      expect(invoice.totalSGST, 21.0);
      expect(invoice.totalIGST, 0.0);
      expect(invoice.grandTotal, 332.0);
    });

    test('grandTotal calculation for inter-state', () {
      final invoice = Invoice(
        supplier: supplier,
        receiver: receiver,
        placeOfSupply: 'Maharashtra',
        invoiceDate: date,
        items: [item1, item2],
      );

      // item1: 100 net, 18 IGST
      // item2: 200 net, 24 IGST
      // Total taxable: 300
      // Total IGST: 18 + 24 = 42
      // Grand Total: 342
      expect(invoice.totalIGST, 42.0);
      expect(invoice.grandTotal, 342.0);
    });

    test('paymentStatus and balanceDue', () {
      final invoice = Invoice(
        supplier: supplier,
        receiver: receiver,
        placeOfSupply: 'Karnataka',
        invoiceDate: date,
        items: [const InvoiceItem(amount: 100, gstRate: 0)],
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      // grandTotal = 100
      expect(invoice.paymentStatus, 'Overdue');
      expect(invoice.balanceDue, 100.0);

      final partialInvoice = invoice.copyWith(
        payments: [
          PaymentTransaction(
            id: 'p1',
            invoiceId: 'inv1',
            amount: 40,
            date: DateTime.now(),
            paymentMode: 'Cash',
          ),
        ],
      );
      expect(partialInvoice.paymentStatus, 'Partial');
      expect(partialInvoice.balanceDue, 60.0);

      final paidInvoice = partialInvoice.copyWith(
        payments: [
          ...partialInvoice.payments,
          PaymentTransaction(
            id: 'p2',
            invoiceId: 'inv1',
            amount: 60,
            date: DateTime.now(),
            paymentMode: 'Cash',
          ),
        ],
      );
      expect(paidInvoice.paymentStatus, 'Paid');
      expect(paidInvoice.balanceDue, 0.0);
    });
  });
}
