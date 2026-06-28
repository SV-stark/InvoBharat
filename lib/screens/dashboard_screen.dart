import 'package:flutter/material.dart';
import 'package:invobharat/widgets/profile_switcher_sheet.dart';
import 'package:invobharat/widgets/error_view.dart';
import 'package:invobharat/widgets/empty_state.dart';
import 'package:invobharat/widgets/gst_pie_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/recurring_provider.dart';

import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:invobharat/services/gstr_service.dart';
import 'package:invobharat/services/gstr3b_service.dart';
import 'package:invobharat/services/dashboard_actions.dart';
import 'package:invobharat/screens/widgets/dashboard_widgets.dart';
import 'package:invobharat/utils/formatters.dart';
import 'package:invobharat/services/invoice_actions.dart';
import 'package:invobharat/services/invoice_import_service.dart';
import 'package:invobharat/services/gstr1_json_import_service.dart';
import 'package:invobharat/utils/pdf_generator.dart';
import 'package:printing/printing.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedFilter = "This Financial Year";
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _updateDateRange("This Financial Year");
    // Trigger recurring invoice checks on app start/dashboard load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringListProvider.notifier).runChecks();
    });
  }

  void _updateDateRange(final String filter) async {
    if (filter == "Custom") {
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
      return;
    }

    if (filter == "Select Financial Year") {
      await _showFinancialYearPicker();
      return;
    }

    final range = DashboardActions.getRangeForPeriod(filter);
    if (range != null) {
      setState(() {
        _selectedFilter = filter;
        _dateRange = range;
      });
    }
  }

  Future<void> _showFinancialYearPicker() async {
    final now = DateTime.now();
    final currentFYStart = now.month >= 4 ? now.year : now.year - 1;

    final List<String> years = [];
    for (int i = 0; i < 5; i++) {
      final start = currentFYStart - i;
      years.add("FY $start-${(start + 1).toString().substring(2)}");
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (final context) => SimpleDialog(
        title: const Text("Select Financial Year"),
        children: years.map((final fy) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, fy),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(fy, style: const TextStyle(fontSize: 16)),
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      _updateDateRange(selected);
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
            const Gap(12),
            const Text(
              "InvoBharat",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProfileSwitcher(context, ref),
        tooltip: "Switch Profile",
        child: const Icon(Icons.switch_account),
      ),
      body: invoiceListAsync.when(
        loading: () => Skeletonizer(
          child: _DashboardContent(
            profile: profile,
            invoices: const [],
            previousInvoices: const [],
            selectedFilter: _selectedFilter,
            onFilterSelected: _updateDateRange,
            dateRange: _dateRange,
          ),
        ),
        error: (final err, final stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(invoiceListProvider),
        ),
        data: (final invoices) {
          final filteredInvoices = _dateRange == null
              ? invoices
              : invoices.where((final i) {
                  return i.invoiceDate.isAfter(
                        _dateRange!.start.subtract(const Duration(seconds: 1)),
                      ) &&
                      i.invoiceDate.isBefore(
                        _dateRange!.end.add(const Duration(days: 1)),
                      );
                }).toList();

          final previousPeriodInvoices = _getPreviousPeriodInvoices(invoices);

          return _DashboardContent(
            profile: profile,
            invoices: filteredInvoices,
            previousInvoices: previousPeriodInvoices,
            selectedFilter: _selectedFilter,
            onFilterSelected: _updateDateRange,
            dateRange: _dateRange,
          );
        },
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

class _DashboardContent extends StatelessWidget {
  final BusinessProfile profile;
  final List<Invoice> invoices;
  final List<Invoice> previousInvoices;
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final DateTimeRange? dateRange;

  const _DashboardContent({
    required this.profile,
    required this.invoices,
    required this.previousInvoices,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.dateRange,
  });

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(
            profile: profile,
            selectedFilter: selectedFilter,
            onFilterSelected: onFilterSelected,
          ),
          const Gap(24),
          _DashboardStats(
            invoices: invoices,
            previousInvoices: previousInvoices,
            selectedFilter: selectedFilter,
            profile: profile,
          ),
          const Gap(32),
          _DashboardQuickActions(
            invoices: invoices,
            selectedFilter: selectedFilter,
          ),
          const Gap(32),
          _DashboardRecentActivity(invoices: invoices),
        ],
      ),
    );
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
        Expanded(
          child: Column(
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${DateTime.now().fiscalYear()} • ${DateTime.now().financialQuarter()}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
              value: "This Financial Year",
              child: Text("This Financial Year"),
            ),
            const PopupMenuItem(
              value: "Last Financial Year",
              child: Text("Last Financial Year"),
            ),
            const PopupMenuItem(
              value: "Select Financial Year",
              child: Text("Select FY..."),
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                onTap: () => context.push('/invoices'),
                title: "Revenue ($selectedFilter)",
                value: totalRevenue.toIndianFormat(
                  includeSymbol: true,
                  symbol: profile.currency,
                ),
                icon: Icons.currency_rupee,
                color: Colors.green,
                trend: revenueTrend,
              ),
            ),
            const Gap(16),
            Expanded(
              child: DashboardStatCard(
                onTap: () => context.push('/invoices'),
                title: "Invoices",
                value: "${invoices.length}",
                icon: Icons.description,
                color: Colors.blue,
                trend: countTrend,
              ),
            ),
          ],
        ),
        const Gap(32),
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
          value: totalGst.toIndianFormat(
            includeSymbol: true,
            symbol: profile.currency,
          ),
          icon: Icons.percent,
          color: Colors.purple,
          trend: gstTrend,
        ),
        if (totalGst > 0) ...[
          const Gap(32),
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
                  const Gap(16),
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
        const Gap(16),
        Row(
          children: [
            DashboardActionButton(
              label: "New Invoice",
              icon: Icons.add,
              bgColor: theme.colorScheme.primaryContainer,
              onTap: () => context
                  .push('/invoice-form')
                  .then((_) => ref.refresh(invoiceListProvider)),
            ),
            const Gap(16),
            DashboardActionButton(
              label: "Payments",
              icon: Icons.payment,
              bgColor: Colors.green.shade100,
              onTap: () => context.push('/payments'),
            ),
            const Gap(16),
            DashboardActionButton(
              label: "Clients",
              icon: Icons.contacts,
              bgColor: Colors.blue.shade100,
              onTap: () => context.push('/clients'),
            ),
            const Gap(16),
            DashboardActionButton(
              label: "Audit",
              icon: Icons.warning_amber,
              bgColor: Colors.orange.shade100,
              onTap: () => context.push('/audit'),
            ),
          ],
        ),
        const Gap(16),
        Row(
          children: [
            DashboardActionButton(
              label: "Recurring",
              icon: Icons.autorenew,
              bgColor: Colors.purple.shade100,
              onTap: () => context.push('/recurring'),
            ),
            const Gap(16),
            DashboardActionButton(
              label: "Export GSTR-1",
              icon: Icons.table_chart,
              bgColor: theme.colorScheme.tertiaryContainer,
              onTap: () async => _exportGstr1(context, invoices),
            ),
            const Gap(16),
            DashboardActionButton(
              label: "Export GSTR-3B",
              icon: Icons.summarize,
              bgColor: theme.colorScheme.secondaryContainer,
              onTap: () async => _exportGstr3b(context, invoices),
            ),
            const Gap(16),
            DashboardActionButton(
              label: "Import Invoices",
              icon: Icons.upload_file,
              bgColor: theme.colorScheme.primaryContainer,
              onTap: () async => _importInvoices(context, ref),
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

      final csvData = await GstrService().generateGstr1CsvAsync(
        filteredInvoices,
      );
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save GSTR-1 CSV',
        fileName: 'GSTR1_${selectedFilter.replaceAll(" ", "_")}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
        bytes: Uint8List.fromList(utf8.encode(csvData)),
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

  Future<void> _importInvoices(
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text("Import Invoices"),
        content: const Text(
          "Would you like to import a CSV file or download a sample template?",
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, "template"),
            icon: const Icon(Icons.download),
            label: const Text("Template"),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, "json"),
            icon: const Icon(Icons.javascript),
            label: const Text("GSTR-1 JSON"),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, "import"),
            icon: const Icon(Icons.file_upload),
            label: const Text("Import CSV"),
          ),
        ],
      ),
    );

    if (choice == "template") {
      try {
        await InvoiceImportService.downloadImportTemplate();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Import template downloaded successfully")),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to download template: $e")),
        );
      }
      return;
    }

    if (choice == "json") {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await Gstr1JsonImportService.importGstr1Json(repository);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      if (result.successCount > 0) {
        ref.invalidate(invoiceListProvider);
      }
      return;
    }

    if (choice == "import") {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await InvoiceImportService.importInvoices(repository);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      if (result.successCount > 0) {
        ref.invalidate(invoiceListProvider);
      }
    }
  }

  Future<void> _exportGstr3b(
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

      final csvData = await Gstr3bService().generateGstr3bCsvAsync(
        filteredInvoices,
      );
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save GSTR-3B CSV',
        fileName: 'GSTR3B_${selectedFilter.replaceAll(" ", "_")}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
        bytes: Uint8List.fromList(utf8.encode(csvData)),
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
              onPressed: () => context.push('/invoices'),
              child: const Text("View All"),
            ),
          ],
        ),
        const Gap(8),
        if (invoices.isEmpty)
          EmptyStateIllustration(
            title: "No invoices yet",
            message: "Create your first invoice to get started",
            actionLabel: "Create Invoice",
            onAction: () => context
                .push('/invoice-form')
                .then((_) => ref.refresh(invoiceListProvider)),
          )
        else
          ...invoices
              .take(5)
              .map(
                (final inv) => Card(
                  child: ListTile(
                    onTap: () async {
                      await context.push('/invoice-detail', extra: inv);
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
                        const Gap(8),
                        DashboardStatusBadge(invoice: inv),
                      ],
                    ),
                    subtitle: Text(
                      "${inv.invoiceNo} • ${DateFormat('dd MMM').format(inv.invoiceDate)}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          inv.grandTotal.toIndianFormat(
                            includeSymbol: true,
                            symbol: ref.read(businessProfileProvider).currency,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (final value) async {
                            if (value == 'mark_sent') {
                              await InvoiceActions.markAsSent(ref, inv);
                              ref.invalidate(invoiceListProvider);
                            } else if (value == 'print') {
                              final profile = ref.read(businessProfileProvider);
                              try {
                                final pdfBytes = await generateInvoicePdf(
                                  inv,
                                  profile,
                                );
                                await Printing.layoutPdf(
                                  onLayout: (_) => pdfBytes,
                                );
                              } catch (e) {
                                debugPrint("Error printing from dashboard: $e");
                              }
                            }
                          },
                          itemBuilder: (final context) => [
                            if (inv.status != 'Sent' &&
                                inv.paymentStatus == 'Unpaid')
                              const PopupMenuItem(
                                value: 'mark_sent',
                                child: Text('Mark as Sent'),
                              ),
                            const PopupMenuItem(
                              value: 'print',
                              child: Text('Print/Export'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
