import 'package:invobharat/models/invoice.dart';

class AuditService {
  /// Detects missing sequence numbers in a list of invoices.
  /// Returns a map of Prefix -> List of missing numbers as formatted strings.
  static List<String> detectGaps(final List<Invoice> invoices) {
    if (invoices.isEmpty) return [];

    // Filter to those that look like sequences (e.g. INV-001, INV-003)
    final numericPartRegExp = RegExp(r'(\d+)$');

    // Group by prefix (e.g. "INV-")
    // Store as Map<Prefix, Map<PaddingWidth, List<Numbers>>>
    final Map<String, Map<int, List<int>>> prefixPaddingMap = {};

    for (final inv in invoices) {
      final match = numericPartRegExp.firstMatch(inv.invoiceNo);
      if (match != null) {
        final numberStr = match.group(1)!;
        final number = int.parse(numberStr);
        final padding = numberStr.length;
        final prefix = inv.invoiceNo.substring(
          0,
          inv.invoiceNo.length - numberStr.length,
        );

        prefixPaddingMap
            .putIfAbsent(prefix, () => {})
            .putIfAbsent(padding, () => [])
            .add(number);
      }
    }

    final missing = <String>[];

    prefixPaddingMap.forEach((final prefix, final paddingMap) {
      paddingMap.forEach((final padding, final numbers) {
        numbers.sort();
        final uniqueNumbers = numbers.toSet().toList()..sort();

        for (int i = 0; i < uniqueNumbers.length - 1; i++) {
          final current = uniqueNumbers[i];
          final next = uniqueNumbers[i + 1];
          if (next > current + 1) {
            for (int gap = current + 1; gap < next; gap++) {
              missing.add("$prefix${gap.toString().padLeft(padding, '0')}");
            }
          }
        }
      });
    });

    return missing;
  }
}
