import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
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
      final receiver = const Receiver(
        name: 'Rec',
        email: 'test@test.com',
        state: 'Maharashtra',
        stateCode: '27',
      );
      final json = receiver.toJson();
      expect(json['email'], 'test@test.com');
      expect(json['stateCode'], '27');
      expect(Receiver.fromJson(json).name, 'Rec');
      expect(Receiver.fromJson(json).stateCode, '27');
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

    test('InvoiceItem serialization of quantity and unit', () {
      final item = const InvoiceItem(quantity: 2.5, unit: 'Kg', amount: 50);
      final json = item.toJson();
      expect(json['quantity'], 2.5);
      expect(json['unit'], 'Kg');

      final deserialized = InvoiceItem.fromJson(json);
      expect(deserialized.quantity, 2.5);
      expect(deserialized.unit, 'Kg');
    });
  });

  group('Invoice', () {
    final supplier = const Supplier(state: 'Karnataka');
    final receiver = const Receiver(state: 'Maharashtra');
    final date = DateTime(2025);

    final item1 = const InvoiceItem(amount: 100); // Net 100
    final item2 = const InvoiceItem(amount: 200, gstRate: 12); // Net 200

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

      // item1: 100 net, item2: 200 net -> total undiscounted 300
      // With flat discount 10 (CGST Sec 15(3) pre-tax proportional deduction):
      // item1 taxable: 100 - (10 * 100/300) = 96.67
      // item2 taxable: 200 - (10 * 200/300) = 193.33
      // Total taxable: 290.0
      // Total CGST: 96.6667 * 0.09 + 193.3333 * 0.06 = 8.70 + 11.60 = 20.30
      // Total SGST: 20.30
      // Grand Total: 290 + 20.30 + 20.30 = 330.60
      expect(invoice.totalTaxableValue, 290.0);
      expect(invoice.totalCGST, closeTo(20.3, 0.01));
      expect(invoice.totalSGST, closeTo(20.3, 0.01));
      expect(invoice.totalIGST, 0.0);
      expect(invoice.grandTotal, closeTo(330.6, 0.01));
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
      // Under P1 #10 fix, overdue status takes precedence when dueDate is past
      expect(partialInvoice.paymentStatus, 'Overdue');
      expect(partialInvoice.balanceDue, 60.0);

      // When dueDate is in future, partial payment is 'Partial'
      final futurePartialInvoice = partialInvoice.copyWith(
        dueDate: DateTime.now().add(const Duration(days: 7)),
      );
      expect(futurePartialInvoice.paymentStatus, 'Partial');

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

    test('Invoice holds and serializes deliveryAddress', () {
      final invoice = Invoice(
        supplier: const Supplier(),
        receiver: const Receiver(),
        invoiceDate: DateTime.now(),
        deliveryAddress: "123 Warehouse St",
      );
      expect(invoice.deliveryAddress, "123 Warehouse St");

      final json = jsonDecode(jsonEncode(invoice.toJson()));
      expect(json['deliveryAddress'], "123 Warehouse St");

      final deserialized = Invoice.fromJson(json);
      expect(deserialized.deliveryAddress, "123 Warehouse St");
    });
  });
}
