import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/csv_export_service.dart';

void main() {
  late CsvExportService csvService;

  setUp(() {
    csvService = CsvExportService();
  });

  group('CsvExportService', () {
    final now = DateTime(2023, 10, 27);
    final invoice = Invoice(
      id: 'inv1',
      invoiceNo: 'INV-001',
      invoiceDate: now,
      supplier: const Supplier(name: 'My Biz', gstin: '27AAAAA0000A1Z6'),
      receiver: const Receiver(name: 'Client A', gstin: '27BBBBB0000B1ZX'),
      items: [
        const InvoiceItem(description: 'Item 1', amount: 100, quantity: 2),
      ],
    );

    test('generateInvoiceCsv should create valid header and rows', () async {
      final csv = await csvService.generateInvoiceCsv([invoice]);

      expect(csv, contains('GSTIN/UIN Of Supplier,Trade Name,Invoice No'));
      expect(
        csv,
        contains(
          '27AAAAA0000A1Z6,My Biz,INV-001,27-10-2023,236.00,18.0,200.00',
        ),
      );
    });

    test('parseInvoiceCsv should reconstruct invoice correctly', () async {
      final csv = await csvService.generateInvoiceCsv([invoice]);
      final parsed = await csvService.parseInvoiceCsv(csv);

      expect(parsed.length, 1);
      expect(parsed.first.invoiceNo, 'INV-001');
      expect(parsed.first.items.first.description, 'Item 1');
      expect(parsed.first.items.first.quantity, 2);
    });

    test('escaping logic in CSV', () async {
      final complexInvoice = invoice.copyWith(
        comments: 'Notes with , comma and "quotes"',
      );
      final csv = await csvService.generateInvoiceCsv([complexInvoice]);
      expect(csv, contains('"Notes with , comma and ""quotes"""'));

      final parsed = await csvService.parseInvoiceCsv(csv);
      expect(parsed.first.comments, 'Notes with , comma and "quotes"');
    });

    test('restore multiple items same invoice', () async {
      final multiItem = invoice.copyWith(
        items: [
          const InvoiceItem(description: 'Item A', amount: 50),
          const InvoiceItem(description: 'Item B', amount: 30),
        ],
      );
      final csv = await csvService.generateInvoiceCsv([multiItem]);
      final parsed = await csvService.parseInvoiceCsv(csv);

      expect(parsed.length, 1);
      expect(parsed.first.items.length, 2);
      expect(parsed.first.items[0].description, 'Item A');
      expect(parsed.first.items[1].description, 'Item B');
    });

    test(
      'interstate calculation is preserved after export and re-import',
      () async {
        // Supplier in MH (27), Receiver in DL (07)
        final interstateInvoice = Invoice(
          id: 'inv2',
          invoiceNo: 'INV-002',
          invoiceDate: now,
          placeOfSupply: 'Delhi',
          supplier: const Supplier(
            name: 'MH Biz',
            gstin: '27AAAAA0000A1Z6',
            state: 'Maharashtra',
          ),
          receiver: const Receiver(
            name: 'DL Client',
            gstin: '07BBBBB0000B1ZX',
            state: 'Delhi',
          ),
          items: [
            const InvoiceItem(description: 'Item Interstate', amount: 1000),
          ],
        );

        expect(interstateInvoice.isInterState, isTrue);
        expect(interstateInvoice.totalIGST, 180.0);

        final csv = await csvService.generateInvoiceCsv([interstateInvoice]);
        final parsed = await csvService.parseInvoiceCsv(csv);

        expect(parsed.length, 1);
        final restored = parsed.first;
        expect(restored.supplier.state, 'Maharashtra');
        expect(restored.isInterState, isTrue);
        expect(restored.totalIGST, 180.0);
        expect(restored.totalCGST, 0.0);
        expect(restored.totalSGST, 0.0);
      },
    );
  });
}
