import 'package:flutter/material.dart';
import '../widgets/profile_switcher_sheet.dart';
import '../widgets/error_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'invoice_form.dart';
import 'invoice_detail_screen.dart';
import 'recurring_invoices_screen.dart';

import 'settings_screen.dart';
import 'payment_history_screen.dart'; // NEW
import 'audit_report_screen.dart'; // NEW
import '../providers/business_profile_provider.dart';

import '../providers/invoice_repository_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/gstr_service.dart';
import '../services/dashboard_actions.dart';
import 'material_clients_screen.dart';
import 'invoices_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedFilter = "This Month";
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _updateDateRange("This Month");
  }

  void _updateDateRange(String filter) async {
    final now = DateTime.now();
    DateTime start, end;

    switch (filter) {
      case "This Month":
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0); // Last day of month
        setState(() {
          _selectedFilter = filter;
          _dateRange = DateTimeRange(start: start, end: end);
        });
        break;
      case "Last Month":
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        setState(() {
          _selectedFilter = filter;
          _dateRange = DateTimeRange(start: start, end: end);
        });
        break;
      case "This Quarter":
        int quarter = (now.month - 1) ~/ 3 + 1;
        start = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        end = DateTime(now.year, quarter * 3 + 1, 0);
        setState(() {
          _selectedFilter = filter;
          _dateRange = DateTimeRange(start: start, end: end);
        });
        break;
      case "Custom":
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDateRange: _dateRange,
        );
        if (picked != null) {
          setState(() {
            _selectedFilter = "Custom";
            _dateRange = picked;
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final invoiceListAsync = ref.watch(invoiceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('logo.png', height: 32, width: 32),
            const SizedBox(width: 12),
            Text(
              "InvoBharat",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(invoiceListProvider),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProfileSwitcher(context, ref),
        tooltip: "Switch Profile",
        child: const Icon(Icons.switch_account),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      profile.companyName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  initialValue: _selectedFilter,
                  onSelected: _updateDateRange,
                  child: Chip(
                    label: Text(_selectedFilter),
                    avatar: const Icon(Icons.calendar_today, size: 16),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "This Month",
                      child: Text("This Month"),
                    ),
                    const PopupMenuItem(
                      value: "Last Month",
                      child: Text("Last Month"),
                    ),
                    const PopupMenuItem(
                      value: "This Quarter",
                      child: Text("This Quarter"),
                    ),
                    const PopupMenuItem(
                      value: "Custom",
                      child: Text("Custom Range..."),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            invoiceListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(invoiceListProvider),
              ),
              data: (invoices) {
                // Filter Invoices
                final filteredInvoices = _dateRange == null
                    ? invoices
                    : invoices.where((i) {
                        // Normalize dates to ignore time?
                        // InvoiceDate usually has time? Assuming just compare
                        return i.invoiceDate.isAfter(
                              _dateRange!.start.subtract(
                                const Duration(seconds: 1),
                              ),
                            ) &&
                            i.invoiceDate.isBefore(
                              _dateRange!.end.add(const Duration(days: 1)),
                            );
                      }).toList();

                final stats = DashboardActions.calculateStats(filteredInvoices);
                final totalRevenue = stats['revenue'] as double;
                final totalCGST = stats['cgst'] as double;
                final totalSGST = stats['sgst'] as double;
                final totalIGST = stats['igst'] as double;
                final currency = NumberFormat.simpleCurrency(
                  locale: 'en_IN',
                  decimalDigits: 0,
                );

                return Column(
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to List
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InvoicesListScreen(),
                                ),
                              );
                            },
                            child: _buildStatCard(
                              context,
                              "Revenue ($_selectedFilter)",
                              currency.format(totalRevenue),
                              Icons.currency_rupee,
                              Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InvoicesListScreen(),
                                ),
                              );
                            },
                            child: _buildStatCard(
                              context,
                              "Invoices",
                              "${filteredInvoices.length}",
                              Icons.description,
                              Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // GST Card (New)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showGstBreakdown(
                              context,
                              totalCGST,
                              totalSGST,
                              totalIGST,
                              profile.currencySymbol,
                            ),
                            child: _buildStatCard(
                              context,
                              "GST Output ($_selectedFilter)",
                              currency.format(
                                totalCGST + totalSGST + totalIGST,
                              ),
                              Icons.percent,
                              Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    Text(
                      "Quick Actions",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildActionButton(
                          context,
                          "New Invoice",
                          Icons.add,
                          Theme.of(context).colorScheme.primaryContainer,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvoiceFormScreen(),
                            ),
                          ).then((_) => ref.refresh(invoiceListProvider)),
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          context,
                          "Payments",
                          Icons.payment,
                          Colors.green.shade100, // Distinct color
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentHistoryScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          context,
                          "Clients",
                          Icons.contacts,
                          Colors.blue.shade100,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MaterialClientsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          context,
                          "Audit",
                          Icons.warning_amber,
                          Colors.orange.shade100,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuditReportScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildActionButton(
                          context,
                          "Recurring",
                          Icons.autorenew,
                          Colors.purple.shade100,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RecurringInvoicesScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          context,
                          "Export GSTR-1",
                          Icons.table_chart,
                          Theme.of(context).colorScheme.tertiaryContainer,
                          () async {
                            try {
                              // Use filtered Invoices
                              if (filteredInvoices.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "No invoices in selected period",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final csvData = GstrService().generateGstr1Csv(
                                filteredInvoices,
                              );

                              String? outputFile = await FilePicker.saveFile(
                                dialogTitle: 'Save GSTR-1 CSV',
                                fileName:
                                    'GSTR1_${_selectedFilter.replaceAll(" ", "_")}.csv',
                                allowedExtensions: ['csv'],
                                type: FileType.custom,
                              );

                              if (outputFile != null) {
                                if (!outputFile.toLowerCase().endsWith(
                                      '.csv',
                                    )) {
                                  outputFile = '$outputFile.csv';
                                }
                                await File(outputFile).writeAsString(csvData);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Exported to $outputFile"),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Invoices",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvoicesListScreen(),
                            ),
                          ),
                          child: const Text("View All"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (invoices.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(Icons.history)),
                          title: Text("No invoices yet"),
                        ),
                      )
                    else
                      ...invoices.take(5).map(
                            (inv) => Card(
                              child: ListTile(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          InvoiceDetailScreen(invoice: inv),
                                    ),
                                  );
                                  ref.invalidate(invoiceListProvider);
                                },
                                leading: const CircleAvatar(
                                  child: Icon(Icons.description),
                                ),
                                title: Text(inv.receiver.name),
                                subtitle: Text(
                                  "${inv.invoiceNo} • ${DateFormat('dd MMM').format(inv.invoiceDate)}",
                                ),
                                trailing: Text(
                                  currency.format(inv.grandTotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSwitcher(BuildContext context, WidgetRef ref) {
    showProfileSwitcherSheet(context, ref);
  }

  void _showGstBreakdown(
    BuildContext context,
    double cgst,
    double sgst,
    double igst,
    String currencySymbol,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("GST Breakdown"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGstRow("CGST", cgst, currencySymbol),
            const SizedBox(height: 8),
            _buildGstRow("SGST", sgst, currencySymbol),
            const SizedBox(height: 8),
            _buildGstRow("IGST", igst, currencySymbol),
            const Divider(height: 24),
            _buildGstRow(
              "Total",
              cgst + sgst + igst,
              currencySymbol,
              isBold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGstRow(
    String label,
    double amount,
    String symbol, {
    bool isBold = false,
  }) {
    final style = isBold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          NumberFormat.currency(
            symbol: symbol,
            decimalDigits: 2,
          ).format(amount),
          style: style,
        ),
      ],
    );
  }
}
