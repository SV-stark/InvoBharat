import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';

void main() {
  group('Place of Supply (POS) & GST Rules (IGST vs CGST/SGST)', () {
    const supplierDelhi = Supplier(
      name: 'Delhi Retailers Pvt Ltd',
      address: 'Connaught Place, New Delhi',
      gstin: '07AAAAA1111A1Z1',
      state: 'Delhi',
    );

    test('Intra-State Supply: Supplier state == POS state (CGST + SGST)', () {
      final invoice = Invoice(
        id: 'inv_intra',
        invoiceDate: DateTime(2026, 8, 16),
        supplier: supplierDelhi,
        receiver: const Receiver(
          name: 'Delhi Local Buyer',
          address: 'Karol Bagh, New Delhi',
          gstin: '07BBBBB2222B1Z2',
          state: 'Delhi',
          stateCode: '07',
        ),
        placeOfSupply: 'Delhi',
        items: const [
          InvoiceItem(
            description: 'Item 1',
            amount: 10000,
          ),
        ],
      );

      expect(invoice.isInterState, isFalse);
      expect(invoice.totalCGST, 900.0);
      expect(invoice.totalSGST, 900.0);
      expect(invoice.totalIGST, 0.0);
      expect(invoice.grandTotal, 11800.0);
    });

    test('Inter-State Supply: Supplier state != POS state (IGST only)', () {
      final invoice = Invoice(
        id: 'inv_inter',
        invoiceDate: DateTime(2026, 8, 16),
        supplier: supplierDelhi,
        receiver: const Receiver(
          name: 'Mumbai Tech Solutions',
          address: 'BKC, Mumbai',
          gstin: '27CCCCC3333C1Z3',
          state: 'Maharashtra',
          stateCode: '27',
        ),
        placeOfSupply: 'Maharashtra',
        items: const [
          InvoiceItem(
            description: 'Consulting',
            amount: 10000,
          ),
        ],
      );

      expect(invoice.isInterState, isTrue);
      expect(invoice.totalCGST, 0.0);
      expect(invoice.totalSGST, 0.0);
      expect(invoice.totalIGST, 1800.0);
      expect(invoice.grandTotal, 11800.0);
    });

    test('State Code Normalization: "07-Delhi" matches "07" or "Delhi"', () {
      final invoiceWithCode = Invoice(
        id: 'inv_norm',
        invoiceDate: DateTime(2026, 8, 16),
        supplier: const Supplier(
          name: 'Delhi Supplier',
          address: 'Delhi',
          gstin: '07AAAAA1111A1Z1',
          state: '07-Delhi',
        ),
        receiver: const Receiver(
          name: 'Buyer',
          address: 'Delhi',
          state: 'Delhi',
          stateCode: '07',
        ),
        placeOfSupply: '07',
        items: const [
          InvoiceItem(
            description: 'Goods',
            amount: 5000,
            gstRate: 12,
          ),
        ],
      );

      expect(invoiceWithCode.isInterState, isFalse);
      expect(invoiceWithCode.totalCGST, 300.0);
      expect(invoiceWithCode.totalSGST, 300.0);
      expect(invoiceWithCode.totalIGST, 0.0);
    });

    test('Bill-To / Ship-To: Buyer in Delhi but POS is Haryana -> IGST', () {
      final invoiceShipTo = Invoice(
        id: 'inv_shipto',
        invoiceDate: DateTime(2026, 8, 16),
        supplier: supplierDelhi, // Delhi
        receiver: const Receiver(
          name: 'Delhi Buyer Head Office',
          address: 'Nehru Place, New Delhi',
          gstin: '07DDDDD4444D1Z4',
          state: 'Delhi', // Bill To
          stateCode: '07',
        ),
        placeOfSupply: 'Haryana', // Ship To / Delivered in Haryana (06)
        items: const [
          InvoiceItem(
            description: 'Warehouse shipment',
            amount: 20000,
          ),
        ],
      );

      expect(invoiceShipTo.isInterState, isTrue);
      expect(invoiceShipTo.totalCGST, 0.0);
      expect(invoiceShipTo.totalSGST, 0.0);
      expect(invoiceShipTo.totalIGST, 3600.0);
      expect(invoiceShipTo.grandTotal, 23600.0);
    });

    test('Fallback to receiver state when placeOfSupply is blank', () {
      final invoiceFallback = Invoice(
        id: 'inv_fb',
        invoiceDate: DateTime(2026, 8, 16),
        supplier: supplierDelhi,
        receiver: const Receiver(
          name: 'Bangalore Client',
          address: 'Indiranagar, Bangalore',
          gstin: '29EEEEE5555E1Z5',
          state: 'Karnataka',
        ),
        items: const [
          InvoiceItem(
            description: 'Design Services',
            amount: 10000,
          ),
        ],
      );

      expect(invoiceFallback.isInterState, isTrue);
      expect(invoiceFallback.totalIGST, 1800.0);
    });
  });
}
