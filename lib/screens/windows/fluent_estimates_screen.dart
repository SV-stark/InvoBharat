import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:invobharat/providers/estimate_provider.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/estimate.dart';
import 'package:invobharat/screens/windows/fluent_estimate_form.dart';
import 'package:invobharat/screens/windows/fluent_invoice_form.dart';

class FluentEstimatesScreen extends ConsumerWidget {
  const FluentEstimatesScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final estimatesAsync = ref.watch(estimateListProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(FluentIcons.back),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
        title: const Text('Estimates'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New Estimate'),
              onPressed: () {
                Navigator.push(
                  context,
                  FluentPageRoute(
                      builder: (final context) => const FluentEstimateForm()),
                );
              },
            ),
          ],
        ),
      ),
      content: estimatesAsync.when(
        data: (final estimates) {
          if (estimates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.page_solid,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("No estimates created",
                      style:
                          theme.typography.title?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FluentPageRoute(
                            builder: (final context) => const FluentEstimateForm()),
                      );
                    },
                    child: const Text("Create Estimate"),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: estimates.length,
            itemBuilder: (final context, final index) {
              final estimate = estimates[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(FluentIcons.page_solid),
                    title: Text(estimate.receiver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${estimate.estimateNo} • ${DateFormat('dd MMM yyyy').format(estimate.date)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${estimate.totalAmount.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            _buildStatusBadge(
                                theme, estimate.status ?? 'Draft'),
                          ],
                        ),
                        if (estimate.status != 'Converted') ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon:
                                const Icon(FluentIcons.switch_widget, size: 18),
                            onPressed: () =>
                                _convertToInvoice(context, estimate),
                          ),
                        ],
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        FluentPageRoute(
                          builder: (final context) =>
                              FluentEstimateForm(estimateId: estimate.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        error: (final err, final stack) => Center(child: Text("Error: $err")),
        loading: () => const Center(child: ProgressRing()),
      ),
    );
  }

  Widget _buildStatusBadge(final FluentThemeData theme, final String status) {
    Color color;
    switch (status) {
      case 'Accepted':
      case 'Converted':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      case 'Sent':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, color: color),
      ),
    );
  }

  void _convertToInvoice(final BuildContext context, final Estimate estimate) {
    final invoice = Invoice(
      supplier: estimate.supplier,
      receiver: estimate.receiver,
      items: estimate.items.map((final e) => e.copyWith(id: null)).toList(),
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      // Convert Notes/Terms to comments?
      comments: estimate.notes.isNotEmpty ? estimate.notes : '',
      paymentTerms: estimate.terms.isNotEmpty ? estimate.terms : '',
    );

    Navigator.push(
      context,
      FluentPageRoute(
        builder: (final context) => FluentInvoiceForm(
          invoiceToEdit: invoice,
          estimateIdToMarkConverted: estimate.id,
        ),
      ),
    );
  }
}
