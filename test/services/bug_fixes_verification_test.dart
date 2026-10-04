import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/database/database.dart' hide Invoice, InvoiceItem;
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/update_service.dart';
import 'package:invobharat/services/gstr_service.dart';
import 'package:invobharat/services/csv_export_service.dart';
import 'package:invobharat/services/invoice_import_service.dart';
import 'package:invobharat/providers/invoice_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';

import 'package:invobharat/data/sql_business_profile_repository.dart';
import 'package:invobharat/models/business_profile.dart' as model_bp;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Verified Defect Fixes Suite', () {
    late AppDatabase db;
    late SqlInvoiceRepository repo;
    const profileId = 'test_prof_fixes';

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      // Seed business profile via repository so all defaults and FKs are satisfied
      final profileRepo = SqlBusinessProfileRepository(db);
      await profileRepo.saveProfile(
        model_bp.BusinessProfile(
          id: profileId,
          companyName: 'Acme Corp',
          address: '123 Street',
          gstin: '07AAAAA0000A1Z5',
          email: 'acme@example.com',
          phone: '9876543210',
        ),
      );
      repo = SqlInvoiceRepository(db, profileId);
    });

    tearDown(() async {
      await db.close();
    });

    test('P0 #2: FY-scoped invoice numbering allows same invoice number in different financial years', () async {
      final invFY24 = Invoice(
        id: 'inv_fy24',
        profileId: profileId,
        invoiceNo: 'INV-001',
        invoiceDate: DateTime(2024, 6, 15), // FY 2024-25
        supplier: const Supplier(name: 'Supplier', state: 'Delhi'),
        receiver: const Receiver(name: 'Client A', state: 'Delhi'),
        items: [const InvoiceItem(description: 'Item 1', amount: 100)],
      );

      final invFY25 = Invoice(
        id: 'inv_fy25',
        profileId: profileId,
        invoiceNo: 'INV-001',
        invoiceDate: DateTime(2025, 6, 15), // FY 2025-26
        supplier: const Supplier(name: 'Supplier', state: 'Delhi'),
        receiver: const Receiver(name: 'Client B', state: 'Delhi'),
        items: [const InvoiceItem(description: 'Item 2', amount: 200)],
      );

      // Both must save without throwing UNIQUE constraint violation
      await repo.saveInvoice(invFY24);
      await repo.saveInvoice(invFY25);

      final loaded24 = await repo.getInvoice('inv_fy24');
      final loaded25 = await repo.getInvoice('inv_fy25');

      expect(loaded24, isNotNull);
      expect(loaded24!.invoiceNo, 'INV-001');
      expect(loaded25, isNotNull);
      expect(loaded25!.invoiceNo, 'INV-001');
      expect(loaded24.receiver.name, 'Client A');
      expect(loaded25.receiver.name, 'Client B');
    });

    test('P1 #5 & #7: Discount, currency, isArchived, and supplier.state are persisted and reloaded', () async {
      final invoice = Invoice(
        id: 'inv_extra_fields',
        profileId: profileId,
        invoiceNo: 'INV-999',
        invoiceDate: DateTime(2025, 5, 10),
        supplier: const Supplier(name: 'Supplier XYZ', state: 'Haryana'),
        receiver: const Receiver(name: 'Client XYZ', state: 'Punjab'),
        discountAmount: 150.0,
        currency: 'USD',
        isArchived: true,
        deliveryAddress: 'Ship To Warehouse 42',
        items: [const InvoiceItem(description: 'Product 1', amount: 1000)],
      );

      await repo.saveInvoice(invoice);
      final reloaded = await repo.getInvoice('inv_extra_fields');

      expect(reloaded, isNotNull);
      expect(reloaded!.discountAmount, 150.0);
      expect(reloaded.currency, 'USD');
      expect(reloaded.isArchived, true);
      expect(reloaded.deliveryAddress, 'Ship To Warehouse 42');
      expect(reloaded.supplier.state, 'Haryana');
      expect(reloaded.isInterState, true); // Haryana to Punjab
    });

    test('P1 #8: Ledger exactMatch prevents client substring collision', () async {
      final invSharma = Invoice(
        id: 'inv_sharma_1',
        profileId: profileId,
        invoiceNo: 'INV-S-01',
        invoiceDate: DateTime(2025, 5),
        supplier: const Supplier(name: 'Supplier'),
        receiver: const Receiver(name: 'Sharma'),
        items: [const InvoiceItem(amount: 500)],
      );

      final invSharmaTextiles = Invoice(
        id: 'inv_sharma_2',
        profileId: profileId,
        invoiceNo: 'INV-S-02',
        invoiceDate: DateTime(2025, 5, 2),
        supplier: const Supplier(name: 'Supplier'),
        receiver: const Receiver(name: 'Sharma Textiles Pvt Ltd'),
        items: [const InvoiceItem(amount: 1500)],
      );

      await repo.saveInvoice(invSharma);
      await repo.saveInvoice(invSharmaTextiles);

      // Exact match for "Sharma" must only return invSharma
      final sharmaOnly = await repo.getInvoicesForClient(
        query: 'Sharma',
        exactMatch: true,
      );
      expect(sharmaOnly.length, 1);
      expect(sharmaOnly.first.receiver.name, 'Sharma');
      expect(sharmaOnly.first.id, 'inv_sharma_1');

      // Non-exact match returns both
      final allSharma = await repo.getInvoicesForClient(
        query: 'Sharma',
      );
      expect(allSharma.length, 2);
    });

    test('P1 #9: GSTR-1 CSV writes invoiceValue only once per multi-item invoice', () {
      final multiItemInvoice = Invoice(
        id: 'inv_multi_item',
        invoiceNo: 'INV-M-01',
        invoiceDate: DateTime(2025, 5),
        status: 'Sent',
        supplier: const Supplier(gstin: '07AAAAA0000A1Z5'),
        receiver: const Receiver(gstin: '07BBBBB1111B1Z1', name: 'Buyer', state: 'Delhi'),
        placeOfSupply: 'Delhi',
        items: [
          const InvoiceItem(description: 'Item 1', amount: 1000),
          const InvoiceItem(description: 'Item 2', amount: 500),
        ],
      );

      final csvData = GstrService().generateGstr1Csv([multiItemInvoice]);
      final lines = csvData.trim().split('\r\n');
      final effectiveLines = lines.length > 1 ? lines : csvData.trim().split('\n');
      expect(effectiveLines.length, 3); // header + 2 items

      final row1 = effectiveLines[1].split(',');
      final row2 = effectiveLines[2].split(',');

      // Grand total should appear in row 1, but 0.0 in row 2
      final invoiceValueIdx = 4; // 'Invoice Value' is column index 4
      expect(double.parse(row1[invoiceValueIdx]), closeTo(1770.0, 0.1));
      expect(double.parse(row2[invoiceValueIdx]), 0.0);
    });

    test('P1 #16: Semver comparison handles v-prefixes and two-digit subversions', () {
      expect(UpdateService.isNewerVersion('0.10.0', '0.9.0'), isTrue);
      expect(UpdateService.isNewerVersion('v1.2.0', '1.2.0'), isFalse);
      expect(UpdateService.isNewerVersion('v1.2.1', '1.2.0'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.0', '1.0.1'), isFalse);
      expect(UpdateService.isNewerVersion('2.0.0-beta', '1.9.9'), isTrue);
    });

    test('P2 #25: InvoiceNotifier guards against out-of-bounds item indices', () {
      final container = ProviderContainer(
        overrides: [
          businessProfileProvider.overrideWithValue(
            model_bp.BusinessProfile(
              id: profileId,
              companyName: 'Acme Corp',
              address: '123 Street',
              gstin: '07AAAAA0000A1Z5',
              email: 'acme@example.com',
              phone: '9876543210',
            ),
          ),
        ],
      );
      final notifier = container.read(invoiceProvider.notifier);
      // Should not throw RangeError on invalid index
      notifier.updateItemDescription(99, 'Test');
      notifier.updateItemAmount(-1, '500');
      notifier.updateItemGstRate(5, '18');
      notifier.removeItem(10);
      notifier.updateDiscountAmount('-50');
      expect(container.read(invoiceProvider).discountAmount, 0.0); // Clamped to non-negative
      container.dispose();
    });

    test('P2 #29: InvoiceImportService unescapes formula injection and enforces row bounds', () async {
      final exportedCsv = await CsvExportService().generateInvoiceCsv([
        Invoice(
          id: 'inv_sec_01',
          profileId: profileId,
          invoiceNo: 'INV-SEC-01',
          invoiceDate: DateTime(2025, 5, 15),
          supplier: const Supplier(name: 'Supplier', gstin: '07AAAAA0000A1Z5'),
          receiver: const Receiver(
            name: "=cmd|' /C calc!A0", // Formula injection attempt
            gstin: '07BBBBB1111B1Z1',
            address: 'Test Address',
            state: 'Delhi',
          ),
          items: [const InvoiceItem(description: 'Item', amount: 100)],
        ),
      ]);

      final result = await InvoiceImportService.importCsvContent(
        exportedCsv,
        repo,
      );

      expect(result.successCount, 1);
      final all = await repo.getAllInvoices();
      expect(all.length, 1);
      final imported = all.first;
      expect(imported.invoiceNo, 'INV-SEC-01');
      // Formula escape was sanitized on export and cleanly unescaped on import
      expect(imported.receiver.name, "=cmd|' /C calc!A0");
    });
  });
}
