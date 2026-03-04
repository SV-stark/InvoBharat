import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/audit_service.dart';

void main() {
  group('AuditService', () {
    final now = DateTime.now();
    const mockSupplier = Supplier(name: 'S');
    const mockReceiver = Receiver(name: 'R');

    test('detectGaps should find missing numbers in simple sequence', () {
      final invoices = [
        Invoice(
          invoiceNo: 'INV-001',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
        Invoice(
          invoiceNo: 'INV-003',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
      ];

      final missing = AuditService.detectGaps(invoices);
      expect(missing, contains('INV-2'));
    });

    test('detectGaps should handle multiple prefixes', () {
      final invoices = [
        Invoice(
          invoiceNo: 'SALE-1',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
        Invoice(
          invoiceNo: 'SALE-3',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
        Invoice(
          invoiceNo: 'PUR-10',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
        Invoice(
          invoiceNo: 'PUR-12',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
      ];

      final missing = AuditService.detectGaps(invoices);
      expect(missing, contains('SALE-2'));
      expect(missing, contains('PUR-11'));
    });

    test('detectGaps return empty if no gaps', () {
      final invoices = [
        Invoice(
          invoiceNo: 'INV-1',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
        Invoice(
          invoiceNo: 'INV-2',
          supplier: mockSupplier,
          receiver: mockReceiver,
          invoiceDate: now,
        ),
      ];

      final missing = AuditService.detectGaps(invoices);
      expect(missing, isEmpty);
    });
  });
}
