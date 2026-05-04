import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/ledger_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/utils/client_statement_generator.dart';
import 'package:printing/printing.dart';
import 'package:invobharat/utils/formatters.dart';

class ClientLedgerScreen extends ConsumerStatefulWidget {
  final Client client;

  const ClientLedgerScreen({super.key, required this.client});

  @override
  ConsumerState<ClientLedgerScreen> createState() => _ClientLedgerScreenState();
}

class _ClientLedgerScreenState extends ConsumerState<ClientLedgerScreen> {
  DateTime _startDate = DateTime(
    DateTime.now().year - 1,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime _endDate = DateTime.now();
  String _selectedRange = 'Last 12 Months';

  final List<String> _dateRanges = [
    'Last 30 Days',
    'Last 6 Months',
    'Last 12 Months',
    'This Financial Year',
    'Last Financial Year',
    'All Time',
  ];

  void _updateDateRange(final String range) {
    final now = DateTime.now();
    setState(() {
      _selectedRange = range;
      switch (range) {
        case 'Last 30 Days':
          _startDate = now.subtract(const Duration(days: 30));
          _endDate = now;
          break;
        case 'Last 6 Months':
          _startDate = DateTime(now.year, now.month - 6, now.day);
          _endDate = now;
          break;
        case 'Last 12 Months':
          _startDate = DateTime(now.year - 1, now.month, now.day);
          _endDate = now;
          break;
        case 'This Financial Year':
          final startYear = now.month < 4 ? now.year - 1 : now.year;
          _startDate = DateTime(startYear, 4);
          _endDate = now;
          break;
        case 'Last Financial Year':
          final startYear = now.month < 4 ? now.year - 2 : now.year - 1;
          _startDate = DateTime(startYear, 4);
          _endDate = DateTime(startYear + 1, 3, 31);
          break;
        case 'All Time':
          _startDate = DateTime(2000);
          _endDate = now;
          break;
      }
    });
  }

  Future<void> _printStatement() async {
    final profile = ref.read(businessProfileProvider);
    final invoices = await ref.read(invoiceRepositoryProvider).getAllInvoices();

    final params = ClientStatementParams(
      client: widget.client,
      profile: profile,
      invoices: invoices,
      dateRange: material.DateTimeRange(start: _startDate, end: _endDate),
    );

    final pdfBytes = await generateClientStatement(params);
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'statement_${widget.client.name}.pdf',
    );
  }

  @override
  Widget build(final BuildContext context) {
    final ledgerAsync = ref.watch(clientLedgerProvider(widget.client.name));

    return ScaffoldPage(
      header: PageHeader(
        title: Text('Ledger: ${widget.client.name}'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarBuilderItem(
              builder: (final context, final mode, final w) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ComboBox<String>(
                  value: _selectedRange,
                  items: _dateRanges.map((final range) {
                    return ComboBoxItem(value: range, child: Text(range));
                  }).toList(),
                  onChanged: (final value) {
                    if (value != null) _updateDateRange(value);
                  },
                ),
              ),
              wrappedItem: CommandBarButton(
                icon: const SizedBox.shrink(),
                label: const Text('Range'),
                onPressed: () {},
              ),
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.print),
              label: const Text('Print Statement'),
              onPressed: _printStatement,
            ),
          ],
        ),
      ),
      content: ledgerAsync.when(
        data: (final allEntries) {
          // Filter entries by date range
          final entries = allEntries
              .where(
                (final e) =>
                    e.date.isAfter(
                      _startDate.subtract(const Duration(days: 1)),
                    ) &&
                    e.date.isBefore(_endDate.add(const Duration(days: 1))),
              )
              .toList();

          if (entries.isEmpty) {
            return const Center(
              child: Text("No transactions found for this date range."),
            );
          }

          final totalDebit = entries.fold(
            0.0,
            (final sum, final e) => sum + e.debit,
          );
          final totalCredit = entries.fold(
            0.0,
            (final sum, final e) => sum + e.credit,
          );
          // Balance logic should ideally be calculated over filtered entries or keeping original running balance.
          // Since it's a ledger, keeping the original running balance from the entry is correct.
          final closingBalance = entries.last.balance;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildSummaryCard("Total Billed", totalDebit, Colors.blue),
                    const SizedBox(width: 16),
                    _buildSummaryCard("Total Paid", totalCredit, Colors.green),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      "Closing Balance",
                      closingBalance,
                      closingBalance > 0 ? Colors.red : Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                          return material.DataRow(
                            cells: [
                              material.DataCell(
                                Text(DateFormat('dd-MM-yyyy').format(e.date)),
                              ),
                              material.DataCell(Text(e.particulars)),
                              material.DataCell(Text(e.type)),
                              material.DataCell(
                                Text(
                                  e.debit > 0
                                      ? e.debit.toIndianFormat(
                                          includeSymbol: true,
                                          symbol: ref
                                              .read(businessProfileProvider)
                                              .currency,
                                        )
                                      : "",
                                ),
                              ),
                              material.DataCell(
                                Text(
                                  e.credit > 0
                                      ? e.credit.toIndianFormat(
                                          includeSymbol: true,
                                          symbol: ref
                                              .read(businessProfileProvider)
                                              .currency,
                                        )
                                      : "",
                                ),
                              ),
                              material.DataCell(
                                Text(
                                  e.balance.toIndianFormat(
                                    includeSymbol: true,
                                    symbol: ref
                                        .read(businessProfileProvider)
                                        .currency,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: e.balance > 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          );
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

  Widget _buildSummaryCard(
    final String title,
    final double amount,
    final Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                amount.toIndianFormat(
                  includeSymbol: true,
                  symbol: ref.read(businessProfileProvider).currency,
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
