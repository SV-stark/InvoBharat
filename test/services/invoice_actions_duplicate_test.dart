import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/invoice_series_provider.dart';
import 'package:invobharat/services/invoice_actions.dart';

class FakeInvoiceRepository implements InvoiceRepository {
  final List<Invoice> storedInvoices = [];

  @override
  Future<void> saveInvoice(final Invoice invoice) async {
    storedInvoices.add(invoice);
  }

  @override
  Future<int> getMaxSequenceForPrefix(
    final String prefix, {
    final DateTime? invoiceDate,
  }) async {
    return 5;
  }

  @override
  Future<bool> checkInvoiceExists(
    final String invoiceNo, {
    final String? excludeId,
    final DateTime? invoiceDate,
  }) async {
    return storedInvoices.any((final i) => i.invoiceNo == invoiceNo);
  }

  @override
  dynamic noSuchMethod(final Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSeriesNotifier extends InvoiceSeriesNotifier {
  @override
  List<InvoiceSeries> build() {
    return [InvoiceSeries(prefix: 'INV-', sequence: 6)];
  }

  @override
  Future<void> updateSequence(final String prefix, final int newSequence) async {}
}

void main() {
  testWidgets('InvoiceActions.duplicateInvoice creates next sequence draft invoice', (final tester) async {
    final fakeRepo = FakeInvoiceRepository();

    Invoice? duplicatedResult;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          invoiceRepositoryProvider.overrideWithValue(fakeRepo),
          businessProfileProvider.overrideWithValue(
            BusinessProfile(
              id: 'prof-1',
              companyName: 'My Business',
              address: 'Address',
              gstin: '07AAAAA0000A1Z5',
              email: 'test@example.com',
              phone: '9999999999',
            ),
          ),
          invoiceSeriesProvider.overrideWith(FakeSeriesNotifier.new),
        ],
        child: Consumer(
          builder: (final context, final ref, final _) {
            return MaterialApp(
              home: ElevatedButton(
                onPressed: () async {
                  final orig = Invoice(
                    id: 'orig-1',
                    invoiceNo: 'INV-005',
                    invoiceDate: DateTime(2025, 4),
                    status: 'Sent',
                    supplier: const Supplier(),
                    receiver: const Receiver(),
                    items: const [
                      InvoiceItem(id: 'item-1', amount: 500, description: 'Test Item'),
                    ],
                  );
                  duplicatedResult = await InvoiceActions.duplicateInvoice(ref, orig);
                },
                child: const Text('Duplicate'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();

    expect(duplicatedResult, isNotNull);
    expect(duplicatedResult!.invoiceNo, equals('INV-006'));
    expect(duplicatedResult!.status, equals('Draft'));
    expect(duplicatedResult!.id, isNot(equals('orig-1')));
    expect(duplicatedResult!.items.length, equals(1));
    expect(duplicatedResult!.items.first.id, isNot(equals('item-1')));

    expect(fakeRepo.storedInvoices.length, equals(1));
    expect(fakeRepo.storedInvoices.first.invoiceNo, equals('INV-006'));
  });
}
