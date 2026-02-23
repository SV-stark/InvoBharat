import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/ledger_provider.dart';

class ClientLedgerScreen extends ConsumerStatefulWidget {
  final Client client;

  const ClientLedgerScreen({super.key, required this.client});

  @override
  ConsumerState<ClientLedgerScreen> createState() => _ClientLedgerScreenState();
}

class _ClientLedgerScreenState extends ConsumerState<ClientLedgerScreen> {
  @override
  Widget build(final BuildContext context) {
    final ledgerAsync = ref.watch(clientLedgerProvider(widget.client.name));

    return ScaffoldPage(
      header: PageHeader(
        title: Text('Ledger: ${widget.client.name}'),
      ),
      content: ledgerAsync.when(
        data: (final entries) {
          if (entries.isEmpty) {
            return const Center(
                child: Text("No transactions found for this client."));
          }

          // Compute Totals
          final totalDebit = entries.fold(0.0, (final sum, final e) => sum + e.debit);
          final totalCredit = entries.fold(0.0, (final sum, final e) => sum + e.credit);
          final closingBalance = entries.last.balance;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Summary Cards
                Row(
                  children: [
                    _buildSummaryCard("Total Billed", totalDebit, Colors.blue),
                    const SizedBox(width: 16),
                    _buildSummaryCard("Total Paid", totalCredit, Colors.green),
                    const SizedBox(width: 16),
                    _buildSummaryCard("Closing Balance", closingBalance,
                        closingBalance > 0 ? Colors.red : Colors.teal),
                  ],
                ),
                const SizedBox(height: 24),
                // Table
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: material.DataTable(
                        columns: const [
                          material.DataColumn(label: Text('Date')),
                          material.DataColumn(label: Text('Particulars')),
                          material.DataColumn(label: Text('Type')),
                          material.DataColumn(label: Text('Debit (+)')),
                          material.DataColumn(label: Text('Credit (-)')),
                          material.DataColumn(label: Text('Balance')),
                        ],
                        rows: entries.map((final e) {
                          return material.DataRow(cells: [
                            material.DataCell(
                                Text(DateFormat('dd-MM-yyyy').format(e.date))),
                            material.DataCell(Text(e.particulars)),
                            material.DataCell(Text(e.type)),
                            material.DataCell(Text(e.debit > 0
                                ? "₹${e.debit.toStringAsFixed(2)}"
                                : "")),
                            material.DataCell(Text(e.credit > 0
                                ? "₹${e.credit.toStringAsFixed(2)}"
                                : "")),
                            material.DataCell(Text(
                                "₹${e.balance.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: e.balance > 0
                                        ? Colors.red
                                        : Colors.green))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: ProgressRing()),
        error: (final err, final stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryCard(final String title, final double amount, final Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                "₹${amount.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
