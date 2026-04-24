import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:invobharat/providers/recurring_provider.dart';

class RecurringInvoicesScreen extends ConsumerWidget {
  const RecurringInvoicesScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final recurringListAsync = ref.watch(recurringListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring Invoices"),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(recurringListProvider.notifier).runChecks();
              },
              tooltip: "Run Checks Now")
        ],
      ),
      body: recurringListAsync.when(
        data: (final profiles) {
          if (profiles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.loop, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No recurring profiles found."),
                  SizedBox(height: 8),
                  Text("Open an invoice and select 'Make Recurring'",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (final context, final index) {
              final profile = profiles[index];
              return Dismissible(
                key: Key(profile.id),
                background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white)),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await showDialog(
                      context: context,
                      builder: (final ctx) => AlertDialog(
                            title: const Text("Delete Profile?"),
                            content: const Text(
                                "This will stop future invoice generation."),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancel")),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Delete")),
                            ],
                          ));
                },
                onDismissed: (_) {
                  ref
                      .read(recurringListProvider.notifier)
                      .deleteProfile(profile.id);
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: profile.isActive
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      child: Icon(Icons.autorenew,
                          color: profile.isActive ? Colors.green : Colors.grey),
                    ),
                    title: Text(profile.baseInvoice.receiver.name),
                    subtitle: Text(
                        "${profile.interval.name.toUpperCase()} • Next: ${DateFormat('dd MMM').format(profile.nextRunDate)} • ₹${profile.baseInvoice.grandTotal}"),
                    trailing: Switch(
                        value: profile.isActive,
                        onChanged: (final val) {
                          ref
                              .read(recurringListProvider.notifier)
                              .updateProfile(profile.copyWith(isActive: val));
                        }),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (final err, final stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
