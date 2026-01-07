import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/estimate_provider.dart';
import 'fluent_estimate_form.dart';

class FluentEstimatesScreen extends ConsumerWidget {
  const FluentEstimatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimatesAsync = ref.watch(estimateListProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
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
                      builder: (context) => const FluentEstimateForm()),
                );
              },
            ),
          ],
        ),
      ),
      content: estimatesAsync.when(
        data: (estimates) {
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
                            builder: (context) => const FluentEstimateForm()),
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
            itemBuilder: (context, index) {
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
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${estimate.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusBadge(theme, estimate.status ?? 'Draft'),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        FluentPageRoute(
                          builder: (context) =>
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
        error: (err, stack) => Center(child: Text("Error: $err")),
        loading: () => const Center(child: ProgressRing()),
      ),
    );
  }

  Widget _buildStatusBadge(FluentThemeData theme, String status) {
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
}
