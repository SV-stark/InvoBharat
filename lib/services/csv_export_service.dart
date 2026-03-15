import 'dart:isolate';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/payment_transaction.dart';

class CsvExportService {
  // Ordered columns as per request + required fields for restoration
  static const List<String> headers = [
    // Requested GSTR-like columns
    'GSTIN/UIN Of Supplier',
    'Trade Name',
    'Invoice No',
    'Date of Invoice',
    'Invoice Value', // Grand Total
    'GST Rate (%)', // Item GST
    'Taxable Value', // Item Net Amount
    'CESS',
    'Place Of Supply',
    'RCM Applicable',
    'HSN',
    'Description',

    // Additional columns for Restore
    'Receiver Name',
    'Receiver GSTIN',
    'Receiver Address',
    'Receiver State',
    'Item Quantity',
    'Item Unit',
    'Item Price',
    'Item Discount',
    'Due Date',
    'Payment Terms',
    'Bank Name',
    'Account No',
    'IFSC Code',
    'Branch',
    'Notes',
    'Payment Total', // Simplified payment restoration
  ];

  Future<String> generateInvoiceCsv(final List<Invoice> invoices) async {
    return Isolate.run(() => _generateInvoiceCsvSync(invoices));
  }

  static String _generateInvoiceCsvSync(final List<Invoice> invoices) {
    final List<List<dynamic>> rows = [headers];
    final dateFormat = DateFormat('dd-MM-yyyy');

    for (final invoice in invoices) {
      // If no items, write at least one row for the invoice header
      final itemsToWrite = invoice.items.isEmpty
          ? [const InvoiceItem(description: 'Service', gstRate: 0)]
          : invoice.items;

      for (final item in itemsToWrite) {
        rows.add([
          invoice.supplier.gstin,
          invoice.supplier.name,
          invoice.invoiceNo,
          dateFormat.format(invoice.invoiceDate),
          invoice.grandTotal.toStringAsFixed(2),
          item.gstRate.toString(),
          item.netAmount.toStringAsFixed(2),
          '0', // CESS
          invoice.placeOfSupply,
          invoice.reverseCharge,
          item.sacCode,
          item.description,

          // Restore fields
          invoice.receiver.name,
          invoice.receiver.gstin,
          invoice.receiver.address,
          invoice.receiver.state,
          item.quantity.toString(),
          item.unit,
          item.amount.toStringAsFixed(2),
          item.discount.toStringAsFixed(2),
          invoice.dueDate != null ? dateFormat.format(invoice.dueDate!) : '',
          invoice.paymentTerms,
          invoice.bankName,
          invoice.accountNo,
          invoice.ifscCode,
          invoice.branch,
          invoice.comments,
          invoice.totalPaid.toStringAsFixed(2),
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Parses CSV string back into List of Invoice objects
  Future<List<Invoice>> parseInvoiceCsv(final String csvContent) async {
    return Isolate.run(() => _parseInvoiceCsvSync(csvContent));
  }

  static List<Invoice> _parseInvoiceCsvSync(final String csvContent) {
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) return [];

    final headerRow = rows.first;
    // Basic validation
    if (headerRow.length < 3 || headerRow[2] != 'Invoice No') {
      throw Exception('Invalid CSV Format: Missing Invoice No column');
    }

    final Map<String, Invoice> invoiceMap = {};

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      // Safety check for column count
      final paddedRow = List<dynamic>.from(row);
      if (paddedRow.length < headers.length) {
        paddedRow.addAll(List.filled(headers.length - paddedRow.length, ''));
      }

      final invoiceNo = paddedRow[2].toString();

      // Parse fields
      final dateStr = paddedRow[3].toString();
      final gstRate = double.tryParse(paddedRow[5].toString()) ?? 0;
      final pos = paddedRow[8].toString();
      final rcm = paddedRow[9].toString();
      final hsn = paddedRow[10].toString();
      final desc = paddedRow[11].toString();

      final recvName = paddedRow[12].toString();
      final recvGstin = paddedRow[13].toString();
      final recvAddr = paddedRow[14].toString();
      final recvState = paddedRow[15].toString();
      final qty = double.tryParse(paddedRow[16].toString()) ?? 1;
      final unit = paddedRow[17].toString();
      final price = double.tryParse(paddedRow[18].toString()) ?? 0;
      final discount = double.tryParse(paddedRow[19].toString()) ?? 0;
      final dueDateStr = paddedRow[20].toString();
      final terms = paddedRow[21].toString();
      final bank = paddedRow[22].toString();
      final acct = paddedRow[23].toString();
      final ifsc = paddedRow[24].toString();
      final branch = paddedRow[25].toString();
      final notes = paddedRow[26].toString();
      final paidTotal = double.tryParse(paddedRow[27].toString()) ?? 0;

      // Create Item
      final item = InvoiceItem(
        description: desc,
        sacCode: hsn,
        gstRate: gstRate,
        amount: price,
        discount: discount,
        quantity: qty,
        unit: unit.isEmpty ? 'Nos' : unit,
      );

      final DateFormat fmt = DateFormat('dd-MM-yyyy');
      DateTime invDate = DateTime.now();
      try {
        invDate = fmt.parse(dateStr);
      } catch (_) {}

      DateTime? dueDate;
      if (dueDateStr.isNotEmpty) {
        try {
          dueDate = fmt.parse(dueDateStr);
        } catch (_) {}
      }

      if (invoiceMap.containsKey(invoiceNo)) {
        // Add item to existing
        final existing = invoiceMap[invoiceNo]!;
        final updatedItems = [...existing.items, item];
        invoiceMap[invoiceNo] = existing.copyWith(items: updatedItems);
      } else {
        // Create new Invoice
        final supplier = Supplier(
          gstin: paddedRow[0].toString(),
          name: paddedRow[1].toString(),
          state: pos,
        );

        final receiver = Receiver(
          name: recvName,
          gstin: recvGstin,
          address: recvAddr,
          state: recvState,
        );

        final List<PaymentTransaction> payments = [];
        if (paidTotal > 0) {
          payments.add(
            PaymentTransaction(
              id: 'restored_${DateTime.now().microsecondsSinceEpoch}',
              invoiceId: invoiceNo,
              date: invDate,
              amount: paidTotal,
              paymentMode: 'Cash',
            ),
          );
        }

        final invoice = Invoice(
          id: 'restored_${DateTime.now().millisecondsSinceEpoch}_$i',
          invoiceNo: invoiceNo,
          invoiceDate: invDate,
          dueDate: dueDate,
          placeOfSupply: pos,
          reverseCharge: rcm,
          paymentTerms: terms,
          comments: notes,
          bankName: bank,
          accountNo: acct,
          ifscCode: ifsc,
          branch: branch,
          supplier: supplier,
          receiver: receiver,
          items: [item],
          payments: payments,
        );

        invoiceMap[invoiceNo] = invoice;
      }
    }

    return invoiceMap.values.toList();
  }
}
