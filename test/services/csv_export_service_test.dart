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
      supplier: const Supplier(name: 'My Biz', gstin: '27AAAAA0000A1Z5'),
      receiver: const Receiver(name: 'Client A', gstin: '27BBBBB0000B1Z5'),
      items: [
        const InvoiceItem(
          description: 'Item 1',
          amount: 100,
          quantity: 2,
          gstRate: 18,
        ),
      ],
    );

    test('generateInvoiceCsv should create valid header and rows', () {
      final csv = csvService.generateInvoiceCsv([invoice]);

      expect(csv, contains('GSTIN/UIN Of Supplier,Trade Name,Invoice No'));
      expect(
        csv,
        contains(
          '27AAAAA0000A1Z5,My Biz,INV-001,27-10-2023,236.00,18.0,200.00',
        ),
      );
    });

    test('parseInvoiceCsv should reconstruct invoice correctly', () {
      final csv = csvService.generateInvoiceCsv([invoice]);
      final parsed = csvService.parseInvoiceCsv(csv);

      expect(parsed.length, 1);
      expect(parsed.first.invoiceNo, 'INV-001');
      expect(parsed.first.items.first.description, 'Item 1');
      expect(parsed.first.items.first.quantity, 2);
    });

    test('escaping logic in CSV', () {
      final complexInvoice = invoice.copyWith(
        comments: 'Notes with , comma and "quotes"',
      );
      final csv = csvService.generateInvoiceCsv([complexInvoice]);
      expect(csv, contains('"Notes with , comma and ""quotes"""'));

      final parsed = csvService.parseInvoiceCsv(csv);
      expect(parsed.first.comments, 'Notes with , comma and "quotes"');
    });

    test('restore multiple items same invoice', () {
      final multiItem = invoice.copyWith(
        items: [
          const InvoiceItem(description: 'Item A', amount: 50),
          const InvoiceItem(description: 'Item B', amount: 30),
        ],
      );
      final csv = csvService.generateInvoiceCsv([multiItem]);
      final parsed = csvService.parseInvoiceCsv(csv);

      expect(parsed.length, 1);
      expect(parsed.first.items.length, 2);
      expect(parsed.first.items[0].description, 'Item A');
      expect(parsed.first.items[1].description, 'Item B');
    });
  });
}
