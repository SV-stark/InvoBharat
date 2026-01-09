import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/services/gstr_import_service.dart';

void main() {
  final service = GstrImportService();

  test('parseGstr1Csv parses single invoice correctly', () {
    const csv =
        '''GSTIN(recipeint),Trade Name(recipeint),Invoice No,Date of Invoice,Invoice Value,GST%,Taxable Value,CESS,Place Of Supply,RCM Applicable,HSN Description
29ABC,Test Client,INV-001,01-04-2025,1180.00,18.00,1000.00,0.00,Karnataka,N,Item A''';

    final result = service.parseGstr1Csv(csv);

    expect(result.invoices.length, 1);
    final inv = result.invoices.first;
    expect(inv.invoiceNo, 'INV-001');
    expect(inv.receiver.name, 'Test Client');
    expect(inv.items.length, 1);
    expect(inv.items.first.description, 'Item A');
    expect(inv.items.first.amount, 1000.0);
  });

  test('parseGstr1Csv groups multiple items for same invoice', () {
    const csv =
        '''GSTIN,Name,Invoice No,Date,Value,GST%,Taxable,CESS,Place,RCM,HSN
29ABC,Client,INV-001,01-04-2025,2360,18,1000,0,KA,N,Item 1
29ABC,Client,INV-001,01-04-2025,2360,18,1000,0,KA,N,Item 2''';

    final result = service.parseGstr1Csv(csv);

    expect(result.invoices.length, 1);
    final inv = result.invoices.first;
    expect(inv.invoiceNo, 'INV-001');
    expect(inv.items.length, 2);
    expect(inv.items[0].description, 'Item 1');
    expect(inv.items[1].description, 'Item 2');
    expect(inv.grandTotal, 2360.0); // 1000+180 + 1000+180
  });

  test('detects missing sequences', () {
    const csv =
        '''GSTIN,Name,Invoice No,Date,Value,GST%,Taxable,CESS,Place,RCM,HSN
29ABC,Client,INV-001,01-04-2025,118,18,100,0,KA,N,Item 1
29ABC,Client,INV-003,01-04-2025,118,18,100,0,KA,N,Item 1''';

    final result = service.parseGstr1Csv(csv);

    expect(result.invoices.length, 2);
    expect(
        result.missingInvoiceNumbers,
        contains(
            'INV-2')); // Sequence gap logic usually returns plain missing number
  });
}
