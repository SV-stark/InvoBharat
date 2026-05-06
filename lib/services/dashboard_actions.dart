import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/formatters.dart';

class DashboardActions {
  static Map<String, double> calculateRevenueTrend(
    final List<Invoice> invoices,
  ) {
    final Map<String, double> monthlyRevenue = {};
    for (var inv in invoices) {
      final key = DateFormat('yyyy-MM').format(inv.invoiceDate);
      if (!monthlyRevenue.containsKey(key)) {
        monthlyRevenue[key] = 0.0;
      }
      monthlyRevenue[key] = monthlyRevenue[key]! + inv.grandTotal;
    }
    return monthlyRevenue;
  }

  static Map<String, double> calculateAging(final List<Invoice> invoices) {
    double current = 0;
    double days30 = 0;
    double days60 = 0;
    double days90 = 0;
    double days90Plus = 0;

    final now = DateTime.now();

    for (var inv in invoices) {
      if (inv.paymentStatus == 'Paid') continue;
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
      "90+ Days": days90Plus,
    };
  }

  static DateTimeRange? getRangeForPeriod(final String period) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (period == "This Month") {
      start = DateTime(now.year, now.month);
      end = DateTime(now.year, now.month + 1, 0);
    } else if (period == "Last Month") {
      start = DateTime(now.year, now.month - 1);
      end = DateTime(now.year, now.month, 0);
    } else if (period == "This Quarter") {
      final int quarter = (now.month - 1) ~/ 3 + 1;
      start = DateTime(now.year, (quarter - 1) * 3 + 1);
      end =
          quarter == 4
              ? DateTime(now.year, 12, 31)
              : DateTime(now.year, quarter * 3 + 1, 0);
    } else if (period == "This Financial Year") {
      final int startYear = now.month >= 4 ? now.year : now.year - 1;
      start = DateTime(startYear, 4);
      end = DateTime(startYear + 1, 3, 31);
    } else if (period == "Last Financial Year") {
      final int startYear = now.month >= 4 ? now.year - 1 : now.year - 2;
      start = DateTime(startYear, 4);
      end = DateTime(startYear + 1, 3, 31);
    } else if (period.startsWith("FY ")) {
      // Parse "FY 2024-25"
      final parts = period.substring(3).split('-');
      if (parts.isNotEmpty) {
        final startYear = int.tryParse(parts[0]);
        if (startYear != null) {
          start = DateTime(startYear, 4);
          end = DateTime(startYear + 1, 3, 31);
        }
      }
    } else if (period.startsWith("Q")) {
      final quarter = int.tryParse(period.substring(1, 2));
      if (quarter != null) {
        // Find FY start year based on current date
        final int startYear = now.month >= 4 ? now.year : now.year - 1;

        switch (quarter) {
          case 1: // Apr-Jun
            start = DateTime(startYear, 4);
            end = DateTime(startYear, 6, 30);
            break;
          case 2: // Jul-Sep
            start = DateTime(startYear, 7);
            end = DateTime(startYear, 9, 30);
            break;
          case 3: // Oct-Dec
            start = DateTime(startYear, 10);
            end = DateTime(startYear, 12, 31);
            break;
          case 4: // Jan-Mar
            start = DateTime(startYear + 1, 1);
            end = DateTime(startYear + 1, 3, 31);
            break;
        }
      }
    }

    if (start != null && end != null) {
      return DateTimeRange(
        start: start,
        end: end.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      );
    }
    return null;
  }

  static List<Invoice> filterInvoices(
    final List<Invoice> invoices,
    final String period,
  ) {
    if (period == "All Time") return invoices;
    final range = getRangeForPeriod(period);

    if (range != null) {
      return invoices
          .where(
            (final inv) =>
                inv.invoiceDate.isAfter(
                  range.start.subtract(const Duration(seconds: 1)),
                ) &&
                inv.invoiceDate.isBefore(range.end),
          )
          .toList();
    }
    return invoices;
  }

  static Map<String, dynamic> calculateStats(final List<Invoice> invoices) {
    return {
      'revenue': invoices.fold(
        0.0,
        (final sum, final inv) => sum + inv.grandTotal,
      ),
      'cgst': invoices.fold(0.0, (final sum, final inv) => sum + inv.totalCGST),
      'sgst': invoices.fold(0.0, (final sum, final inv) => sum + inv.totalSGST),
      'igst': invoices.fold(0.0, (final sum, final inv) => sum + inv.totalIGST),
      'count': invoices.length,
    };
  }
}
