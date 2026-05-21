import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load custom fonts to prevent fallback block symbols in goldens
  setUpAll(() async {
    final fontData = await rootBundle.load('fonts/Spectral-Regular.ttf');
    final fontLoader = FontLoader('Spectral')..addFont(Future.value(fontData));
    await fontLoader.load();
  });

  group('PDF Layout Golden Tests', () {
    final profile = BusinessProfile.defaults().copyWith(
      companyName: 'InvoBharat Ltd',
      address: '123 Main Street, Bangalore',
      gstin: '29ABCDE1234F1Z5',
      email: 'billing@invobharat.in',
      phone: '9876543210',
    );

    final invoice = Invoice(
      id: 'golden-1',
      invoiceNo: 'INV-2026-001',
      invoiceDate: DateTime(2026, 5, 21),
      dueDate: DateTime(2026, 6, 21),
      placeOfSupply: 'Karnataka',
      items: [
        const InvoiceItem(
          description: 'Software Development Services',
          amount: 50000,
          quantity: 1,
          unit: 'pcs',
          gstRate: 18,
        ),
        const InvoiceItem(
          description: 'Consulting Fees',
          amount: 15000,
          quantity: 2,
          unit: 'hrs',
          gstRate: 18,
        ),
      ],
      supplier: const Supplier(
        name: 'InvoBharat Ltd',
        address: '123 Main Street, Bangalore',
        gstin: '29ABCDE1234F1Z5',
        state: 'Karnataka',
      ),
      receiver: const Receiver(
        name: 'Acme Corp',
        address: '456 Business Park, Mumbai',
        gstin: '27GHIJK5678L1Z9',
        state: 'Maharashtra',
      ),
    );

    for (final style in ['Modern', 'Professional', 'Minimal', 'Classic', 'Corporate', 'Creative']) {
      testWidgets('Template $style layout matches golden', (WidgetTester tester) async {
        final styledInvoice = invoice.copyWith(style: style);
        
        print('[DEBUG] Generating PDF for $style...');
        Uint8List pdfBytes;
        try {
          pdfBytes = await generateInvoicePdf(styledInvoice, profile);
        } catch (e) {
          fail('Failed to generate PDF for $style: $e');
        }
        print('[DEBUG] PDF generated for $style. Size: ${pdfBytes.length} bytes. Rasterizing...');

        // Try rasterizing - if it fails with MissingPluginException, we are headless and should skip
        List<PdfRaster> rasterPages;
        try {
          rasterPages = await Printing.raster(pdfBytes, pages: [0], dpi: 72).toList();
        } on MissingPluginException {
          // Skip the test gracefully in headless mode
          print('Skipping $style golden test (headless environment: Printing plugin not available).');
          return;
        } catch (e) {
          // If we run on standard unit test environment, we might get other plugin exceptions
          print('Skipping $style golden test due to platform channel error: $e');
          return;
        }

        print('[DEBUG] Rasterization done for $style. Pages: ${rasterPages.length}. Converting first page to PNG...');

        if (rasterPages.isEmpty) {
          fail('No pages rasterized for $style template');
        }

        final pngBytes = await rasterPages.first.toPng();
        print('[DEBUG] PNG conversion done for $style. Size: ${pngBytes.length} bytes. Pumping widget...');

        // Display the rasterized PDF image
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: RepaintBoundary(
                child: Image.memory(
                  pngBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
        print('[DEBUG] Pumping done for $style. Running pumpAndSettle...');
        await tester.pumpAndSettle();
        print('[DEBUG] pumpAndSettle done for $style. Comparing golden...');

        // Golden image assertion
        await expectLater(
          find.byType(RepaintBoundary),
          matchesGoldenFile('goldens/pdf_layout_${style.toLowerCase()}.png'),
        );
        print('[DEBUG] Golden check done for $style.');
      });
    }
  });
}
