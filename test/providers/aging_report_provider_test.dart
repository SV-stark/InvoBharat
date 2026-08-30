import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/aging_report_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  group('agingReportProvider', () {
    late MockInvoiceRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockInvoiceRepository();
      container = ProviderContainer(
        overrides: [
          invoiceRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('categorizes unpaid invoices into aging buckets correctly', () async {
      final now = DateTime.now();
      final invoices = [
        Invoice(
          id: 'inv-current',
          invoiceNo: 'INV-101',
          invoiceDate: now,
          dueDate: now.add(const Duration(days: 10)),
          items: [
            InvoiceItem(
              id: '1',
              description: 'Service A',
              amount: 1000,
              quantity: 1,
              gstRate: 0,
            ),
          ],
          supplier: const Supplier(name: 'Supplier'),
          receiver: const Receiver(name: 'Client Current'),
        ),
        Invoice(
          id: 'inv-30',
          invoiceNo: 'INV-102',
          invoiceDate: now.subtract(const Duration(days: 45)),
          dueDate: now.subtract(const Duration(days: 15)),
          items: [
            InvoiceItem(
              id: '2',
              description: 'Service B',
              amount: 2000,
              quantity: 1,
              gstRate: 0,
            ),
          ],
          supplier: const Supplier(name: 'Supplier'),
          receiver: const Receiver(name: 'Client Overdue 15'),
        ),
      ];

      when(
        () => mockRepository.getAllInvoices(),
      ).thenAnswer((_) async => invoices);

      final report = await container.read(agingReportProvider.future);

      expect(report.totalReceivable, 3000.0);
      expect(report.buckets.length, 5);

      // Bucket 0: Current
      expect(report.buckets[0].amount, 1000.0);
      expect(report.buckets[0].count, 1);

      // Bucket 1: 1-30 Days Overdue
      expect(report.buckets[1].amount, 2000.0);
      expect(report.buckets[1].count, 1);

      // Client breakdown
      expect(report.clientBreakdown['Client Current'], 1000.0);
      expect(report.clientBreakdown['Client Overdue 15'], 2000.0);
    });
  });
}
