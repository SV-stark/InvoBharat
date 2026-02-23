import 'dart:convert';
import 'package:intl/intl.dart';
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
    'Payment Total' // Simplified payment restoration
  ];

  String generateInvoiceCsv(final List<Invoice> invoices) {
    final buffer = StringBuffer();

    // Write Header
    buffer.writeln(headers.join(','));

    for (final invoice in invoices) {
      final dateFormat = DateFormat('dd-MM-yyyy');

      // If no items, write at least one row for the invoice header
      final itemsToWrite = invoice.items.isEmpty
          ? [const InvoiceItem(description: 'Service', gstRate: 0)]
          : invoice.items;

      for (final item in itemsToWrite) {
        final row = [
          _escape(invoice.supplier.gstin),
          _escape(invoice.supplier.name),
          _escape(invoice.invoiceNo),
          _escape(dateFormat.format(invoice.invoiceDate)),
          invoice.grandTotal.toStringAsFixed(2),
          item.gstRate.toString(),
          item.netAmount.toStringAsFixed(2),
          '0', // CESS
          _escape(invoice.placeOfSupply),
          _escape(invoice.reverseCharge),
          _escape(item.sacCode),
          _escape(item.description),

          // Restore fields
          _escape(invoice.receiver.name),
          _escape(invoice.receiver.gstin),
          _escape(invoice.receiver.address),
          _escape(invoice.receiver.state),
          item.quantity.toString(),
          _escape(item.unit),
          item.amount.toStringAsFixed(2),
          item.discount.toStringAsFixed(2),
          invoice.dueDate != null ? dateFormat.format(invoice.dueDate!) : '',
          _escape(invoice.paymentTerms),
          _escape(invoice.bankName),
          _escape(invoice.accountNo),
          _escape(invoice.ifscCode),
          _escape(invoice.branch),
          _escape(invoice.comments),
          invoice.totalPaid.toStringAsFixed(2)
        ];

        buffer.writeln(row.join(','));
      }
    }

    return buffer.toString();
  }

  /// Parses CSV string back into List of Invoice objects
  List<Invoice> parseInvoiceCsv(final String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) return [];

    final headerRow = _parseRow(lines.first);
    // Basic validation
    if (headerRow.length < 3 || headerRow[2] != 'Invoice No') {
      throw Exception('Invalid CSV Format: Missing Invoice No column');
    }

    final Map<String, Invoice> invoiceMap = {};
    // Map<InvoiceNo, List<InvoiceItem>>

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      final row = _parseRow(line);
      // Safety check for column count
      if (row.length < headers.length) {
        // Pad with empty strings if older format or truncated
        row.addAll(List.filled(headers.length - row.length, ''));
      }

      final invoiceNo = row[2];

      // Parse fields
      final dateStr = row[3];
      final gstRate = double.tryParse(row[5]) ?? 0;
      // taxableValue row[6] is derived
      // cess row[7] unused
      final pos = row[8];
      final rcm = row[9];
      final hsn = row[10];
      final desc = row[11];

      final recvName = row[12];
      final recvGstin = row[13];
      final recvAddr = row[14];
      final recvState = row[15];
      final qty = double.tryParse(row[16]) ?? 1;
      final unit = row[17];
      final price = double.tryParse(row[18]) ?? 0;
      final discount = double.tryParse(row[19]) ?? 0;
      final dueDateStr = row[20];
      final terms = row[21];
      final bank = row[22];
      final acct = row[23];
      final ifsc = row[24];
      final branch = row[25];
      final notes = row[26];
      final paidTotal = double.tryParse(row[27]) ?? 0;

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
          gstin: row[0],
          name: row[1],
          state: pos, // Approx
          // We don't have full supplier address/email/phone in basic CSV
        );

        final receiver = Receiver(
          name: recvName,
          gstin: recvGstin,
          address: recvAddr,
          state: recvState,
        );

        // Reconstruct payments (simplified as one lump sum transaction if totalPaid > 0)
        final List<PaymentTransaction> payments = [];
        if (paidTotal > 0) {
          payments.add(PaymentTransaction(
              id: 'restored_${DateTime.now().microsecondsSinceEpoch}',
              invoiceId: invoiceNo,
              date: invDate,
              amount: paidTotal,
              paymentMode: 'Cash'));
        }

        final invoice = Invoice(
          id: 'restored_${DateTime.now().millisecondsSinceEpoch}_$i', // Generate new ID
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

  String _escape(final String? val) {
    if (val == null) return '';
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }

  List<String> _parseRow(final String line) {
    final values = <String>[];
    final sb = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          sb.write('"');
          i++; // Skip escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(sb.toString());
        sb.clear();
      } else {
        sb.write(char);
      }
    }
    values.add(sb.toString());
    return values;
  }
}
