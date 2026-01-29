import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/pdf_generator.dart';
// Implicitly used by pdf_generator internal logic
// implicitly used

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generateInvoicePdf generates valid PDF for all templates', () async {
    // Basic setup
    final profile = BusinessProfile.defaults();
    final invoice = Invoice(
      id: '1',
      invoiceNo: 'INV-001',
      invoiceDate: DateTime.now(),
      items: [const InvoiceItem(description: 'Test', amount: 100)],
      supplier: const Supplier(state: 'Karnataka'),
      receiver: const Receiver(name: 'Test Client', state: 'Karnataka'),
    );

    // Test Minimal
    final minimalInvoice = invoice.copyWith(style: 'Minimal');
    final bytesMinimal = await generateInvoicePdf(minimalInvoice, profile);
    expect(bytesMinimal.length, greaterThan(0));
    expect(String.fromCharCodes(bytesMinimal).contains('%PDF'), isTrue);

    // Test Professional
    final profInvoice = invoice.copyWith(style: 'Professional');
    final bytesProf = await generateInvoicePdf(profInvoice, profile);
    expect(bytesProf.length, greaterThan(0));

    // Test Modern
    final modernInvoice = invoice.copyWith(style: 'Modern');
    final bytesModern = await generateInvoicePdf(modernInvoice, profile);
    expect(bytesModern.length, greaterThan(0));
  });
}
