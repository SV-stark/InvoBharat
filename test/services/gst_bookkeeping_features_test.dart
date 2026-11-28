import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/data/sql_business_profile_repository.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/database/database.dart' show AppDatabase;
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/enums.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/services/gstr3b_service.dart';
import 'package:invobharat/services/gstr_service.dart';
import 'package:invobharat/services/tally_xml_export_service.dart';
import 'package:invobharat/utils/einvoice_exporter.dart';
import 'package:invobharat/utils/gst_utils.dart';
import 'package:invobharat/utils/pdf/templates/classic_template.dart';
import 'package:invobharat/utils/pdf/templates/corporate_template.dart';
import 'package:invobharat/utils/pdf/templates/creative_template.dart';
import 'package:invobharat/utils/pdf/templates/minimal_template.dart';
import 'package:invobharat/utils/pdf/templates/modern_template.dart';
import 'package:invobharat/utils/pdf/templates/professional_template.dart';
import 'package:pdf/widgets.dart' as pw;

Invoice _makeInvoice({
  final String id = 'inv-1',
  final String invoiceNo = 'INV-001',
  final InvoiceType type = InvoiceType.invoice,
  final SupplyType supplyType = SupplyType.regular,
  final String supplierState = 'Maharashtra',
  final String supplierGstin = '27AABCU9603R1ZM',
  final String receiverState = 'Maharashtra',
  final String receiverGstin = '27AADCB2230M1Z2',
  final String placeOfSupply = 'Maharashtra',
  final String status = 'Sent',
  final double discountAmount = 0.0,
  final List<InvoiceItem>? items,
  final DateTime? date,
}) {
  return Invoice(
    id: id,
    profileId: 'prof-1',
    invoiceNo: invoiceNo,
    invoiceDate: date ?? DateTime(2026, 4, 15),
    type: type,
    supplyType: supplyType,
    status: status,
    discountAmount: discountAmount,
    placeOfSupply: placeOfSupply,
    supplier: Supplier(
      name: 'Acme Corp',
      address: '101 MG Road, Mumbai 400001',
      gstin: supplierGstin,
      state: supplierState,
    ),
    receiver: Receiver(
      name: 'Beta & Co <Tech>',
      address: '202 Park St, Mumbai 400002',
      gstin: receiverGstin,
      state: receiverState,
    ),
    items:
        items ??
        const [
          InvoiceItem(
            id: 'item-1',
            description: 'Consulting Services',
            sacCode: '998311',
            amount: 1000.0,
            unit: 'NOS',
          ),
        ],
  );
}

void main() {
  group('UTGST, Cess, Exports, SEZ & Composition', () {
    test('UTGST applies only to the 5 UTs without legislature', () {
      for (final code in ['04', '26', '31', '35', '38']) {
        expect(GstUtils.isUtgstState(code), isTrue, reason: 'code $code');
      }
      for (final code in ['07', '34', '01', '27', '29']) {
        expect(GstUtils.isUtgstState(code), isFalse, reason: 'code $code');
      }

      final chdInvoice = _makeInvoice(
        supplierState: 'Chandigarh',
        supplierGstin: '04AABCU9603R1ZM',
        receiverState: 'Chandigarh',
        receiverGstin: '04AADCB2230M1Z2',
        placeOfSupply: '04-Chandigarh',
      );
      expect(chdInvoice.isInterState, isFalse);
      expect(chdInvoice.isUtgstSupply, isTrue);
      expect(chdInvoice.stateTaxLabel, 'UTGST');

      final delhiInvoice = _makeInvoice(
        supplierState: 'Delhi',
        supplierGstin: '07AABCU9603R1ZM',
        receiverState: 'Delhi',
        receiverGstin: '07AADCB2230M1Z2',
        placeOfSupply: '07-Delhi',
      );
      expect(delhiInvoice.isUtgstSupply, isFalse);
      expect(delhiInvoice.stateTaxLabel, 'SGST');
    });

    test('Cess calculation with and without invoice-level discount proration', () {
      final noDiscount = _makeInvoice(
        items: const [
          InvoiceItem(
            id: 'i1',
            description: 'Aerated Water',
            sacCode: '2202',
            codeType: 'HSN',
            amount: 1000.0,
            gstRate: 28.0,
            cessRate: 12.0,
          ),
        ],
      );
      expect(noDiscount.totalTaxableValue, 1000.0);
      expect(noDiscount.totalCGST, 140.0);
      expect(noDiscount.totalSGST, 140.0);
      expect(noDiscount.totalCess, 120.0);
      expect(noDiscount.grandTotal, 1400.0);

      final withDiscount = noDiscount.copyWith(discountAmount: 100.0);
      expect(withDiscount.totalTaxableValue, 900.0);
      expect(withDiscount.totalCGST, 126.0);
      expect(withDiscount.totalSGST, 126.0);
      expect(withDiscount.totalCess, 108.0);
      expect(withDiscount.grandTotal, 1260.0);
    });

    test('Export/SEZ under LUT forces inter-state with 0 tax; With IGST charges IGST', () {
      final expLut = _makeInvoice(
        supplyType: SupplyType.exportWithLut,
        receiverGstin: '',
        receiverState: 'Outside India',
        items: const [
          InvoiceItem(
            id: 'i1',
            amount: 1000,
            gstRate: 18,
            cessRate: 5,
          ),
        ],
      );
      expect(expLut.isInterState, isTrue);
      expect(expLut.isTaxExemptSupply, isTrue);
      expect(expLut.totalIGST, 0.0);
      expect(expLut.totalCess, 0.0);
      expect(expLut.grandTotal, 1000.0);

      final expPay = expLut.copyWith(supplyType: SupplyType.exportWithPayment);
      expect(expPay.isInterState, isTrue);
      expect(expPay.isTaxExemptSupply, isFalse);
      expect(expPay.totalIGST, 180.0);
      expect(expPay.totalCess, 50.0);
      expect(expPay.grandTotal, 1230.0);

      final sezLut = expLut.copyWith(supplyType: SupplyType.sezWithLut);
      expect(sezLut.isTaxExemptSupply, isTrue);
      expect(sezLut.totalIGST, 0.0);

      final sezPay = expLut.copyWith(supplyType: SupplyType.sezWithPayment);
      expect(sezPay.isInterState, isTrue);
      expect(sezPay.totalIGST, 180.0);
    });

    test('Composition Bill of Supply enforces 0% GST', () {
      final bos = _makeInvoice(type: InvoiceType.billOfSupply);
      expect(bos.isTaxExemptSupply, isTrue);
      expect(bos.totalCGST, 0.0);
      expect(bos.totalSGST, 0.0);
      expect(bos.grandTotal, 1000.0);
    });
  });

  group('GSTR-1, GSTR-3B, E-Invoice & Tally XML', () {
    test('GSTR-1 Portal JSON includes exp, SEWP/SEWOP, csamt, and doc_issue with cancelled count', () {
      final activeB2B = _makeInvoice(
        id: '1',
        items: const [
          InvoiceItem(
            id: 'i1',
            description: 'Luxury Item',
            sacCode: '8703',
            codeType: 'HSN',
            amount: 1000,
            gstRate: 28,
            cessRate: 12,
          ),
        ],
      );
      final cancelled = _makeInvoice(
        id: '2',
        invoiceNo: 'INV-002',
        status: 'Cancelled',
      );
      final exportLut = _makeInvoice(
        id: '3',
        invoiceNo: 'INV-003',
        supplyType: SupplyType.exportWithLut,
        receiverGstin: '',
      );
      final sezPay = _makeInvoice(
        id: '4',
        invoiceNo: 'INV-004',
        supplyType: SupplyType.sezWithPayment,
      );

      final jsonStr = GstrService().generateGstr1PortalJson([
        activeB2B,
        cancelled,
        exportLut,
        sezPay,
      ]);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      final b2b = decoded['b2b'] as List<dynamic>;
      expect(b2b.length, 1);
      final invs = (b2b.first as Map<String, dynamic>)['inv'] as List<dynamic>;
      // Cancelled INV-002 excluded from B2B; INV-001 & INV-004 included
      expect(invs.length, 2);
      expect(invs[0]['itms'][0]['itm_det']['csamt'], 120.0);
      expect(invs[1]['inv_typ'], 'SEWP');

      final exp = decoded['exp'] as List<dynamic>;
      expect(exp.length, 1);
      expect(exp[0]['exp_typ'], 'WOPAY');
      expect(exp[0]['inv'][0]['inum'], 'INV-003');

      final docIssue = decoded['doc_issue']['doc_det'] as List<dynamic>;
      expect(docIssue.length, 1);
      expect(docIssue[0]['docs'][0]['totnum'], 4);
      expect(docIssue[0]['docs'][0]['cancel'], 1);
      expect(docIssue[0]['docs'][0]['net_issue'], 3);
    });

    test('GSTR-3B CSV includes Cess, 3.1(b) zero-rated, 3.1(c) exempt, and excludes cancelled', () {
      final inv = _makeInvoice(
        id: '1',
        items: const [
          InvoiceItem(id: 'i1', amount: 1000, gstRate: 28, cessRate: 12),
        ],
      );
      final exp = _makeInvoice(
        id: '2',
        invoiceNo: 'INV-002',
        supplyType: SupplyType.exportWithLut,
        receiverGstin: '',
      );
      final bos = _makeInvoice(
        id: '3',
        invoiceNo: 'INV-003',
        type: InvoiceType.billOfSupply,
      );
      final cancelled = _makeInvoice(
        id: '4',
        invoiceNo: 'INV-004',
        status: 'Cancelled',
      );

      final csv = Gstr3bService().generateGstr3bCsv([inv, exp, bos, cancelled]);
      expect(csv, contains('3.1(a) - Outward taxable supplies'));
      expect(csv, contains('3.1(b) - Zero rated supplies'));
      expect(csv, contains('3.1(c) - Nil rated / Exempt'));
      expect(csv, contains('120.00'));
      expect(csv.split('\n').where((final l) => l.trim().isNotEmpty).length, 4);
    });

    test('E-Invoice JSON includes CesRt, CesAmt, CesVal and SupTyp', () {
      final profile = BusinessProfile(
        id: 'prof-1',
        companyName: 'Acme Corp',
        address: '101 MG Road, Mumbai 400001',
        gstin: '27AABCU9603R1ZM',
        email: 'a@b.com',
        phone: '9999999999',
        state: 'Maharashtra',
      );
      final inv = _makeInvoice(
        supplyType: SupplyType.sezWithPayment,
        items: const [
          InvoiceItem(
            id: 'i1',
            description: 'Goods',
            sacCode: '8703',
            codeType: 'HSN',
            amount: 1000,
            gstRate: 28,
            cessRate: 12,
          ),
        ],
      );

      final decoded =
          jsonDecode(EInvoiceExporter.generateEInvoiceJson(inv, profile))
              as Map<String, dynamic>;
      expect(decoded['TranDtls']['SupTyp'], 'SEZWP');
      expect(decoded['ItemList'][0]['CesRt'], 12.0);
      expect(decoded['ItemList'][0]['CesAmt'], 120.0);
      expect(decoded['ValDtls']['CesVal'], 120.0);
      expect(decoded['ValDtls']['TotInvVal'], 1400.0);
    });

    test('Tally XML Export escapes XML, balances double-entry, supports UTGST/Cess & Cancelled', () {
      final utgstCessInv = _makeInvoice(
        id: '1',
        supplierState: 'Chandigarh',
        supplierGstin: '04AABCU9603R1ZM',
        receiverState: 'Chandigarh',
        receiverGstin: '04AADCB2230M1Z2',
        placeOfSupply: '04-Chandigarh',
        items: const [
          InvoiceItem(
            id: 'i1',
            amount: 1000,
            gstRate: 18,
            cessRate: 5,
          ),
        ],
      );
      final cancelledInv = _makeInvoice(
        id: '2',
        invoiceNo: 'INV-002',
        status: 'Cancelled',
      ).copyWith(cancellationReason: 'Wrong party');

      final xml = TallyXmlExportService().generateTallySalesXml([
        utgstCessInv,
        cancelledInv,
      ], companyName: 'Acme & Co');

      expect(xml, contains('<SVCURRENTCOMPANY>Acme &amp; Co</SVCURRENTCOMPANY>'));
      expect(xml, contains('Beta &amp; Co &lt;Tech&gt;'));
      expect(xml, contains('<LEDGERNAME>Output UTGST</LEDGERNAME>'));
      expect(xml, contains('<LEDGERNAME>Output GST Cess</LEDGERNAME>'));
      expect(xml, contains('<ISCANCELLED>Yes</ISCANCELLED>'));

      // Verify balanced ledger entries for INV-001
      final amounts = RegExp(r'<AMOUNT>(-?\d+\.\d+)</AMOUNT>')
          .allMatches(xml)
          .map((final m) => double.parse(m.group(1)!))
          .fold<double>(0.0, (final a, final b) => a + b);
      expect(amounts, closeTo(0.0, 0.001));
    });
  });

  group('Database Trash, Restore, Cancel & Period Lock', () {
    test('Soft-delete, restore, permanent delete, emptyTrash & cancelInvoice', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() async => db.close());

      final profileRepo = SqlBusinessProfileRepository(db);
      await profileRepo.saveProfile(
        BusinessProfile(
          id: 'prof-1',
          companyName: 'Test Biz',
          address: 'Addr',
          gstin: '27AABCU9603R1ZM',
          email: 'a@b.com',
          phone: '9999999999',
          state: 'Maharashtra',
        ),
      );

      final repo = SqlInvoiceRepository(db, 'prof-1');
      final inv1 = _makeInvoice();
      final inv2 = _makeInvoice(
        id: 'inv-2',
        invoiceNo: 'INV-002',
        items: const [
          InvoiceItem(
            id: 'item-2',
            description: 'Consulting Services',
            sacCode: '998311',
            amount: 1000.0,
            unit: 'NOS',
          ),
        ],
      );
      await repo.saveInvoice(inv1);
      await repo.saveInvoice(inv2);

      // Soft-delete inv-1
      await repo.deleteInvoice('inv-1');
      expect((await repo.getAllInvoices()).map((final i) => i.id), ['inv-2']);
      expect((await repo.getTrashedInvoices()).map((final i) => i.id), ['inv-1']);

      // Restore inv-1
      await repo.restoreInvoice('inv-1');
      expect((await repo.getAllInvoices()).length, 2);
      expect((await repo.getTrashedInvoices()).isEmpty, isTrue);

      // Cancel inv-2 (stays in active list with status Cancelled, preserving sequence)
      await repo.cancelInvoice('inv-2', reason: 'Duplicate');
      final fetched2 = await repo.getInvoice('inv-2');
      expect(fetched2?.isCancelled, isTrue);
      expect(fetched2?.cancellationReason, 'Duplicate');
      expect(
        await repo.getMaxSequenceForPrefix('INV-', invoiceDate: DateTime(2026, 4, 15)),
        2,
      );

      // Soft-delete and permanently delete
      await repo.deleteInvoice('inv-1');
      await repo.permanentlyDeleteInvoice('inv-1');
      expect((await repo.getTrashedInvoices()).isEmpty, isTrue);

      // Soft-delete inv-2 and emptyTrash
      await repo.deleteInvoice('inv-2');
      expect((await repo.getTrashedInvoices()).length, 1);
      await repo.emptyTrash();
      expect((await repo.getTrashedInvoices()).isEmpty, isTrue);
    });

    test('BusinessProfile.isDateLocked boundary checks', () {
      final profile = BusinessProfile.defaults().copyWith(
        booksLockedUntil: DateTime(2026, 3, 31),
      );
      expect(profile.isDateLocked(DateTime(2026, 3, 30)), isTrue);
      expect(profile.isDateLocked(DateTime(2026, 3, 31, 23, 59)), isTrue);
      expect(profile.isDateLocked(DateTime(2026, 4)), isFalse);
    });
  });

  group('PDF Templates Smoke Test', () {
    test('All 6 PDF templates generate bytes with copyType, watermarks, UTGST, Cess & declarations', () async {
      final font = pw.Font.helvetica();
      final fontBold = pw.Font.helveticaBold();
      final profile = BusinessProfile(
        id: 'prof-1',
        companyName: 'Test Biz',
        address: 'Chandigarh 160001',
        gstin: '04AABCU9603R1ZM',
        email: 'a@b.com',
        phone: '9999999999',
        state: 'Chandigarh',
        isCompositionDealer: true,
        lutNumber: 'AD0404260001',
        lutDate: DateTime(2026, 4),
      );
      final inv = _makeInvoice(
        status: 'Cancelled',
        supplyType: SupplyType.exportWithLut,
        supplierState: 'Chandigarh',
        supplierGstin: '04AABCU9603R1ZM',
        receiverState: 'Chandigarh',
        receiverGstin: '04AADCB2230M1Z2',
        placeOfSupply: '04-Chandigarh',
        items: const [
          InvoiceItem(
            id: 'i1',
            description: 'Item A',
            sacCode: '998311',
            amount: 1000,
            cessRate: 5,
          ),
        ],
      );

      final templates = [
        ModernTemplate(),
        ProfessionalTemplate(),
        MinimalTemplate(),
        ClassicTemplate(),
        CorporateTemplate(),
        CreativeTemplate(),
      ];

      for (final template in templates) {
        final bytes = await template.generate(
          inv,
          profile,
          font,
          fontBold,
          copyType: InvoiceCopyType.original,
        );
        expect(bytes.length, greaterThan(500), reason: template.name);
      }
    });
  });
}
