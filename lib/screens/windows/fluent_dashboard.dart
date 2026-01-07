import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/invoice_repository.dart';
import '../../models/invoice.dart';
import '../../providers/business_profile_provider.dart';
import 'fluent_invoice_form.dart';

final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  return InvoiceRepository().getAllInvoices();
});

class FluentDashboard extends ConsumerWidget {
  const FluentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);
    final invoiceListAsync = ref.watch(invoiceListProvider);

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Dashboard')),
      children: [
        Text(
          "Welcome back, ${profile.companyName}",
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 20),
        invoiceListAsync.when(
          loading: () => const Center(child: ProgressRing()),
          error: (err, stack) => Text("Error: $err"),
          data: (invoices) {
            final totalRevenue =
                invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
            final currency =
                NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      "${invoices.length}",
                      FluentIcons.page_list,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  "Recent Invoices",
                  style: FluentTheme.of(context).typography.title,
                ),
                const SizedBox(height: 10),
                if (invoices.isEmpty)
                  const InfoBar(
                    title: Text("No invoices yet"),
                    severity: InfoBarSeverity.info,
                  )
                else
                  ...invoices.take(5).map((inv) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(FluentIcons.page_solid),
                            title: Text(inv.receiver.name),
                            subtitle: Text(
                                "${inv.invoiceNo} • ${DateFormat('dd MMM').format(inv.invoiceDate)}"),
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

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 12),
            Text(title, style: FluentTheme.of(context).typography.body),
            const SizedBox(height: 4),
            Text(
              value,
              style: FluentTheme.of(context).typography.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
