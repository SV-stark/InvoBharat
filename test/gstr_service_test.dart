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
        InvoiceItem(
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
            'Invoice No,Invoice Date,Receiver Name,GSTIN,State,Taxable Value,IGST,CGST,SGST,Total Invoice Value'));

    // Check Row Content
    expect(
        csv,
        contains(
            'INV-001,01-04-2025,John Doe,29ABCDE1234F1Z5,Karnataka,2000.00,0.00,180.00,180.00,2360.00'));
  });
}
