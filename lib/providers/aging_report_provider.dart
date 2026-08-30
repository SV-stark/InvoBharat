import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money2/money2.dart';

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

  final inr = CommonCurrencies().inr;
  final unpaidInvoices = allInvoices
      .where((final inv) => inv.balanceDue > 0.01)
      .toList();

  Money current = Money.fromNumWithCurrency(0, inr);
  Money days30 = Money.fromNumWithCurrency(0, inr);
  Money days60 = Money.fromNumWithCurrency(0, inr);
  Money days90 = Money.fromNumWithCurrency(0, inr);
  Money days90Plus = Money.fromNumWithCurrency(0, inr);

  int countCurrent = 0;
  int count30 = 0;
  int count60 = 0;
  int count90 = 0;
  int count90Plus = 0;

  final Map<String, Money> clientMoneyMap = {};

  final now = DateTime.now();

  for (final inv in unpaidInvoices) {
    final due =
        inv.dueDate ?? inv.invoiceDate; // Use invoice date if due date missing
    final balanceMoney = Money.fromNumWithCurrency(inv.balanceDue, inr);

    // Aggregate by Client safely
    final clientKey = inv.receiver.name.trim().isNotEmpty
        ? inv.receiver.name.trim()
        : (inv.receiver.gstin.trim().isNotEmpty
              ? inv.receiver.gstin.trim()
              : 'Unknown Client');

    clientMoneyMap[clientKey] =
        (clientMoneyMap[clientKey] ?? Money.fromNumWithCurrency(0, inr)) +
        balanceMoney;

    if (now.isBefore(due)) {
      current += balanceMoney;
      countCurrent++;
    } else {
      final daysOverdue = now.difference(due).inDays;
      if (daysOverdue <= 30) {
        days30 += balanceMoney;
        count30++;
      } else if (daysOverdue <= 60) {
        days60 += balanceMoney;
        count60++;
      } else if (daysOverdue <= 90) {
        days90 += balanceMoney;
        count90++;
      } else {
        days90Plus += balanceMoney;
        count90Plus++;
      }
    }
  }

  final total = current + days30 + days60 + days90 + days90Plus;
  final clientMap = clientMoneyMap.map(
    (key, val) => MapEntry(key, val.toDouble()),
  );

  return AgingReportData(
    totalReceivable: total.toDouble(),
    clientBreakdown: clientMap,
    buckets: [
      AgingBucket(
        "Current (Not Overdue)",
        current.toDouble(),
        countCurrent,
        Colors.green,
      ),
      AgingBucket("1-30 Days", days30.toDouble(), count30, Colors.teal),
      AgingBucket("31-60 Days", days60.toDouble(), count60, Colors.orange),
      AgingBucket("61-90 Days", days90.toDouble(), count90, Colors.deepOrange),
      AgingBucket("> 90 Days", days90Plus.toDouble(), count90Plus, Colors.red),
    ],
  );
});
