import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/gstr_service.dart';

void main() {
  test('generateGstr1Csv produces correct CSV format', () {
    final invoice = Invoice(
      id: '1',
      invoiceNo: 'INV-001',
      status: 'Sent',
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
        'GSTIN(recipeint),Trade Name(recipeint),Invoice No,Date of Invoice,Invoice Value,GST%,Taxable Value,CGST,SGST,IGST,CESS,Place Of Supply,RCM Applicable,HSN Details,HSN Description,type',
      ),
    );

    // Check Row Content (Expect HSN Details, HSN Description, and type (B2B))
    expect(
      csv,
      contains(
        '29ABCDE1234F1Z3,John Doe,INV-001,01-04-2025,2360.00,18.00,2000.00,180.00,180.00,0.00,0.00,29-Karnataka,N,998311,Item 1,B2B',
      ),
    );
  });

  test('generateGstr1Csv produces B2C type for invoices without GSTIN', () {
    final invoice = Invoice(
      id: '2',
      invoiceNo: 'INV-002',
      status: 'Sent',
      invoiceDate: DateTime(2025, 4),
      supplier: const Supplier(state: 'Karnataka'),
      receiver: const Receiver(name: 'Jane Doe', state: 'Karnataka'),
      items: [
        const InvoiceItem(
          description: 'Item 2',
          sacCode: '998312',
          amount: 500,
        ),
      ],
    );

    final csv = GstrService().generateGstr1Csv([invoice]);

    expect(
      csv,
      contains(
        ',Jane Doe,INV-002,01-04-2025,590.00,18.00,500.00,45.00,45.00,0.00,0.00,29-Karnataka,N,998312,Item 2,B2C',
      ),
    );
  });

  test(
    'generateGstr1Csv calculates IGST correctly for inter-state transactions',
    () {
      final invoice = Invoice(
        id: '3',
        invoiceNo: 'INV-003',
        status: 'Sent',
        invoiceDate: DateTime(2025, 4),
        placeOfSupply: 'Maharashtra',
        supplier: const Supplier(state: 'Karnataka'),
        receiver: const Receiver(
          name: 'Maharashtra Client',
          state: 'Maharashtra',
          gstin: '27ABCDE1234F1Z3',
        ),
        items: [
          const InvoiceItem(
            description: 'Item 3',
            sacCode: '998313',
            amount: 1000,
          ),
        ],
      );

      final csv = GstrService().generateGstr1Csv([invoice]);

      expect(
        csv,
        contains(
          '27ABCDE1234F1Z3,Maharashtra Client,INV-003,01-04-2025,1180.00,18.00,1000.00,0.00,0.00,180.00,0.00,27-Maharashtra,N,998313,Item 3,B2B',
        ),
      );
    },
  );

  test(
    'generateGstr1Csv includes Draft invoices but excludes deliveryChallan and cancelled/void',
    () {
      final draftInvoice = Invoice(
        id: 'draft-1',
        invoiceNo: 'INV-DRAFT',
        invoiceDate: DateTime(2025, 4),
        supplier: const Supplier(state: 'Karnataka'),
        receiver: const Receiver(name: 'Draft Client', state: 'Karnataka'),
        items: [const InvoiceItem(description: 'Service', amount: 1000)],
      );

      final cancelledInvoice = Invoice(
        id: 'cancelled-1',
        invoiceNo: 'INV-CANCELLED',
        status: 'Cancelled',
        invoiceDate: DateTime(2025, 4),
        supplier: const Supplier(state: 'Karnataka'),
        receiver: const Receiver(name: 'Cancelled Client', state: 'Karnataka'),
        items: [const InvoiceItem(description: 'Service', amount: 1000)],
      );

      final voidInvoice = Invoice(
        id: 'void-1',
        invoiceNo: 'INV-VOID',
        status: 'Void',
        invoiceDate: DateTime(2025, 4),
        supplier: const Supplier(state: 'Karnataka'),
        receiver: const Receiver(name: 'Void Client', state: 'Karnataka'),
        items: [const InvoiceItem(description: 'Service', amount: 1000)],
      );

      final challanInvoice = Invoice(
        id: 'challan-1',
        invoiceNo: 'DC-001',
        type: InvoiceType.deliveryChallan,
        status: 'Sent',
        invoiceDate: DateTime(2025, 4),
        supplier: const Supplier(state: 'Karnataka'),
        receiver: const Receiver(name: 'Challan Client', state: 'Karnataka'),
        items: [const InvoiceItem(description: 'Service', amount: 1000)],
      );

      final csv = GstrService().generateGstr1Csv([
        draftInvoice,
        cancelledInvoice,
        voidInvoice,
        challanInvoice,
      ]);

      expect(csv, contains('INV-DRAFT'));
      expect(csv, isNot(contains('INV-CANCELLED')));
      expect(csv, isNot(contains('INV-VOID')));
      expect(csv, isNot(contains('DC-001')));
    },
  );
}
