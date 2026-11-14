import 'dart:isolate';
import 'dart:typed_data';
import 'package:excel_plus/excel_plus.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path/path.dart' as p;
import 'package:invobharat/models/invoice.dart';

class ExcelExportService {
  /// Generates a professional multi-tab Excel (.xlsx) workbook for invoices
  Future<List<int>> generateInvoiceExcel(final List<Invoice> invoices) async {
    return Isolate.run(() => _generateInvoiceExcelSync(invoices));
  }

  static List<int> _generateInvoiceExcelSync(final List<Invoice> invoices) {
    final excel = Excel.createExcel();

    // Rename default sheet to 'Invoices Summary'
    final String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(defaultSheet, 'Invoices Summary');
    final Sheet summarySheet = excel['Invoices Summary'];

    // 1. Invoices Summary Sheet
    final List<CellValue> summaryHeader = [
      TextCellValue('Invoice No'),
      TextCellValue('Date'),
      TextCellValue('Due Date'),
      TextCellValue('Receiver Name'),
      TextCellValue('Receiver GSTIN'),
      TextCellValue('Place of Supply'),
      TextCellValue('Reverse Charge'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Grand Total (₹)'),
      TextCellValue('Total Paid (₹)'),
      TextCellValue('Balance Due (₹)'),
      TextCellValue('Status'),
    ];
    summarySheet.appendRow(summaryHeader);

    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

    double totalTaxableSum = 0;
    double totalCgstSum = 0;
    double totalSgstSum = 0;
    double totalIgstSum = 0;
    double grandTotalSum = 0;

    for (final inv in invoices) {
      totalTaxableSum += inv.totalTaxableValue;
      totalCgstSum += inv.totalCGST;
      totalSgstSum += inv.totalSGST;
      totalIgstSum += inv.totalIGST;
      grandTotalSum += inv.grandTotal;

      summarySheet.appendRow([
        TextCellValue(inv.invoiceNo),
        TextCellValue(dateFormat.format(inv.invoiceDate)),
        TextCellValue(
          inv.dueDate != null ? dateFormat.format(inv.dueDate!) : '-',
        ),
        TextCellValue(inv.receiver.name),
        TextCellValue(
          inv.receiver.gstin.isNotEmpty ? inv.receiver.gstin : 'URP',
        ),
        TextCellValue(inv.placeOfSupply),
        TextCellValue(inv.reverseCharge),
        DoubleCellValue(inv.totalTaxableValue),
        DoubleCellValue(inv.totalCGST),
        DoubleCellValue(inv.totalSGST),
        DoubleCellValue(inv.totalIGST),
        DoubleCellValue(inv.grandTotal),
        DoubleCellValue(inv.totalPaid),
        DoubleCellValue(inv.balanceDue),
        TextCellValue(inv.paymentStatus),
      ]);
    }

    // Totals row for Summary
    summarySheet.appendRow([
      TextCellValue('TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(totalTaxableSum),
      DoubleCellValue(totalCgstSum),
      DoubleCellValue(totalSgstSum),
      DoubleCellValue(totalIgstSum),
      DoubleCellValue(grandTotalSum),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);

    // 2. Itemized Breakup Sheet
    final Sheet itemsSheet = excel['Itemized Details'];
    final List<CellValue> itemHeader = [
      TextCellValue('Invoice No'),
      TextCellValue('Date'),
      TextCellValue('Receiver Name'),
      TextCellValue('HSN / SAC'),
      TextCellValue('Description'),
      TextCellValue('Quantity'),
      TextCellValue('Unit'),
      TextCellValue('Price (₹)'),
      TextCellValue('Discount (₹)'),
      TextCellValue('GST Rate (%)'),
      TextCellValue('Taxable Amount (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Item Total (₹)'),
    ];
    itemsSheet.appendRow(itemHeader);

    for (final inv in invoices) {
      for (final item in inv.items) {
        final effectiveTaxable = inv.itemTaxableValue(item);
        final effectiveDiscount =
            ((item.amount * item.quantity) - effectiveTaxable).clamp(
              0.0,
              double.infinity,
            );
        itemsSheet.appendRow([
          TextCellValue(inv.invoiceNo),
          TextCellValue(dateFormat.format(inv.invoiceDate)),
          TextCellValue(inv.receiver.name),
          TextCellValue(item.cleanSacCode),
          TextCellValue(item.description),
          DoubleCellValue(item.quantity),
          TextCellValue(item.unit),
          DoubleCellValue(item.amount),
          DoubleCellValue(effectiveDiscount),
          DoubleCellValue(item.gstRate),
          DoubleCellValue(effectiveTaxable),
          DoubleCellValue(inv.itemCgstAmount(item)),
          DoubleCellValue(inv.itemSgstAmount(item)),
          DoubleCellValue(inv.itemIgstAmount(item)),
          DoubleCellValue(inv.itemTotalAmount(item)),
        ]);
      }
    }

    // 3. GSTR-1 B2B Summary Sheet
    final Sheet gstrSheet = excel['GSTR1 B2B Summary'];
    gstrSheet.appendRow([
      TextCellValue('Receiver GSTIN'),
      TextCellValue('Receiver Name'),
      TextCellValue('Invoice No'),
      TextCellValue('Invoice Date'),
      TextCellValue('Invoice Value (₹)'),
      TextCellValue('Place of Supply'),
      TextCellValue('Reverse Charge'),
      TextCellValue('Applicable % Tax Rate'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('Cess Amount (₹)'),
    ]);

    for (final inv in invoices) {
      if (inv.receiver.gstin.isNotEmpty &&
          inv.type != InvoiceType.creditNote &&
          inv.type != InvoiceType.debitNote &&
          inv.type != InvoiceType.deliveryChallan) {
        for (int i = 0; i < inv.items.length; i++) {
          final item = inv.items[i];
          final isFirstItem = i == 0;
          gstrSheet.appendRow([
            TextCellValue(inv.receiver.gstin),
            TextCellValue(inv.receiver.name),
            TextCellValue(inv.invoiceNo),
            TextCellValue(dateFormat.format(inv.invoiceDate)),
            DoubleCellValue(isFirstItem ? inv.grandTotal : 0.0),
            TextCellValue(inv.placeOfSupply),
            TextCellValue(inv.reverseCharge),
            DoubleCellValue(item.gstRate),
            DoubleCellValue(inv.itemTaxableValue(item)),
            const DoubleCellValue(0.0),
          ]);
        }
      }
    }

    // 4. GSTR-1 B2CS Summary Sheet
    final Sheet b2csSheet = excel['GSTR1 B2CS Summary'];
    b2csSheet.appendRow([
      TextCellValue('Type'),
      TextCellValue('Place of Supply'),
      TextCellValue('Rate (%)'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Cess Amount (₹)'),
    ]);
    final b2csBuckets = <String, Map<String, dynamic>>{};
    for (final inv in invoices) {
      if (inv.receiver.gstin.trim().isEmpty &&
          inv.type != InvoiceType.creditNote &&
          inv.type != InvoiceType.debitNote &&
          inv.type != InvoiceType.deliveryChallan) {
        final pos = inv.placeOfSupply.isNotEmpty
            ? inv.placeOfSupply
            : inv.receiver.state;
        for (final item in inv.items) {
          final key = '$pos|${item.gstRate.toStringAsFixed(2)}';
          final bucket = b2csBuckets.putIfAbsent(
            key,
            () => {
              'pos': pos,
              'rate': item.gstRate,
              'taxable': 0.0,
              'cgst': 0.0,
              'sgst': 0.0,
              'igst': 0.0,
            },
          );
          bucket['taxable'] =
              (bucket['taxable'] as double) + inv.itemTaxableValue(item);
          bucket['cgst'] =
              (bucket['cgst'] as double) + inv.itemCgstAmount(item);
          bucket['sgst'] =
              (bucket['sgst'] as double) + inv.itemSgstAmount(item);
          bucket['igst'] =
              (bucket['igst'] as double) + inv.itemIgstAmount(item);
        }
      }
    }
    for (final b in b2csBuckets.values) {
      b2csSheet.appendRow([
        TextCellValue('OE'),
        TextCellValue(b['pos'] as String),
        DoubleCellValue(b['rate'] as double),
        DoubleCellValue(b['taxable'] as double),
        DoubleCellValue(b['cgst'] as double),
        DoubleCellValue(b['sgst'] as double),
        DoubleCellValue(b['igst'] as double),
        const DoubleCellValue(0.0),
      ]);
    }

    // 5. GSTR-1 CDNR Summary Sheet (Credit / Debit Notes)
    final Sheet cdnrSheet = excel['GSTR1 CDNR Summary'];
    cdnrSheet.appendRow([
      TextCellValue('Receiver GSTIN'),
      TextCellValue('Receiver Name'),
      TextCellValue('Note Number'),
      TextCellValue('Note Date'),
      TextCellValue('Note Type'),
      TextCellValue('Original Invoice No'),
      TextCellValue('Place of Supply'),
      TextCellValue('Rate (%)'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('Note Value (₹)'),
    ]);
    for (final inv in invoices) {
      if (inv.type == InvoiceType.creditNote ||
          inv.type == InvoiceType.debitNote) {
        final noteType = inv.type == InvoiceType.creditNote ? 'C' : 'D';
        for (int i = 0; i < inv.items.length; i++) {
          final item = inv.items[i];
          cdnrSheet.appendRow([
            TextCellValue(
              inv.receiver.gstin.isNotEmpty ? inv.receiver.gstin : 'URP',
            ),
            TextCellValue(inv.receiver.name),
            TextCellValue(inv.invoiceNo),
            TextCellValue(dateFormat.format(inv.invoiceDate)),
            TextCellValue(noteType),
            TextCellValue(inv.originalInvoiceNumber ?? '-'),
            TextCellValue(inv.placeOfSupply),
            DoubleCellValue(item.gstRate),
            DoubleCellValue(inv.itemTaxableValue(item)),
            DoubleCellValue(i == 0 ? inv.grandTotal : 0.0),
          ]);
        }
      }
    }

    // 6. GSTR-1 HSN Summary Sheet
    final Sheet hsnSheet = excel['GSTR1 HSN Summary'];
    hsnSheet.appendRow([
      TextCellValue('HSN / SAC'),
      TextCellValue('Description'),
      TextCellValue('UQC'),
      TextCellValue('Total Quantity'),
      TextCellValue('Rate (%)'),
      TextCellValue('Total Taxable Value (₹)'),
      TextCellValue('Integrated Tax (₹)'),
      TextCellValue('Central Tax (₹)'),
      TextCellValue('State/UT Tax (₹)'),
      TextCellValue('Total Value (₹)'),
    ]);
    final hsnBuckets = <String, Map<String, dynamic>>{};
    for (final inv in invoices) {
      if (inv.type == InvoiceType.deliveryChallan) continue;
      final mult = inv.type == InvoiceType.creditNote ? -1.0 : 1.0;
      for (final item in inv.items) {
        final code = item.cleanSacCode.isEmpty ? '998311' : item.cleanSacCode;
        final key = '$code|${item.unit}|${item.gstRate.toStringAsFixed(2)}';
        final bucket = hsnBuckets.putIfAbsent(
          key,
          () => {
            'code': code,
            'desc': item.description,
            'uqc': item.unit,
            'qty': 0.0,
            'rate': item.gstRate,
            'taxable': 0.0,
            'igst': 0.0,
            'cgst': 0.0,
            'sgst': 0.0,
            'total': 0.0,
          },
        );
        bucket['qty'] = (bucket['qty'] as double) + (item.quantity * mult);
        bucket['taxable'] =
            (bucket['taxable'] as double) +
            (inv.itemTaxableValue(item) * mult);
        bucket['igst'] =
            (bucket['igst'] as double) + (inv.itemIgstAmount(item) * mult);
        bucket['cgst'] =
            (bucket['cgst'] as double) + (inv.itemCgstAmount(item) * mult);
        bucket['sgst'] =
            (bucket['sgst'] as double) + (inv.itemSgstAmount(item) * mult);
        bucket['total'] =
            (bucket['total'] as double) + (inv.itemTotalAmount(item) * mult);
      }
    }
    for (final h in hsnBuckets.values) {
      hsnSheet.appendRow([
        TextCellValue(h['code'] as String),
        TextCellValue(h['desc'] as String),
        TextCellValue(h['uqc'] as String),
        DoubleCellValue(h['qty'] as double),
        DoubleCellValue(h['rate'] as double),
        DoubleCellValue(h['taxable'] as double),
        DoubleCellValue(h['igst'] as double),
        DoubleCellValue(h['cgst'] as double),
        DoubleCellValue(h['sgst'] as double),
        DoubleCellValue(h['total'] as double),
      ]);
    }

    return excel.encode() ?? [];
  }

  /// Saves the generated Excel bytes to file using FileSaver
  Future<String?> saveExcelFile(
    final List<int> bytes,
    final String fileName,
  ) async {
    final extension = p.extension(fileName).replaceAll('.', '');
    final nameOnly = p.basenameWithoutExtension(fileName);

    return FileSaver.instance.saveFile(
      name: nameOnly.isEmpty ? 'Invoices_Export' : nameOnly,
      bytes: Uint8List.fromList(bytes),
      fileExtension: extension.isEmpty ? 'xlsx' : extension,
      mimeType: MimeType.microsoftExcel,
    );
  }
}
