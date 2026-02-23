import 'package:flutter/material.dart';
import 'package:invobharat/widgets/profile_switcher_sheet.dart';
import 'package:invobharat/widgets/error_view.dart';
import 'package:invobharat/widgets/empty_state.dart';
import 'package:invobharat/widgets/skeleton_widgets.dart';
import 'package:invobharat/widgets/gst_pie_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invobharat/screens/invoice_form.dart';
import 'package:invobharat/screens/invoice_detail_screen.dart';
import 'package:invobharat/screens/recurring_invoices_screen.dart';

import 'package:invobharat/screens/settings_screen.dart';
import 'package:invobharat/screens/payment_history_screen.dart';
import 'package:invobharat/screens/audit_report_screen.dart';
import 'package:invobharat/providers/business_profile_provider.dart';

import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:invobharat/services/gstr_service.dart';
import 'package:invobharat/services/dashboard_actions.dart';
import 'package:invobharat/screens/widgets/dashboard_widgets.dart';
import 'package:invobharat/screens/material_clients_screen.dart';
import 'package:invobharat/screens/invoices_list_screen.dart';

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

  void _updateDateRange(final String filter) async {
    final now = DateTime.now();
    DateTime start, end;

    switch (filter) {
      case "This Month":
        start = DateTime(now.year, now.month);
        end = DateTime(now.year, now.month + 1, 0);
        setState(() {
          _selectedFilter = filter;
          _dateRange = DateTimeRange(start: start, end: end);
        });
        break;
      case "Last Month":
        start = DateTime(now.year, now.month - 1);
        end = DateTime(now.year, now.month, 0);
        setState(() {
          _selectedFilter = filter;
          _dateRange = DateTimeRange(start: start, end: end);
        });
        break;
      case "This Quarter":
        final int quarter = (now.month - 1) ~/ 3 + 1;
        start = DateTime(now.year, (quarter - 1) * 3 + 1);
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
  Widget build(final BuildContext context) {
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
            _DashboardHeader(
              profile: profile,
              selectedFilter: _selectedFilter,
              onFilterSelected: _updateDateRange,
            ),
            const SizedBox(height: 24),
            invoiceListAsync.when(
              loading: () => const SkeletonDashboard(),
              error: (final err, final stack) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(invoiceListProvider),
              ),
              data: (final invoices) {
                final filteredInvoices = _dateRange == null
                    ? invoices
                    : invoices.where((final i) {
                        return i.invoiceDate.isAfter(
                              _dateRange!.start.subtract(
                                const Duration(seconds: 1),
                              ),
                            ) &&
                            i.invoiceDate.isBefore(
                              _dateRange!.end.add(const Duration(days: 1)),
                            );
                      }).toList();

                final previousPeriodInvoices = _getPreviousPeriodInvoices(
                  invoices,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardStats(
                      invoices: filteredInvoices,
                      previousInvoices: previousPeriodInvoices,
                      selectedFilter: _selectedFilter,
                      profile: profile,
                    ),
                    const SizedBox(height: 32),
                    _DashboardQuickActions(
                      invoices: filteredInvoices,
                      selectedFilter: _selectedFilter,
                    ),
                    const SizedBox(height: 32),
                    _DashboardRecentActivity(invoices: invoices),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Invoice> _getPreviousPeriodInvoices(final List<Invoice> allInvoices) {
    if (_dateRange == null) return [];

    final periodDuration = _dateRange!.end.difference(_dateRange!.start);
    final previousStart = _dateRange!.start.subtract(periodDuration);
    final previousEnd = _dateRange!.start.subtract(const Duration(days: 1));

    return allInvoices.where((final i) {
      return i.invoiceDate.isAfter(
            previousStart.subtract(const Duration(seconds: 1)),
          ) &&
          i.invoiceDate.isBefore(previousEnd.add(const Duration(days: 1)));
    }).toList();
  }

  void _showProfileSwitcher(final BuildContext context, final WidgetRef ref) {
    showProfileSwitcherSheet(context, ref);
  }
}

class _DashboardHeader extends StatelessWidget {
  final BusinessProfile profile;
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const _DashboardHeader({
    required this.profile,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(final BuildContext context) {
    return Row(
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
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        PopupMenuButton<String>(
          initialValue: selectedFilter,
          onSelected: onFilterSelected,
          child: Chip(
            label: Text(selectedFilter),
            avatar: const Icon(Icons.calendar_today, size: 16),
          ),
          itemBuilder: (final context) => [
            const PopupMenuItem(value: "This Month", child: Text("This Month")),
            const PopupMenuItem(value: "Last Month", child: Text("Last Month")),
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
    );
  }
}

class _DashboardStats extends StatelessWidget {
  final List<Invoice> invoices;
  final List<Invoice> previousInvoices;
  final String selectedFilter;
  final BusinessProfile profile;

  const _DashboardStats({
    required this.invoices,
    required this.previousInvoices,
    required this.selectedFilter,
    required this.profile,
  });

  @override
  Widget build(final BuildContext context) {
    final stats = DashboardActions.calculateStats(invoices);
    final totalRevenue = stats['revenue'] as double;
    final totalCGST = stats['cgst'] as double;
    final totalSGST = stats['sgst'] as double;
    final totalIGST = stats['igst'] as double;
    final totalGst = totalCGST + totalSGST + totalIGST;

    final prevStats = DashboardActions.calculateStats(previousInvoices);
    final prevRevenue = prevStats['revenue'] as double;
    final prevGst =
        (prevStats['cgst'] as double) +
        (prevStats['sgst'] as double) +
        (prevStats['igst'] as double);

    final revenueTrend = prevRevenue > 0
        ? ((totalRevenue - prevRevenue) / prevRevenue) * 100
        : 0.0;
    final countTrend = previousInvoices.isNotEmpty
        ? ((invoices.length - previousInvoices.length) /
                  previousInvoices.length) *
              100
        : 0.0;
    final gstTrend = prevGst > 0 ? ((totalGst - prevGst) / prevGst) * 100 : 0.0;

    final currency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InvoicesListScreen()),
                ),
                title: "Revenue ($selectedFilter)",
                value: currency.format(totalRevenue),
                icon: Icons.currency_rupee,
                color: Colors.green,
                trend: revenueTrend,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardStatCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InvoicesListScreen()),
                ),
                title: "Invoices",
                value: "${invoices.length}",
                icon: Icons.description,
                color: Colors.blue,
                trend: countTrend,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        DashboardStatCard(
          onTap: () => showDialog(
            context: context,
            builder: (final context) => GstBreakdownDialog(
              cgst: totalCGST,
              sgst: totalSGST,
              igst: totalIGST,
              currencySymbol: profile.currencySymbol,
            ),
          ),
          title: "GST Output ($selectedFilter)",
          value: currency.format(totalGst),
          icon: Icons.percent,
          color: Colors.purple,
          trend: gstTrend,
        ),
        if (totalGst > 0) ...[
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "GST Breakdown ($selectedFilter)",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GstPieChart(
                    cgst: totalCGST,
                    sgst: totalSGST,
                    igst: totalIGST,
                    currencySymbol: profile.currencySymbol,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DashboardQuickActions extends ConsumerWidget {
  final List<Invoice> invoices;
  final String selectedFilter;

  const _DashboardQuickActions({
    required this.invoices,
    required this.selectedFilter,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DashboardActionButton(
              label: "New Invoice",
              icon: Icons.add,
              bgColor: theme.colorScheme.primaryContainer,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoiceFormScreen()),
              ).then((_) => ref.refresh(invoiceListProvider)),
            ),
            const SizedBox(width: 16),
            DashboardActionButton(
              label: "Payments",
              icon: Icons.payment,
              bgColor: Colors.green.shade100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
              ),
            ),
            const SizedBox(width: 16),
            DashboardActionButton(
              label: "Clients",
              icon: Icons.contacts,
              bgColor: Colors.blue.shade100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MaterialClientsScreen(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            DashboardActionButton(
              label: "Audit",
              icon: Icons.warning_amber,
              bgColor: Colors.orange.shade100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuditReportScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DashboardActionButton(
              label: "Recurring",
              icon: Icons.autorenew,
              bgColor: Colors.purple.shade100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecurringInvoicesScreen(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            DashboardActionButton(
              label: "Export GSTR-1",
              icon: Icons.table_chart,
              bgColor: theme.colorScheme.tertiaryContainer,
              onTap: () async => _exportGstr1(context, invoices),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportGstr1(
    final BuildContext context,
    final List<Invoice> filteredInvoices,
  ) async {
    try {
      if (filteredInvoices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No invoices in selected period")),
        );
        return;
      }

      final csvData = GstrService().generateGstr1Csv(filteredInvoices);
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save GSTR-1 CSV',
        fileName: 'GSTR1_${selectedFilter.replaceAll(" ", "_")}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.csv')) {
          outputFile = '$outputFile.csv';
        }
        await File(outputFile).writeAsString(csvData);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exported to $outputFile")));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class _DashboardRecentActivity extends ConsumerWidget {
  final List<Invoice> invoices;

  const _DashboardRecentActivity({required this.invoices});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final currency = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Invoices",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoicesListScreen()),
              ),
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (invoices.isEmpty)
          EmptyStateIllustration(
            title: "No invoices yet",
            message: "Create your first invoice to get started",
            actionLabel: "Create Invoice",
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvoiceFormScreen()),
            ).then((_) => ref.refresh(invoiceListProvider)),
          )
        else
          ...invoices
              .take(5)
              .map(
                (final inv) => Card(
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceDetailScreen(invoice: inv),
                        ),
                      );
                      ref.invalidate(invoiceListProvider);
                    },
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor(
                        inv.paymentStatus,
                      ).withValues(alpha: 0.2),
                      child: Text(
                        inv.receiver.name.isNotEmpty
                            ? inv.receiver.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: getStatusColor(inv.paymentStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(inv.receiver.name),
                        const SizedBox(width: 8),
                        DashboardStatusBadge(status: inv.paymentStatus),
                      ],
                    ),
                    subtitle: Text(
                      "${inv.invoiceNo} • ${DateFormat('dd MMM').format(inv.invoiceDate)}",
                    ),
                    trailing: Text(
                      currency.format(inv.grandTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
