import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/invoice.dart';
import '../../providers/business_profile_provider.dart';
import '../../widgets/profile_switcher_sheet.dart';
import 'fluent_invoice_form.dart';
import '../../services/gstr_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../providers/invoice_repository_provider.dart';
import '../estimates_screen.dart';
import '../recurring_invoices_screen.dart';

final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  return ref.watch(invoiceRepositoryProvider).getAllInvoices();
});

class FluentDashboard extends ConsumerStatefulWidget {
  const FluentDashboard({super.key});

  @override
  ConsumerState<FluentDashboard> createState() => _FluentDashboardState();
}

class _FluentDashboardState extends ConsumerState<FluentDashboard> {
  String _selectedPeriod = "All Time";

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final invoiceListAsync = ref.watch(invoiceListProvider);

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
          style: FluentTheme.of(context).typography.titleLarge,
        ),
        const SizedBox(height: 20),
        invoiceListAsync.when(
          loading: () => const Center(child: ProgressRing()),
          error: (err, stack) => Text("Error: $err"),
          data: (allInvoices) {
            final filteredInvoices =
                _filterInvoices(allInvoices, _selectedPeriod);

            final totalRevenue =
                filteredInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);

            final totalCGST =
                filteredInvoices.fold(0.0, (sum, inv) => sum + inv.totalCGST);
            final totalSGST =
                filteredInvoices.fold(0.0, (sum, inv) => sum + inv.totalSGST);
            final totalIGST =
                filteredInvoices.fold(0.0, (sum, inv) => sum + inv.totalIGST);

            final currency = NumberFormat.currency(
                symbol: profile.currencySymbol, decimalDigits: 2);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions
                Row(children: [
                  FilledButton(
                      child: const Text("Create Invoice"),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          FluentPageRoute(
                            builder: (_) => const FluentInvoiceForm(),
                          ),
                        );
                        ref.invalidate(invoiceListProvider);
                      }),
                  const SizedBox(width: 12),
                  Button(
                    child: const Text("Export GSTR-1 (CSV)"),
                    onPressed: () async {
                      try {
                        final filteredInvoices =
                            _filterInvoices(allInvoices, _selectedPeriod);
                        if (filteredInvoices.isEmpty) {
                          displayInfoBar(context,
                              builder: (context, close) => InfoBar(
                                  title: const Text("No Invoices"),
                                  content: const Text(
                                      "No invoices to export for selected period"),
                                  onClose: close));
                          return;
                        }

                        final csvData =
                            GstrService().generateGstr1Csv(filteredInvoices);

                        String? outputFile = await FilePicker.platform.saveFile(
                          dialogTitle: 'Save GSTR-1 CSV',
                          fileName:
                              'GSTR1_${_selectedPeriod.replaceAll(" ", "_")}.csv',
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
                    },
                  ),
                  const SizedBox(width: 12),
                  Button(
                    child: const Text("Estimates"),
                    onPressed: () => Navigator.push(
                        context,
                        FluentPageRoute(
                            builder: (_) => const EstimatesScreen())),
                  ),
                  const SizedBox(width: 12),
                  Button(
                    child: const Text("Recurring"),
                    onPressed: () => Navigator.push(
                        context,
                        FluentPageRoute(
                            builder: (_) => const RecurringInvoicesScreen())),
                  ),
                ]),
                const SizedBox(height: 16),
                // Revenue & Count
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      "Total Revenue",
                      currency.format(totalRevenue),
                      FluentIcons.money,
                    ),
                    const SizedBox(width: 20),
                    _buildStatCard(
                      context,
                      "Invoices Generated",
                      "${filteredInvoices.length}",
                      FluentIcons.page_list,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // GST Stats
                const Text("GST Liability",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      "Total CGST",
                      currency.format(totalCGST),
                      FluentIcons.bank,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      context,
                      "Total SGST",
                      currency.format(totalSGST),
                      FluentIcons.bank,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      context,
                      "Total IGST",
                      currency.format(totalIGST),
                      FluentIcons.bank,
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Text(
                  "Filtered Invoices",
                  style: FluentTheme.of(context).typography.title,
                ),
                const SizedBox(height: 10),
                if (filteredInvoices.isEmpty)
                  const InfoBar(
                    title: Text("No invoices found for this period"),
                    severity: InfoBarSeverity.info,
                  )
                else
                  ...filteredInvoices.map((inv) => Padding(
                        // Show all or limited? User said "listed". Filtered list might be long. Let's show top 100 or all. I'll show top 10 for dashboard view.
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(FluentIcons.page_solid),
                            title: Text(inv.receiver.name),
                            subtitle: Text(
                                "${inv.invoiceNo} • ${DateFormat('dd MMM yyyy').format(inv.invoiceDate)}"),
                            trailing: Text(
                              currency.format(inv.grandTotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                FluentPageRoute(
                                  builder: (_) =>
                                      FluentInvoiceForm(invoiceToEdit: inv),
                                ),
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
      // Indian FY Apr-Jun of CURRENT fiscal year.
      // E.g. if now is Jan 2026. Fiscal year is 2025-26.
      // Q1 was Apr-Jun 2025.
      // If now is May 2026. Fiscal year is 2026-27. Q1 is Apr-Jun 2026.
      // Determining current FY: If month >= 4, FY = year. Else FY = year-1.
      final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
      start = DateTime(fyStartYear, 4, 1); // Apr 1
      end = DateTime(fyStartYear, 6, 30); // Jun 30
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
      start = DateTime(fyStartYear + 1, 1, 1); // Jan next year
      end = DateTime(fyStartYear + 1, 3,
          31); // Mar next year (leap handled by DateTime?) No. 31 is fixed.
    }

    if (start != null && end != null) {
      // Normalize invoices to date only or check range
      // Range check: start <= date <= end (inclusive or up to end of day)
      // DateTime compare usually compares Time. Invoices usually have time? Database might save time.
      // Let's assume start is 00:00:00 and end is 00:00:00?
      // Better: End should be end of day.
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

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    final theme = FluentTheme.of(context);
    return Expanded(
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: theme.accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.typography.caption,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: theme.typography.bodyStrong?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
