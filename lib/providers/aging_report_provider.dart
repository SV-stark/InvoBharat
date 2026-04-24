import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:invobharat/providers/invoice_repository_provider.dart';

class AgingBucket {
  final String label;
  final double amount;
  final int count;
  final Color color;

  AgingBucket(this.label, this.amount, this.count, this.color);
}

class AgingReportData {
  final List<AgingBucket> buckets;
  final double totalReceivable;
  final Map<String, double> clientBreakdown; // Client Name -> Total Due

  AgingReportData({
    required this.buckets,
    required this.totalReceivable,
    required this.clientBreakdown,
  });
}

final agingReportProvider = FutureProvider<AgingReportData>((final ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final allInvoices = await repository.getAllInvoices();

  // Filter Unpaid
  // Note: invoice.paymentStatus logic is in model, but we can recheck here to be safe or use model getter.
  // We need actual balance due.
  final unpaidInvoices =
      allInvoices.where((final inv) => inv.balanceDue > 1.0).toList();
  // > 1.0 to handle float rounding errors or negligible amounts.

  double current = 0;
  double days30 = 0;
  double days60 = 0;
  double days90 = 0;
  double days90Plus = 0;

  int countCurrent = 0;
  int count30 = 0;
  int count60 = 0;
  int count90 = 0;
  int count90Plus = 0;

  final Map<String, double> clientMap = {};

  final now = DateTime.now();

  for (final inv in unpaidInvoices) {
    final due =
        inv.dueDate ?? inv.invoiceDate; // Use invoice date if due date missing
    final balance = inv.balanceDue;

    // Aggregate by Client
    clientMap[inv.receiver.name] =
        (clientMap[inv.receiver.name] ?? 0) + balance;

    if (now.isBefore(due)) {
      current += balance;
      countCurrent++;
    } else {
      final daysOverdue = now.difference(due).inDays;
      if (daysOverdue <= 30) {
        days30 += balance;
        count30++;
      } else if (daysOverdue <= 60) {
        days60 += balance;
        count60++;
      } else if (daysOverdue <= 90) {
        days90 += balance;
        count90++;
      } else {
        days90Plus += balance;
        count90Plus++;
      }
    }
  }

  final total = current + days30 + days60 + days90 + days90Plus;

  return AgingReportData(
    totalReceivable: total,
    clientBreakdown: clientMap,
    buckets: [
      AgingBucket("Current (Not Overdue)", current, countCurrent, Colors.green),
      AgingBucket("1-30 Days", days30, count30, Colors.teal),
      AgingBucket("31-60 Days", days60, count60, Colors.orange),
      AgingBucket("61-90 Days", days90, count90, Colors.deepOrange),
      AgingBucket("> 90 Days", days90Plus, count90Plus, Colors.red),
    ],
  );
});
