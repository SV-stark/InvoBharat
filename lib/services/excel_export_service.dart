import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path/path.dart' as p;
import 'package:invobharat/models/invoice.dart';

class ExcelExportService {
  /// Generates a professional multi-tab Excel (.xlsx) workbook for invoices
  Future<List<int>> generateInvoiceExcel(final List<Invoice> invoices) async {
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
        TextCellValue(inv.dueDate != null ? dateFormat.format(inv.dueDate!) : '-'),
        TextCellValue(inv.receiver.name),
        TextCellValue(inv.receiver.gstin.isNotEmpty ? inv.receiver.gstin : 'URP'),
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
      final isInterState = inv.isInterState;
      for (final item in inv.items) {
        itemsSheet.appendRow([
          TextCellValue(inv.invoiceNo),
          TextCellValue(dateFormat.format(inv.invoiceDate)),
          TextCellValue(inv.receiver.name),
          TextCellValue(item.cleanSacCode),
          TextCellValue(item.description),
          DoubleCellValue(item.quantity),
          TextCellValue(item.unit),
          DoubleCellValue(item.amount),
          DoubleCellValue(item.discount),
          DoubleCellValue(item.gstRate),
          DoubleCellValue(item.netAmount),
          DoubleCellValue(item.calculateCgst(isInterState)),
          DoubleCellValue(item.calculateSgst(isInterState)),
          DoubleCellValue(item.calculateIgst(isInterState)),
          DoubleCellValue(item.totalAmount),
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
      if (inv.receiver.gstin.isNotEmpty) {
        for (final item in inv.items) {
          gstrSheet.appendRow([
            TextCellValue(inv.receiver.gstin),
            TextCellValue(inv.receiver.name),
            TextCellValue(inv.invoiceNo),
            TextCellValue(dateFormat.format(inv.invoiceDate)),
            DoubleCellValue(inv.grandTotal),
            TextCellValue(inv.placeOfSupply),
            TextCellValue(inv.reverseCharge),
            DoubleCellValue(item.gstRate),
            DoubleCellValue(item.netAmount),
            const DoubleCellValue(0.0),
          ]);
        }
      }
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
