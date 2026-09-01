import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/payment_transaction.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/ledger_provider.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  group('clientLedgerProvider', () {
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

    test('calculates running debit, credit, and balance correctly', () async {
      final now = DateTime(2026, 8, 30);
      final invoices = [
        Invoice(
          id: 'inv1',
          invoiceNo: 'INV-001',
          invoiceDate: now,
          items: const [
            InvoiceItem(
              id: '1',
              description: 'Item A',
              amount: 1000,
            ),
          ],
          payments: [
            PaymentTransaction(
              id: 'p1',
              invoiceId: 'inv1',
              date: now.add(const Duration(days: 2)),
              amount: 500,
              paymentMode: 'UPI',
            ),
          ],
          supplier: const Supplier(name: 'Supplier'),
          receiver: const Receiver(name: 'Acme Corp', gstin: '27AAPFU0939F1ZT'),
        ),
      ];

      when(
        () => mockRepository.getInvoicesForClient(
          clientId: any(named: 'clientId'),
          gstin: any(named: 'gstin'),
          query: any(named: 'query'),
        ),
      ).thenAnswer((_) async => invoices);

      final entries = await container.read(
        clientLedgerProvider('Acme Corp').future,
      );

      expect(entries.length, 2);
      expect(entries[0].type, 'INVOICE');
      expect(entries[0].debit, 1180.0);
      expect(entries[0].credit, 0.0);
      expect(entries[0].balance, 1180.0);

      expect(entries[1].type, 'PAYMENT');
      expect(entries[1].debit, 0.0);
      expect(entries[1].credit, 500.0);
      expect(entries[1].balance, 680.0);
    });
  });
}
