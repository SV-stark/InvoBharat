import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/gstr_service.dart';

void main() {
  test('generateGstr1Csv produces correct CSV format', () {
    final invoice = Invoice(
      id: '1',
      invoiceNo: 'INV-001',
      invoiceDate: DateTime(2025, 4, 1),
      supplier: const Supplier(state: 'Karnataka'),
      receiver: const Receiver(
          name: 'John Doe', state: 'Karnataka', gstin: '29ABCDE1234F1Z5'),
      items: [
        const InvoiceItem(
          description: 'Item 1',
          amount: 1000,
          quantity: 2,
          gstRate: 18,
        ) // 2000 taxable. CGST 180, SGST 180. Total 2360.
      ],
    );

    final csv = GstrService().generateGstr1Csv([invoice]);

    // Check Header
    expect(
        csv,
        contains(
            'GSTIN/UIN,Trade Name,Invoice No,Date of Invoice,Invoice Value,GST%,Taxable Value,CESS,Place Of Supply,RCM Applicable'));

    // Check Row Content
    expect(
        csv,
        contains(
            '29ABCDE1234F1Z5,John Doe,INV-001,01-04-2025,2360.00,18.00,2000.00,0.00,Karnataka,N'));
  });
}
