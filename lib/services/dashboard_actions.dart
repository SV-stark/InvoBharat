import 'package:intl/intl.dart'; // New
import '../models/invoice.dart';

class DashboardActions {
  static Map<String, double> calculateRevenueTrend(List<Invoice> invoices) {
    Map<String, double> monthlyRevenue = {};
    for (var inv in invoices) {
      final key = DateFormat('yyyy-MM').format(inv.invoiceDate);
      if (!monthlyRevenue.containsKey(key)) {
        monthlyRevenue[key] = 0.0;
      }
      monthlyRevenue[key] = monthlyRevenue[key]! + inv.grandTotal;
    }
    return monthlyRevenue;
  }

  static Map<String, double> calculateAging(List<Invoice> invoices) {
    double current = 0;
    double days30 = 0;
    double days60 = 0;
    double days90 = 0;
    double days90Plus = 0;

    final now = DateTime.now();

    for (var inv in invoices) {
      if (inv.paymentStatus == 'Paid') continue;
      // Use invoiceDate or dueDate? Usually DueDate.
      // If dueDate is null, use invoiceDate.
      final due = inv.dueDate;
      final diff = now.difference(due ?? now).inDays;

      if (diff <= 0) {
        current += inv.balanceDue;
      } else if (diff <= 30) {
        days30 += inv.balanceDue;
      } else if (diff <= 60) {
        days60 += inv.balanceDue;
      } else if (diff <= 90) {
        days90 += inv.balanceDue;
      } else {
        days90Plus += inv.balanceDue;
      }
    }

    return {
      "Current": current,
      "1-30 Days": days30,
      "31-60 Days": days60,
      "61-90 Days": days90,
      "90+ Days": days90Plus
    };
  }

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
