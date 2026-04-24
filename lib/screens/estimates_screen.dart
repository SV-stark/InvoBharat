import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:invobharat/providers/estimate_provider.dart';
import 'package:go_router/go_router.dart';

class EstimatesScreen extends ConsumerWidget {
  const EstimatesScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final estimatesAsync = ref.watch(estimateListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimates"),
      ),
      body: estimatesAsync.when(
        data: (final estimates) {
          if (estimates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.request_quote_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("No estimates created",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.push('/estimate-form');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Create Estimate"),
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
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.request_quote),
                  ),
                  title: Text(estimate.receiver.name),
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
                  onTap: () {
                    context.push('/estimate-form', extra: estimate.id);
                  },
                ),
              );
            },
          );
        },
        error: (final err, final stack) => Center(child: Text("Error: $err")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/estimate-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusBadge(final ThemeData theme, final String status) {
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
