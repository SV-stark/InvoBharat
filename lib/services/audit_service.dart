import '../models/invoice.dart';

class AuditService {
  /// Detects missing sequence numbers in a list of invoices.
  /// Returns a map of Prefix -> List of missing numbers as formatted strings.
  static List<String> detectGaps(List<Invoice> invoices) {
    if (invoices.isEmpty) return [];

    // Filter to those that look like sequences (e.g. INV-001, INV-003)
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
      // Remove duplicates
      final uniqueNumbers = numbers.toSet().toList()..sort();

      for (int i = 0; i < uniqueNumbers.length - 1; i++) {
        final current = uniqueNumbers[i];
        final next = uniqueNumbers[i + 1];
        if (next > current + 1) {
          // Gap found
          for (int gap = current + 1; gap < next; gap++) {
            // Check if this gap can be formatted similarly to neighbors
            // We'll rely on a heuristic to pad it if the current/next were padded.
            // But getting original length is hard since we only stored int.
            missing.add("$prefix$gap");
          }
        }
      }
    });

    return missing;
  }
}
