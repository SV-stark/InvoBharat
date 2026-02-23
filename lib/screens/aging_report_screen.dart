import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:invobharat/providers/aging_report_provider.dart';

class AgingReportScreen extends ConsumerWidget {
  const AgingReportScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final reportAsync = ref.watch(agingReportProvider);

    return ScaffoldPage(
      header: const PageHeader(title: Text("Receivables Aging Report")),
      content: reportAsync.when(
        data: (final data) {
          if (data.totalReceivable == 0) {
            return const Center(
              child: Text("Great news! You have no outstanding receivables."),
            );
          }

          // Pie Chart Data
          final sections = data.buckets
              .where((final b) => b.amount > 0)
              .map((final b) => PieChartSectionData(
                    color: b.color,
                    value: b.amount,
                    title: '', // Tooltips or Legend instead
                    radius: 50,
                  ))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Total Outstanding: ₹${data.totalReceivable.toStringAsFixed(2)}",
                        style: FluentTheme.of(context).typography.title),
                  ],
                ),
                const SizedBox(height: 24),

                // Chart and Legend Section
                SizedBox(
                  height: 300,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 60,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: data.buckets.map((final b) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: b.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      "${b.label}: ₹${b.amount.toStringAsFixed(2)} (${b.count} inv)"),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text("Client Breakdown",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),

                // Client List
                Expanded(
                  child: ListView.builder(
                    itemCount: data.clientBreakdown.length,
                    itemBuilder: (final ctx, final index) {
                      final name = data.clientBreakdown.keys.elementAt(index);
                      final amount = data.clientBreakdown[name]!;
                      return ListTile(
                        leading: const Icon(FluentIcons.contact),
                        title: Text(name),
                        trailing: Text(
                          "₹${amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: material.Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: ProgressRing()),
        error: (final e, final s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
