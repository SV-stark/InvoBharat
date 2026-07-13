import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/gstr_service.dart';

void main() {
  test('generateGstr1Csv produces correct CSV format', () {
    final invoice = Invoice(
      id: '1',
      invoiceNo: 'INV-001',
      invoiceDate: DateTime(2025, 4),
      supplier: const Supplier(state: 'Karnataka'),
      receiver: const Receiver(
        name: 'John Doe',
        state: 'Karnataka',
        gstin: '29ABCDE1234F1Z3',
      ),
      items: [
        const InvoiceItem(
          description: 'Item 1',
          sacCode: '998311',
          amount: 1000,
          quantity: 2,
        ), // 2000 taxable. CGST 180, SGST 180. Total 2360.
      ],
    );

    final csv = GstrService().generateGstr1Csv([invoice]);

    // Check Header
    expect(
      csv,
      contains(
        'GSTIN(recipeint),Trade Name(recipeint),Invoice No,Date of Invoice,Invoice Value,GST%,Taxable Value,CESS,Place Of Supply,RCM Applicable,HSN Details,HSN Description,type',
      ),
    );

    // Check Row Content (Expect HSN Details, HSN Description, and type (B2B))
    expect(
      csv,
      contains(
        '29ABCDE1234F1Z3,John Doe,INV-001,01-04-2025,2360.00,18.00,2000.00,0.00,Karnataka,N,998311,Item 1,B2B',
      ),
    );
  });

  test('generateGstr1Csv produces B2C type for invoices without GSTIN', () {
    final invoice = Invoice(
      id: '2',
      invoiceNo: 'INV-002',
      invoiceDate: DateTime(2025, 4),
      supplier: const Supplier(state: 'Karnataka'),
      receiver: const Receiver(
        name: 'Jane Doe',
        state: 'Karnataka',
        gstin: '',
      ),
      items: [
        const InvoiceItem(
          description: 'Item 2',
          sacCode: '998312',
          amount: 500,
          quantity: 1,
        ),
      ],
    );

    final csv = GstrService().generateGstr1Csv([invoice]);

    expect(
      csv,
      contains(
        ',Jane Doe,INV-002,01-04-2025,590.00,18.00,500.00,0.00,Karnataka,N,998312,Item 2,B2C',
      ),
    );
  });
}
