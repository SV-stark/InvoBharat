import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/gstr1_json_import_service.dart';

class MockInvoiceRepository implements InvoiceRepository {
  final List<Invoice> savedInvoices = [];

  @override
  Future<void> saveInvoice(final Invoice invoice) async {
    savedInvoices.add(invoice);
  }

  @override
  dynamic noSuchMethod(final Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Gstr1JsonImportService', () {
    late MockInvoiceRepository repo;

    setUp(() {
      repo = MockInvoiceRepository();
    });

    test('deduces GST rate from iamt and creates cess item if present', () async {
      final json = {
        'b2b': [
          {
            'ctin': '07AAAAA0000A1Z5',
            'inv': [
              {
                'inum': 'INV-100',
                'idt': '01-04-2025',
                'pos': '07',
                'itms': [
                  {
                    'num': 1,
                    'itm_det': {
                      'rt': 0, // 0 in json
                      'txval': 1000.0,
                      'iamt': 180.0, // 18% tax
                      'csamt': 50.0, // 50 cess
                    },
                  },
                ],
              },
            ],
          },
        ],
      };

      final result = await Gstr1JsonImportService.parseAndSaveJson(json, repo);

      expect(result.successCount, equals(1));
      expect(result.errorCount, equals(0));
      expect(repo.savedInvoices.length, equals(1));

      final inv = repo.savedInvoices.first;
      expect(inv.invoiceNo, equals('INV-100'));
      expect(inv.items.length, equals(2));

      // First item: Goods/Service with deduced 18% rate
      expect(inv.items[0].description, equals('Goods/Service'));
      expect(inv.items[0].amount, equals(1000.0));
      expect(inv.items[0].gstRate, equals(18.0));

      // Second item: Cess
      expect(inv.items[1].description, equals('Cess'));
      expect(inv.items[1].amount, equals(50.0));
      expect(inv.items[1].gstRate, equals(0.0));
    });

    test('gracefully ignores malformed or non-Map itms and non-Map b2b entries without throwing', () async {
      final json = {
        'b2b': [
          'corrupt string entry',
          42,
          {
            'ctin': '07AAAAA0000A1Z5',
            'inv': [
              'non-map invoice',
              {
                'inum': 'INV-SAFE-1',
                'idt': '01-04-2025',
                'pos': '07',
                'itms': [
                  'invalid-item-string',
                  null,
                  {
                    'num': 1,
                    'itm_det': {
                      'rt': 12.0,
                      'txval': 500.0,
                    },
                  },
                ],
              },
            ],
          },
        ],
      };

      final result = await Gstr1JsonImportService.parseAndSaveJson(json, repo);

      expect(result.successCount, equals(1));
      expect(repo.savedInvoices.length, equals(1));
      final inv = repo.savedInvoices.first;
      expect(inv.invoiceNo, equals('INV-SAFE-1'));
      expect(inv.items.length, equals(1));
      expect(inv.items.first.amount, equals(500.0));
      expect(inv.items.first.gstRate, equals(12.0));
    });
  });
}
