import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/recurring_provider.dart';

class FluentRecurringScreen extends ConsumerWidget {
  const FluentRecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringListAsync = ref.watch(recurringListProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Recurring Invoices'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('Run Checks'),
              onPressed: () {
                ref.read(recurringListProvider.notifier).runChecks();
              },
            ),
          ],
        ),
      ),
      content: recurringListAsync.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.repeat_all,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("No recurring profiles found.",
                      style:
                          theme.typography.title?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text(
                      "Open an invoice and select 'Make Recurring' to create one.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: profile.isActive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FluentIcons.repeat_one,
                        color: profile.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    title: Text(profile.baseInvoice.receiver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${profile.interval.name.toUpperCase()} • Next: ${DateFormat('dd MMM').format(profile.nextRunDate)} • ₹${profile.baseInvoice.grandTotal}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ToggleSwitch(
                          checked: profile.isActive,
                          onChanged: (val) {
                            ref
                                .read(recurringListProvider.notifier)
                                .updateProfile(profile.copyWith(isActive: val));
                          },
                          content: Text(profile.isActive ? "Active" : "Paused"),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(FluentIcons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => ContentDialog(
                                title: const Text("Delete Profile?"),
                                content: const Text(
                                    "This will stop future invoice generation permanently."),
                                actions: [
                                  Button(
                                    child: const Text("Cancel"),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  FilledButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            ButtonState.all(Colors.red)),
                                    child: const Text("Delete"),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              ref
                                  .read(recurringListProvider.notifier)
                                  .deleteProfile(profile.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: ProgressRing()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
