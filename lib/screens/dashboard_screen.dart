import 'package:flutter/material.dart';
import '../widgets/profile_switcher_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'invoice_form.dart';
import 'invoice_detail_screen.dart';
import 'estimates_screen.dart';
import 'recurring_invoices_screen.dart';

import 'settings_screen.dart';
import '../providers/business_profile_provider.dart';

import '../providers/invoice_repository_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/gstr_service.dart';
import 'material_clients_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
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
            // Welcome Section ...
            Text(
              "Welcome back,",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey),
            ),
            Text(
              profile.companyName,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            invoiceListAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text("Error: $err"),
                data: (invoices) {
                  final totalRevenue =
                      invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
                  final currency = NumberFormat.simpleCurrency(
                      locale: 'en_IN', decimalDigits: 0);

                  return Column(children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                context,
                                "Total Revenue",
                                currency.format(totalRevenue),
                                Icons.currency_rupee,
                                Colors.green)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildStatCard(
                                context,
                                "Invoices Generated",
                                "${invoices.length}",
                                Icons.description,
                                Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    Text("Quick Actions",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            "New Invoice",
                            Icons.add,
                            Theme.of(context).colorScheme.primaryContainer,
                            () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const InvoiceFormScreen()))
                                .then((_) => ref.refresh(invoiceListProvider)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            "Clients",
                            Icons.contacts,
                            Colors.blue.shade100,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MaterialClientsScreen())),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            "Estimates",
                            Icons.request_quote,
                            Colors.orange.shade100,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EstimatesScreen())),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            "Recurring",
                            Icons.autorenew,
                            Colors.purple.shade100,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const RecurringInvoicesScreen())),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            "Export GSTR-1",
                            Icons.table_chart,
                            Theme.of(context).colorScheme.tertiaryContainer,
                            () async {
                              try {
                                final filteredInvoices =
                                    invoices; // Export all for now or filter? Dashboard usually shows recent. Let's export all visible.
                                if (filteredInvoices.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("No invoices to export")));
                                  return;
                                }

                                final csvData = GstrService()
                                    .generateGstr1Csv(filteredInvoices);

                                String? outputFile =
                                    await FilePicker.platform.saveFile(
                                  dialogTitle: 'Save GSTR-1 CSV',
                                  fileName: 'GSTR1_All_Time.csv',
                                  allowedExtensions: ['csv'],
                                  type: FileType.custom,
                                );

                                if (outputFile != null) {
                                  if (!outputFile
                                      .toLowerCase()
                                      .endsWith('.csv')) {
                                    outputFile = '$outputFile.csv';
                                  }
                                  await File(outputFile).writeAsString(csvData);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Exported to $outputFile")));
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text("Recent Invoices",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (invoices.isEmpty)
                      const Card(
                          child: ListTile(
                              leading: CircleAvatar(child: Icon(Icons.history)),
                              title: Text("No invoices yet")))
                    else
                      ...invoices.take(5).map((inv) => Card(
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
                                child: Icon(Icons.description)),
                            title: Text(inv.receiver.name),
                            subtitle: Text(
                                "${inv.invoiceNo} • ${DateFormat('dd MMM').format(inv.invoiceDate)}"),
                            trailing: Text(currency.format(inv.grandTotal),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          )))
                  ]);
                })
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color bgColor, VoidCallback onTap) {
    return InkWell(
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
            Icon(icon,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showProfileSwitcher(BuildContext context, WidgetRef ref) {
    showProfileSwitcherSheet(context, ref);
  }
}
