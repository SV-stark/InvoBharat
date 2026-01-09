import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/business_profile_provider.dart';
import '../../widgets/profile_switcher_sheet.dart';
import 'fluent_invoice_wizard.dart';
import '../../services/gstr_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../providers/invoice_repository_provider.dart';

import 'fluent_estimates_screen.dart';
import 'fluent_recurring_screen.dart';
import '../../models/invoice.dart';

import '../../services/dashboard_actions.dart'; // Re-added

class FluentDashboard extends ConsumerStatefulWidget {
  const FluentDashboard({super.key});

  @override
  ConsumerState<FluentDashboard> createState() => _FluentDashboardState();
}

class _FluentDashboardState extends ConsumerState<FluentDashboard> {
  String _selectedPeriod = "All Time";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final invoiceListAsync = ref.watch(invoiceListProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Dashboard'),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.contact),
              onPressed: () => showProfileSwitcherSheet(context, ref),
            ),
            const SizedBox(width: 8),
            ComboBox<String>(
              value: _selectedPeriod,
              items: [
                "All Time",
                "This Month",
                "Last Month",
                "Q1 (Apr-Jun)",
                "Q2 (Jul-Sep)",
                "Q3 (Oct-Dec)",
                "Q4 (Jan-Mar)"
              ].map((e) => ComboBoxItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedPeriod = v);
              },
              placeholder: const Text("Select Period"),
            ),
          ],
        ),
      ),
      children: [
        Text(
          "Welcome back, ${profile.companyName}",
          style: theme.typography.titleLarge,
        ),
        const SizedBox(height: 20),
        invoiceListAsync.when(
          loading: () => const Center(child: ProgressRing()),
          error: (err, stack) => Text("Error: $err"),
          data: (allInvoices) {
            var filteredInvoices =
                DashboardActions.filterInvoices(allInvoices, _selectedPeriod);

            // Search filter
            if (_searchQuery.isNotEmpty) {
              filteredInvoices = filteredInvoices
                  .where((inv) =>
                      inv.receiver.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      inv.invoiceNo
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();
            }

            final stats = DashboardActions.calculateStats(filteredInvoices);
            final totalRevenue = stats['revenue'] as double;
            final totalCGST = stats['cgst'] as double;
            final totalSGST = stats['sgst'] as double;
            final totalIGST = stats['igst'] as double;

            final paymentsReceived =
                filteredInvoices.fold(0.0, (sum, inv) => sum + inv.totalPaid);
            final paymentsDue =
                filteredInvoices.fold(0.0, (sum, inv) => sum + inv.balanceDue);

            final currency = NumberFormat.currency(
                symbol: profile.currencySymbol, decimalDigits: 2);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions CommandBar
                CommandBar(
                  primaryItems: [
                    CommandBarButton(
                      label: const Text('New Invoice'),
                      icon: const Icon(FluentIcons.add),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          FluentPageRoute(
                              builder: (_) => const FluentInvoiceWizard()),
                        );
                        ref.invalidate(invoiceListProvider);
                      },
                    ),
                    CommandBarButton(
                      label: const Text('Export GSTR-1'),
                      icon: const Icon(FluentIcons.download),
                      onPressed: () => _exportGstr1(context, allInvoices),
                    ),
                  ],
                  secondaryItems: [
                    CommandBarButton(
                      label: const Text('Estimates'),
                      icon: const Icon(FluentIcons.document_set),
                      onPressed: () => Navigator.push(
                          context,
                          FluentPageRoute(
                              builder: (_) => const FluentEstimatesScreen())),
                    ),
                    CommandBarButton(
                      label: const Text('Recurring'),
                      icon: const Icon(FluentIcons.repeat_all),
                      onPressed: () => Navigator.push(
                          context,
                          FluentPageRoute(
                              builder: (_) => const FluentRecurringScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stat Cards
                // Row 1: Revenue (Hero)
                Row(
                  children: [
                    Expanded(
                      child: _buildHeroStatCard(
                        context,
                        "Total Revenue",
                        currency.format(totalRevenue),
                        FluentIcons.money,
                        theme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: Received & Due
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        "Received",
                        currency.format(paymentsReceived),
                        FluentIcons.check_mark,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        "Due",
                        currency.format(paymentsDue),
                        FluentIcons.warning,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 3: GST & Invoices
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showGstBreakdown(context, totalCGST,
                            totalSGST, totalIGST, profile.currencySymbol),
                        child: _buildStatCard(
                            context,
                            "GST Liability",
                            currency.format(totalCGST + totalSGST + totalIGST),
                            FluentIcons.bank,
                            Colors.purple),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                          context,
                          "Total Invoices",
                          "${filteredInvoices.length}",
                          FluentIcons.page_list,
                          Colors.teal),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Invoice List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recent Invoices", style: theme.typography.title),
                    SizedBox(
                      width: 250,
                      child: TextBox(
                        placeholder: "Search invoices...",
                        prefix: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(FluentIcons.search)),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (filteredInvoices.isEmpty)
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.error_badge,
                            size: 40, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No invoices found",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  ...filteredInvoices.take(50).map((inv) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(FluentIcons.page_solid,
                                  color: theme.accentColor),
                            ),
                            title: Text(inv.receiver.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "${inv.invoiceNo} • ${DateFormat('dd MMM yyyy').format(inv.invoiceDate)}"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currency.format(inv.grandTotal),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                _buildStatusBadge(inv),
                              ],
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                FluentPageRoute(
                                    builder: (_) => FluentInvoiceWizard(
                                        invoiceToEdit: inv)),
                              );
                              ref.invalidate(invoiceListProvider);
                            },
                          ),
                        ),
                      )),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(dynamic invoice) {
    // Logic for status: Paid if payments >= total, Overdue if due date passed, else Unpaid
    // Assuming invoice has payments field (List<Payment>)
    // For now, simple mock or check if available
    // Invoice model in read_file output didn't show payment logic detail, but let's assume unpaid/default for now
    // or use due date.

    final isOverdue = invoice.dueDate.isBefore(DateTime.now());
    // final isPaid = invoice.balance <= 0; // If balance exists

    // Fallback: Just display date relative
    String text = "Due on ${DateFormat('MMM dd').format(invoice.dueDate)}";
    Color color = Colors.orange;

    if (isOverdue) {
      text = "Overdue";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  Widget _buildHeroStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      padding: const EdgeInsets.all(16),
      backgroundColor: color, // Solid color for hero
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const Icon(FluentIcons.chart, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  color: FluentTheme.of(context).typography.bodyLarge?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _exportGstr1(
      BuildContext context, List<Invoice> allInvoices) async {
    try {
      final filteredInvoices =
          DashboardActions.filterInvoices(allInvoices, _selectedPeriod);
      if (filteredInvoices.isEmpty) {
        displayInfoBar(context,
            builder: (context, close) => InfoBar(
                title: const Text("No Invoices"),
                content:
                    const Text("No invoices to export for selected period"),
                onClose: close));
        return;
      }

      final csvData = GstrService().generateGstr1Csv(filteredInvoices);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save GSTR-1 CSV',
        fileName: 'GSTR1_${_selectedPeriod.replaceAll(" ", "_")}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.csv')) {
          outputFile = '$outputFile.csv';
        }
        await File(outputFile).writeAsString(csvData);
        if (!context.mounted) return;
        displayInfoBar(context,
            builder: (context, close) => InfoBar(
                title: const Text("Success"),
                content: Text("Exported to $outputFile"),
                severity: InfoBarSeverity.success,
                onClose: close));
      }
    } catch (e) {
      if (!context.mounted) return;
      displayInfoBar(context,
          builder: (context, close) => InfoBar(
              title: const Text("Error"),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
              onClose: close));
    }
  }

  void _showGstBreakdown(BuildContext context, double cgst, double sgst,
      double igst, String currencySymbol) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text("GST Breakdown"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGstRow("CGST", cgst, currencySymbol),
            const SizedBox(height: 8),
            _buildGstRow("SGST", sgst, currencySymbol),
            const SizedBox(height: 8),
            _buildGstRow("IGST", igst, currencySymbol),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildGstRow("Total", cgst + sgst + igst, currencySymbol,
                isBold: true),
          ],
        ),
        actions: [
          Button(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildGstRow(String label, double amount, String symbol,
      {bool isBold = false}) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : const TextStyle();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
            NumberFormat.currency(symbol: symbol, decimalDigits: 2)
                .format(amount),
            style: style),
      ],
    );
  }
}
