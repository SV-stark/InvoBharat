import 'package:flutter_test/flutter_test.dart';
import 'package:excel/excel.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/excel_export_service.dart';

void main() {
  late ExcelExportService excelService;

  setUp(() {
    excelService = ExcelExportService();
  });

  group('ExcelExportService', () {
    final now = DateTime(2026, 7, 22);
    final invoice = Invoice(
      id: 'inv1',
      invoiceNo: 'INV-2026-001',
      invoiceDate: now,
      supplier: const Supplier(name: 'InvoBharat Corp', gstin: '27AAAAA0000A1Z6'),
      receiver: const Receiver(name: 'Acme Pvt Ltd', gstin: '27BBBBB0000B1ZX'),
      items: [
        const InvoiceItem(
          description: 'Consulting Services',
          sacCode: '998311',
          amount: 1000,
          quantity: 2,
        ),
      ],
    );

    test('generateInvoiceExcel generates valid non-empty byte buffer with sheets', () async {
      final bytes = await excelService.generateInvoiceExcel([invoice]);
      expect(bytes, isNotEmpty);

      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.keys, contains('Invoices Summary'));
      expect(excel.tables.keys, contains('Itemized Details'));
      expect(excel.tables.keys, contains('GSTR1 B2B Summary'));

      final summarySheet = excel.tables['Invoices Summary'];
      expect(summarySheet, isNotNull);
      expect(summarySheet!.maxRows, greaterThanOrEqualTo(2));
    });
  });
}
