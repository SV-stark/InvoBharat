import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:libadwaita/libadwaita.dart';

import '../../models/invoice.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/invoice_repository_provider.dart';
import '../invoice_form.dart';
import '../estimates_screen.dart';
import '../recurring_invoices_screen.dart';

final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  return ref.watch(invoiceRepositoryProvider).getAllInvoices();
});

class LinuxDashboard extends ConsumerStatefulWidget {
  const LinuxDashboard({super.key});

  @override
  ConsumerState<LinuxDashboard> createState() => _LinuxDashboardState();
}

class _LinuxDashboardState extends ConsumerState<LinuxDashboard> {
  String _selectedPeriod = "All Time";

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final invoiceListAsync = ref.watch(invoiceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            icon: const Icon(Icons.filter_list),
            underline: Container(),
            onChanged: (String? newValue) {
              if (newValue != null) setState(() => _selectedPeriod = newValue);
            },
            items: <String>[
              "All Time",
              "This Month",
              "Last Month",
              "Q1 (Apr-Jun)",
              "Q2 (Jul-Sep)",
              "Q3 (Oct-Dec)",
              "Q4 (Jan-Mar)"
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(invoiceListProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  "Welcome back, ${profile.companyName}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                invoiceListAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text("Error: $err"),
                  data: (allInvoices) {
                    final invoices =
                        _filterInvoices(allInvoices, _selectedPeriod);

                    final totalRevenue =
                        invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
                    final totalCGST =
                        invoices.fold(0.0, (sum, inv) => sum + inv.totalCGST);
                    final totalSGST =
                        invoices.fold(0.0, (sum, inv) => sum + inv.totalSGST);
                    final totalIGST =
                        invoices.fold(0.0, (sum, inv) => sum + inv.totalIGST);

                    final currency = NumberFormat.simpleCurrency(
                        locale: 'en_IN', decimalDigits: 0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Revenue Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                "Total Revenue",
                                currency.format(totalRevenue),
                                Icons.currency_rupee,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                "Invoices",
                                "${invoices.length}",
                                Icons.description,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // GST Stats (New Row)
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                "CGST",
                                currency.format(totalCGST),
                                Icons.account_balance,
                                isSmall: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                "SGST",
                                currency.format(totalSGST),
                                Icons.account_balance,
                                isSmall: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                "IGST",
                                currency.format(totalIGST),
                                Icons.account_balance,
                                isSmall: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        AdwPreferencesGroup(
                          title: "Quick Actions",
                          children: [
                            AdwActionRow(
                              start: const Icon(Icons.add),
                              title: "New Invoice",
                              subtitle: "Create a new sales invoice",
                              end: const Icon(Icons.chevron_right),
                              onActivated: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const InvoiceFormScreen()),
                                ).then((_) => ref.refresh(invoiceListProvider));
                              },
                            ),
                            AdwActionRow(
                              start: const Icon(Icons.receipt_long),
                              title: "Estimates",
                              subtitle: "Manage quotes & estimates",
                              end: const Icon(Icons.chevron_right),
                              onActivated: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EstimatesScreen()),
                                );
                              },
                            ),
                            AdwActionRow(
                              start: const Icon(Icons.autorenew),
                              title: "Recurring",
                              subtitle: "Manage recurring profiles",
                              end: const Icon(Icons.chevron_right),
                              onActivated: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const RecurringInvoicesScreen()),
                                );
                              },
                            ),
                            AdwActionRow(
                              start: const Icon(Icons.table_chart),
                              title: "Export GSTR-1",
                              subtitle: "Download CSV report",
                              end: const Icon(Icons.chevron_right),
                              onActivated: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "GSTR-1 Export Coming Soon!")));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AdwPreferencesGroup(
                          title: "Filtered Invoices",
                          children: invoices.isEmpty
                              ? [const AdwActionRow(title: "No invoices found")]
                              : invoices
                                  .map((inv) => AdwActionRow(
                                        start: const Icon(Icons.description),
                                        title: inv.receiver.name,
                                        subtitle:
                                            "${inv.invoiceNo} • ${DateFormat('dd MMM').format(inv.invoiceDate)}",
                                        end: Text(
                                            currency.format(inv.grandTotal),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        onActivated: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    InvoiceFormScreen(
                                                        invoiceToEdit: inv)),
                                          ).then((_) =>
                                              ref.refresh(invoiceListProvider));
                                        },
                                      ))
                                  .toList(),
                        ),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon,
      {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSmall)
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          if (!isSmall) const SizedBox(height: 12),
          Text(title,
              style: isSmall
                  ? Theme.of(context).textTheme.bodySmall
                  : Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value,
              style: isSmall
                  ? Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices, String period) {
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
}
