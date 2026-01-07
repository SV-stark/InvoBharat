import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';

void main() {
  group('CGST Compliance Model Tests', () {
    test('InvoiceItem calculates netAmount correctly with quantity', () {
      final item = InvoiceItem(
        amount: 100, // Price per unit
        quantity: 2,
        discount: 0,
      );
      // Net Amount = (Amount * Quantity) - Discount
      // 100 * 2 - 0 = 200
      expect(item.netAmount, 200);
    });

    test('InvoiceItem calculates netAmount correctly with discount', () {
      final item = InvoiceItem(
        amount: 100,
        quantity: 5,
        discount: 50,
      );
      // (100 * 5) - 50 = 450
      expect(item.netAmount, 450);
    });

    test('InvoiceItem serializes quantity and unit', () {
      final item = InvoiceItem(
        quantity: 2.5,
        unit: 'Kg',
        amount: 50,
      );
      final json = item.toJson();
      expect(json['quantity'], 2.5);
      expect(json['unit'], 'Kg');

      final deserialized = InvoiceItem.fromJson(json);
      expect(deserialized.quantity, 2.5);
      expect(deserialized.unit, 'Kg');
    });

    test('Invoice holds deliveryAddress', () {
      final invoice = Invoice(
        supplier: const Supplier(),
        receiver: const Receiver(),
        invoiceDate: DateTime.now(),
        deliveryAddress: "123 Warehouse St",
      );
      expect(invoice.deliveryAddress, "123 Warehouse St");

      final json = invoice.toJson();
      expect(json['deliveryAddress'], "123 Warehouse St");

      final deserialized = Invoice.fromJson(json);
      expect(deserialized.deliveryAddress, "123 Warehouse St");
    });

    test('Receiver holds state and stateCode', () {
      final receiver = const Receiver(
        state: "Maharashtra",
        stateCode: "27",
      );
      expect(receiver.state, "Maharashtra");
      expect(receiver.stateCode, "27");

      final json = receiver.toJson();
      expect(json['state'], "Maharashtra");
      expect(json['stateCode'], "27");

      final des = Receiver.fromJson(json);
      expect(des.state, "Maharashtra");
      expect(des.stateCode, "27");
    });
  });
}
