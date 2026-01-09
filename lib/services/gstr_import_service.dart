import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/invoice.dart';

class GstrImportResult {
  final List<Invoice> invoices;
  final List<String> missingInvoiceNumbers;
  final int totalRowsProcessed;

  GstrImportResult({
    required this.invoices,
    required this.missingInvoiceNumbers,
    required this.totalRowsProcessed,
  });
}

class GstrImportService {
  /// Parses CSV content and returns a result with invoices and missing numbers.
  /// Expects CSV format: GSTIN,Trade Name,Invoice No,Date,Value,GST%,Taxable,CESS,Place,RCM,HSN
  GstrImportResult parseGstr1Csv(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty)
      return GstrImportResult(
          invoices: [], missingInvoiceNumbers: [], totalRowsProcessed: 0);

    // Skip header if present (Naive check: contains "Invoice No" or starts with GSTIN label)
    // We'll assume first line is header if it contains specific keywords
    var startRow = 0;
    if (lines.first.toLowerCase().contains("invoice no")) {
      startRow = 1;
    }

    final Map<String, Invoice> invoiceMap = {};
    final dateFormat = DateFormat('dd-MM-yyyy');

    for (var i = startRow; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = _parseCsvLine(line);
      if (parts.length < 10) continue; // Minimum required columns

      // CSV Columns based on export format:
      // 0: GSTIN, 1: Trade Name, 2: Invoice No, 3: Date, 4: Value, 5: GST%,
      // 6: Taxable, 7: CESS, 8: Place, 9: RCM, 10: HSN (Optional)

      final gstin = parts[0];
      final tradeName = parts[1];
      final invoiceNo = parts[2];
      final dateStr = parts[3];
      // final invoiceValue = double.tryParse(parts[4]) ?? 0; // Not stored directly on Invoice, derived
      final gstRate = double.tryParse(parts[5]) ?? 0;
      final taxableValue = double.tryParse(parts[6]) ?? 0;
      // final cess = parts[7];
      final placeOfSupply = parts[8];
      // final rcm = parts[9];
      final hsnDesc = parts.length > 10 ? parts[10] : "";

      DateTime invoiceDate;
      try {
        invoiceDate = dateFormat.parse(dateStr);
      } catch (e) {
        invoiceDate = DateTime.now(); // Fallback
      }

      // Create Item
      final item = InvoiceItem(
        description: hsnDesc.isEmpty ? "Imported Item" : hsnDesc,
        quantity: 1, // Default to 1 as CSV doesn't have qty
        amount: taxableValue, // Unit price = taxable value since qty is 1
        gstRate: gstRate,
      );

      if (invoiceMap.containsKey(invoiceNo)) {
        // Append item to existing invoice
        final existing = invoiceMap[invoiceNo]!;
        final updatedItems = List<InvoiceItem>.from(existing.items)..add(item);
        invoiceMap[invoiceNo] = existing.copyWith(items: updatedItems);
      } else {
        // Create new invoice
        invoiceMap[invoiceNo] = Invoice(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              i.toString(), // Temp ID
          invoiceNo: invoiceNo,
          invoiceDate: invoiceDate,
          dueDate: invoiceDate, // Default due date same as invoice date
          placeOfSupply: placeOfSupply,
          receiver: Receiver(
            name: tradeName,
            gstin: gstin,
            state: placeOfSupply,
          ),
          items: [item],
          // Defaults
          paymentTerms: "Due on Receipt",
          comments: "Imported from GSTR-1",
          supplier:
              const Supplier(), // Will be filled by context/defaults if saved? Or just keep empty
        );
      }
    }

    final parsedInvoices = invoiceMap.values.toList();

    // Check for missing sequence numbers
    final missing = _detectMissingSequences(parsedInvoices);

    return GstrImportResult(
      invoices: parsedInvoices,
      missingInvoiceNumbers: missing,
      totalRowsProcessed: lines.length - startRow,
    );
  }

  List<String> _parseCsvLine(String line) {
    // Basic CSV split, doesn't handle quoted commas perfectly but sufficient for this specific export format
    // which replaces commas in text fields.
    return line.split(',');
  }

  List<String> _detectMissingSequences(List<Invoice> invoices) {
    if (invoices.isEmpty) return [];

    // Filter to those that look like sequences (e.g. INV-001, INV-003)
    // Heuristic: Extract numeric part from the end.
    final numericPartRegExp = RegExp(r'(\d+)$');

    // Group by prefix (e.g. "INV-")
    final Map<String, List<int>> prefixMap = {};

    for (final inv in invoices) {
      final match = numericPartRegExp.firstMatch(inv.invoiceNo);
      if (match != null) {
        final numberStr = match.group(1)!;
        final number = int.parse(numberStr);
        final prefix =
            inv.invoiceNo.substring(0, inv.invoiceNo.length - numberStr.length);

        prefixMap.putIfAbsent(prefix, () => []).add(number);
      }
    }

    final missing = <String>[];

    prefixMap.forEach((prefix, numbers) {
      numbers.sort();
      for (int i = 0; i < numbers.length - 1; i++) {
        final current = numbers[i];
        final next = numbers[i + 1];
        if (next > current + 1) {
          // Gap found
          for (int gap = current + 1; gap < next; gap++) {
            // Reconstruct formatted number with leading zeros if possible?
            // heurisitic: use same length as current
            // e.g. if current is 001 (len 3), make gap 002.
            // If original was just 1, make gap 2.

            // We can infer width from the string representation of current in the invoice list but we parsed it to int.
            // Let's just output Prefix+Gap
            missing.add("$prefix$gap");
          }
        }
      }
    });

    return missing;
  }
}
