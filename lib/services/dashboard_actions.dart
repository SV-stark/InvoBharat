import '../models/invoice.dart';

class DashboardActions {
  static List<Invoice> filterInvoices(List<Invoice> invoices, String period) {
    if (period == "All Time") return invoices;
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (period == "This Month") {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0); // Last day of month
    } else if (period == "Last Month") {
      start = DateTime(now.year, now.month - 1, 1);
      end = DateTime(now.year, now.month, 0);
    } else if (period.startsWith("Q1")) {
      // Apr-Jun
      final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
      start = DateTime(fyStartYear, 4, 1);
      end = DateTime(fyStartYear, 6, 30);
    } else if (period.startsWith("Q2")) {
      // Jul-Sep
      final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
      start = DateTime(fyStartYear, 7, 1);
      end = DateTime(fyStartYear, 9, 30);
    } else if (period.startsWith("Q3")) {
      // Oct-Dec
      final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
      start = DateTime(fyStartYear, 10, 1);
      end = DateTime(fyStartYear, 12, 31);
    } else if (period.startsWith("Q4")) {
      // Jan-Mar
      final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
      start = DateTime(fyStartYear + 1, 1, 1);
      end = DateTime(fyStartYear + 1, 3, 31);
    }

    if (start != null && end != null) {
      final endOfDay =
          end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      return invoices
          .where((inv) =>
              inv.invoiceDate
                  .isAfter(start!.subtract(const Duration(seconds: 1))) &&
              inv.invoiceDate.isBefore(endOfDay))
          .toList();
    }
    return invoices;
  }

  static Map<String, dynamic> calculateStats(List<Invoice> invoices) {
    return {
      'revenue': invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal),
      'cgst': invoices.fold(0.0, (sum, inv) => sum + inv.totalCGST),
      'sgst': invoices.fold(0.0, (sum, inv) => sum + inv.totalSGST),
      'igst': invoices.fold(0.0, (sum, inv) => sum + inv.totalIGST),
      'count': invoices.length,
    };
  }
}
