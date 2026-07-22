import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:invobharat/providers/aging_report_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/services/audit_service.dart';
import 'package:invobharat/services/gstr3b_service.dart';
import 'package:invobharat/services/gstr_service.dart';
import 'package:invobharat/services/excel_export_service.dart';
import 'package:invobharat/utils/formatters.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:file_picker/file_picker.dart';

class FluentReportsScreen extends ConsumerStatefulWidget {
  const FluentReportsScreen({super.key});

  @override
  ConsumerState<FluentReportsScreen> createState() =>
      _FluentReportsScreenState();
}

class _FluentReportsScreenState extends ConsumerState<FluentReportsScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'icon': FluentIcons.clock, 'label': 'Receivables Aging'},
    {'icon': FluentIcons.financial, 'label': 'GST Reports (GSTR)'},
    {'icon': FluentIcons.bulleted_list, 'label': 'Sequence Audit'},
  ];

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('Reports & Analytics')),
      content: Column(
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (final context, final index) {
                final tab = _tabs[index];
                final isSelected = _selectedIndex == index;
                final theme = FluentTheme.of(context);
                final color = isSelected ? theme.accentColor : theme.cardColor;
                final fgColor = isSelected
                    ? Colors.white
                    : theme.typography.body?.color;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Card(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tab['icon'], size: 24, color: fgColor),
                          const Gap(8),
                          Text(
                            tab['label'],
                            style: TextStyle(
                              color: fgColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildSelectedReport(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedReport() {
    switch (_selectedIndex) {
      case 0:
        return const AgingReportContent();
      case 1:
        return const GstReportsView();
      case 2:
        return const SequenceAuditView();
      default:
        return const Center(child: Text('Select a report'));
    }
  }
}

class AgingReportContent extends ConsumerWidget {
  const AgingReportContent({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final reportAsync = ref.watch(agingReportProvider);
    final currencySymbol = ref.read(businessProfileProvider).currency;

    return reportAsync.when(
      data: (final data) {
        if (data.totalReceivable == 0) {
          return const Center(
            child: Text("Great news! You have no outstanding receivables."),
          );
        }

        final sections = data.buckets
            .where((final b) => b.amount > 0)
            .map(
              (final b) => PieChartSectionData(
                color: b.color,
                value: b.amount,
                title: '',
                radius: 50,
              ),
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Outstanding: ${data.totalReceivable.toIndianFormat(includeSymbol: true, symbol: currencySymbol)}",
                  style: FluentTheme.of(context).typography.title,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
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
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(width: 16, height: 16, color: b.color),
                              const SizedBox(width: 8),
                              Text(
                                "${b.label}: ${b.amount.toIndianFormat(includeSymbol: true, symbol: currencySymbol)} (${b.count} inv)",
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Client Breakdown",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
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
                      amount.toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: material.Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: ProgressRing()),
      error: (final e, final s) => Center(child: Text("Error: $e")),
    );
  }
}

class GstReportsView extends ConsumerStatefulWidget {
  const GstReportsView({super.key});

  @override
  ConsumerState<GstReportsView> createState() => _GstReportsViewState();
}

class _GstReportsViewState extends ConsumerState<GstReportsView> {
  int _gstTab = 0;
  String _selectedMonth = 'All';

  final List<String> _months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(final BuildContext context) {
    final invoiceListAsync = ref.watch(invoiceListProvider);
    final currencySymbol = ref.read(businessProfileProvider).currency;

    return invoiceListAsync.when(
      loading: () => const Center(child: ProgressRing()),
      error: (final e, final s) => Center(child: Text('Error: $e')),
      data: (final invoices) {
        final filteredInvoices = invoices.where((final inv) {
          if (_selectedMonth == 'All') return true;
          final monthName = DateFormat('MMMM').format(inv.invoiceDate);
          return monthName == _selectedMonth;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    ToggleButton(
                      checked: _gstTab == 0,
                      onChanged: (_) => setState(() => _gstTab = 0),
                      child: const Text('GSTR-1 Summary'),
                    ),
                    const Gap(8),
                    ToggleButton(
                      checked: _gstTab == 1,
                      onChanged: (_) => setState(() => _gstTab = 1),
                      child: const Text('GSTR-3B Summary'),
                    ),
                  ],
                ),
                const Spacer(),
                const Text('Period: '),
                const Gap(8),
                ComboBox<String>(
                  value: _selectedMonth,
                  items: _months
                      .map(
                        (final e) =>
                            ComboBoxItem<String>(value: e, child: Text(e)),
                      )
                      .toList(),
                  onChanged: (final val) =>
                      setState(() => _selectedMonth = val ?? 'All'),
                ),
                const Gap(16),
                Button(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.download, size: 14),
                      const Gap(6),
                      Text(_gstTab == 0 ? 'Export GSTR-1 CSV' : 'Export GSTR-3B CSV'),
                    ],
                  ),
                  onPressed: () => _exportReport(context, filteredInvoices),
                ),
                const Gap(8),
                FilledButton(
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.excel_document, size: 14),
                      Gap(6),
                      Text('Export Excel (.xlsx)'),
                    ],
                  ),
                  onPressed: () => _exportExcelReport(context, filteredInvoices),
                ),
              ],
            ),
            const Gap(16),
            Expanded(
              child: _gstTab == 0
                  ? _buildGstr1Preview(filteredInvoices, currencySymbol)
                  : _buildGstr3bPreview(filteredInvoices, currencySymbol),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGstr1Preview(
    final List<Invoice> invoices,
    final String currencySymbol,
  ) {
    final List<Map<String, dynamic>> items = [];
    for (final inv in invoices) {
      final dateStr = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);
      final isB2B = inv.receiver.gstin.trim().isNotEmpty;
      for (final item in inv.items) {
        items.add({
          'invoiceNo': inv.invoiceNo,
          'date': dateStr,
          'gstin': inv.receiver.gstin.isEmpty ? 'B2C' : inv.receiver.gstin,
          'name': inv.receiver.name,
          'taxable': item.netAmount,
          'cgst': item.calculateCgst(inv.isInterState),
          'sgst': item.calculateSgst(inv.isInterState),
          'igst': item.calculateIgst(inv.isInterState),
          'type': isB2B ? 'B2B' : 'B2C',
        });
      }
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No invoice entries for GSTR-1 in this period.'),
      );
    }

    return Card(
      child: material.SingleChildScrollView(
        child: material.SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: material.DataTable(
            columns: const [
              material.DataColumn(label: Text('Invoice No')),
              material.DataColumn(label: Text('Date')),
              material.DataColumn(label: Text('Recipient GSTIN')),
              material.DataColumn(label: Text('Name')),
              material.DataColumn(label: Text('Taxable Value')),
              material.DataColumn(label: Text('CGST')),
              material.DataColumn(label: Text('SGST')),
              material.DataColumn(label: Text('IGST')),
              material.DataColumn(label: Text('Type')),
            ],
            rows: items.map((final item) {
              return material.DataRow(
                cells: [
                  material.DataCell(Text(item['invoiceNo'])),
                  material.DataCell(Text(item['date'])),
                  material.DataCell(Text(item['gstin'])),
                  material.DataCell(Text(item['name'])),
                  material.DataCell(
                    Text(
                      (item['taxable'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  material.DataCell(
                    Text(
                      (item['cgst'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  material.DataCell(
                    Text(
                      (item['sgst'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  material.DataCell(
                    Text(
                      (item['igst'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  material.DataCell(Text(item['type'])),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGstr3bPreview(
    final List<Invoice> invoices,
    final String currencySymbol,
  ) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final inv in invoices) {
      if (inv.items.isEmpty) continue;
      final isInter = inv.isInterState;

      for (final item in inv.items) {
        final rateKey = item.gstRate.toStringAsFixed(2);
        final section = isInter
            ? '3.1(a) - Inter-State'
            : '3.1(b) - Intra-State';
        final nature = isInter
            ? 'Inter-State supplies'
            : 'Intra-State supplies';
        final compositeKey = '$section|$rateKey';

        if (!grouped.containsKey(compositeKey)) {
          grouped[compositeKey] = {
            'section': section,
            'nature': nature,
            'rate': item.gstRate,
            'taxable': 0.0,
            'igst': 0.0,
            'cgst': 0.0,
            'sgst': 0.0,
          };
        }

        final entry = grouped[compositeKey]!;
        entry['taxable'] = (entry['taxable'] as double) + item.netAmount;
        if (isInter) {
          entry['igst'] = (entry['igst'] as double) + item.igstAmount;
        } else {
          entry['cgst'] = (entry['cgst'] as double) + item.cgstAmount;
          entry['sgst'] = (entry['sgst'] as double) + item.sgstAmount;
        }
      }
    }

    if (grouped.isEmpty) {
      return const Center(
        child: Text('No invoice entries for GSTR-3B in this period.'),
      );
    }

    return Card(
      child: material.SingleChildScrollView(
        child: material.SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: material.DataTable(
            columns: const [
              material.DataColumn(label: Text('Section')),
              material.DataColumn(label: Text('Nature of Supplies')),
              material.DataColumn(label: Text('GST Rate')),
              material.DataColumn(label: Text('Taxable Value')),
              material.DataColumn(label: Text('IGST')),
              material.DataColumn(label: Text('CGST')),
              material.DataColumn(label: Text('SGST')),
            ],
            rows: grouped.values.map((final entry) {
              return material.DataRow(
                cells: [
                  material.DataCell(Text(entry['section'])),
                  material.DataCell(Text(entry['nature'])),
                  material.DataCell(
                    Text('${(entry['rate'] as double).toStringAsFixed(1)}%'),
                  ),
                  material.DataCell(
                    Text(
                      (entry['taxable'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  material.DataCell(
                    Text(
                      (entry['igst'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  material.DataCell(
                    Text(
                      (entry['cgst'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                  material.DataCell(
                    Text(
                      (entry['sgst'] as double).toIndianFormat(
                        includeSymbol: true,
                        symbol: currencySymbol,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _exportReport(
    final BuildContext context,
    final List<Invoice> invoices,
  ) async {
    try {
      if (_gstTab == 0) {
        final csvData = await GstrService().generateGstr1CsvAsync(invoices);
        String? outputFile = await FilePicker.saveFile(
          dialogTitle: 'Save GSTR-1 CSV',
          fileName: 'GSTR1_$_selectedMonth.csv',
          allowedExtensions: ['csv'],
          type: FileType.custom,
          bytes: Uint8List.fromList(utf8.encode(csvData)),
        );
        if (outputFile != null) {
          if (!outputFile.toLowerCase().endsWith('.csv')) outputFile = '$outputFile.csv';
          await File(outputFile).writeAsString(csvData);
          if (context.mounted) {
            unawaited(
              displayInfoBar(
                context,
                builder: (final context, final close) => InfoBar(
                  title: const Text('Export Complete'),
                  content: Text('GSTR-1 CSV saved to $outputFile'),
                  severity: InfoBarSeverity.success,
                  onClose: close,
                ),
              ),
            );
          }
        }
      } else {
        final csvData = await Gstr3bService().generateGstr3bCsvAsync(invoices);
        String? outputFile = await FilePicker.saveFile(
          dialogTitle: 'Save GSTR-3B CSV',
          fileName: 'GSTR3B_$_selectedMonth.csv',
          allowedExtensions: ['csv'],
          type: FileType.custom,
          bytes: Uint8List.fromList(utf8.encode(csvData)),
        );
        if (outputFile != null) {
          if (!outputFile.toLowerCase().endsWith('.csv')) outputFile = '$outputFile.csv';
          await File(outputFile).writeAsString(csvData);
          if (context.mounted) {
            unawaited(
              displayInfoBar(
                context,
                builder: (final context, final close) => InfoBar(
                  title: const Text('Export Complete'),
                  content: Text('GSTR-3B CSV saved to $outputFile'),
                  severity: InfoBarSeverity.success,
                  onClose: close,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        unawaited(
          displayInfoBar(
            context,
            builder: (final context, final close) => InfoBar(
              title: const Text('Export Failed'),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
              onClose: close,
            ),
          ),
        );
      }
    }
  }

  Future<void> _exportExcelReport(
    final BuildContext context,
    final List<Invoice> invoices,
  ) async {
    try {
      final excelBytes = await ExcelExportService().generateInvoiceExcel(invoices);
      final savedPath = await ExcelExportService().saveExcelFile(
        excelBytes,
        'Invoices_Export_$_selectedMonth.xlsx',
      );
      if (savedPath != null && context.mounted) {
        unawaited(
          displayInfoBar(
            context,
            builder: (final context, final close) => InfoBar(
              title: const Text('Excel Export Complete'),
              content: Text('Workbook saved successfully to $savedPath'),
              severity: InfoBarSeverity.success,
              onClose: close,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        unawaited(
          displayInfoBar(
            context,
            builder: (final context, final close) => InfoBar(
              title: const Text('Excel Export Failed'),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
              onClose: close,
            ),
          ),
        );
      }
    }
  }
}

class SequenceAuditView extends ConsumerWidget {
  const SequenceAuditView({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoiceListAsync = ref.watch(invoiceListProvider);

    return invoiceListAsync.when(
      loading: () => const Center(child: ProgressRing()),
      error: (final err, final stack) => Center(child: Text("Error: $err")),
      data: (final invoices) {
        final missingSequences = AuditService.detectGaps(invoices);

        if (missingSequences.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FluentIcons.completed, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  "No invoice sequence gaps found.",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sequence Gaps Detected",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(12),
            Expanded(
              child: ListView.separated(
                itemCount: missingSequences.length,
                separatorBuilder: (final _, final _) => const Divider(),
                itemBuilder: (final context, final index) {
                  final missing = missingSequences[index];
                  return ListTile(
                    leading: Icon(FluentIcons.warning, color: Colors.orange),
                    title: Text("Missing Invoice: $missing"),
                    subtitle: const Text(
                      "This invoice number is skipped in your sequence.",
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
