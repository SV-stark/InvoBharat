import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:indian_formatters/indian_formatters.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

import 'package:invobharat/providers/invoice_repository_provider.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  String _selectedDateRange = 'All Time';
  String _selectedMode = 'All Modes';

  final List<String> _dateRanges = ['Last 30 Days', 'Last 6 Months', 'This Financial Year', 'All Time'];
  final List<String> _modes = ['All Modes', 'Cash', 'Bank Transfer', 'UPI', 'Cheque', 'Other'];

  bool _isWithinRange(final DateTime date, final String range) {
    final now = DateTime.now();
    switch (range) {
      case 'Last 30 Days':
        return now.difference(date).inDays <= 30;
      case 'Last 6 Months':
        return now.difference(date).inDays <= 180;
      case 'This Financial Year':
        final currentYear = now.month >= 4 ? now.year : now.year - 1;
        final startOfFy = DateTime(currentYear, 4, 1);
        return date.isAfter(startOfFy.subtract(const Duration(days: 1)));
      case 'All Time':
      default:
        return true;
    }
  }

  void _exportToCsv(final List<Map<String, dynamic>> data) async {
    final rows = <List<String>>[];
    rows.add(['Date', 'Client', 'Invoice No', 'Mode', 'Amount', 'Notes']);
    for (final entry in data) {
      final payment = entry['payment'] as dynamic;
      final invoice = entry['invoice'] as dynamic;
      rows.add([
        DateFormat('dd MMM yyyy').format(payment.date),
        invoice.receiver.name,
        invoice.invoiceNo,
        payment.paymentMode,
        payment.amount.toString(),
        payment.notes ?? '',
      ]);
    }

    final csvData = rows.map((final e) => e.join(',')).join('\n');
    try {
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Payment History CSV',
        fileName: 'Payment_History_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.csv')) {
          outputFile = '$outputFile.csv';
        }
        await File(outputFile).writeAsString(csvData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported to $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final invoiceListAsync = ref.watch(invoiceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        actions: [
          invoiceListAsync.maybeWhen(
            data: (final invoices) {
              final allPayments = _getFilteredPayments(invoices);
              return IconButton(
                icon: const Icon(Icons.download),
                tooltip: "Export CSV",
                onPressed: allPayments.isEmpty ? null : () => _exportToCsv(allPayments),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDateRange,
                    items: _dateRanges.map((final e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (final v) => setState(() => _selectedDateRange = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedMode,
                    items: _modes.map((final e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (final v) => setState(() => _selectedMode = v!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: invoiceListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (final err, final stack) => Center(child: Text("Error: $err")),
              data: (final invoices) {
                final allPayments = _getFilteredPayments(invoices);

                if (allPayments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No payments found for selected filters."),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allPayments.length,
                  separatorBuilder: (_, final _) => const Divider(),
                  itemBuilder: (final context, final index) {
                    final entry = allPayments[index];
                    final payment = entry['payment'] as dynamic;
                    final invoice = entry['invoice'] as dynamic;

                    return ListTile(
                      onTap: () {
                        context.push('/invoice-detail', extra: invoice);
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.check, color: Colors.green, size: 20),
                      ),
                      title: Text(invoice.receiver.name),
                      subtitle: Text(
                        "${DateFormat('dd MMM yyyy').format(payment.date)} • ${payment.paymentMode}\nInvoice #${invoice.invoiceNo}",
                      ),
                      trailing: Text(
                        IndianCurrencyFormatter.format(payment.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPayments(final List<dynamic> invoices) {
    var allPayments = invoices.expand((final inv) {
      return inv.payments.map((final p) => <String, dynamic>{'payment': p, 'invoice': inv});
    }).toList();

    allPayments = allPayments.where((final entry) {
      final payment = entry['payment'] as dynamic;
      final matchDate = _isWithinRange(payment.date, _selectedDateRange);
      final matchMode = _selectedMode == 'All Modes' || payment.paymentMode == _selectedMode;
      return matchDate && matchMode;
    }).toList();

    allPayments.sort((final a, final b) {
      final pA = a['payment'] as dynamic;
      final pB = b['payment'] as dynamic;
      return pB.date.compareTo(pA.date);
    });

    return allPayments.cast<Map<String, dynamic>>();
  }
}
