// ignore_for_file: unawaited_futures
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/providers/app_config_provider.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/providers/estimate_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/recurring_provider.dart';
import 'package:invobharat/services/backup_service.dart';

class DataSettingsTab extends ConsumerWidget {
  const DataSettingsTab({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDataCard(
                context,
                "Invoices",
                ref.watch(invoiceListProvider),
                FluentIcons.invoice,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _buildClientDataCard(
                context,
                "Clients",
                ref.watch(clientListProvider),
                FluentIcons.contact,
              ),
            ),
          ],
        ),
        const Gap(8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDataCard(
                context,
                "Estimates",
                ref.watch(estimateListProvider),
                FluentIcons.document_set,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _buildDataCard(
                context,
                "Recurring",
                ref.watch(recurringListProvider),
                FluentIcons.repeat_all,
              ),
            ),
          ],
        ),
        const Gap(20),
        const Divider(),
        const Gap(20),
        const Text(
          "Auto Backup Schedule",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Gap(10),
        const Text(
          "Schedule automatic backups of your database to ensure your data is always safe.",
          style: TextStyle(color: Colors.grey),
        ),
        const Gap(15),
        ToggleSwitch(
          checked: ref.watch(appConfigProvider).autoBackupEnabled,
          content: const Text("Enable Auto Backup"),
          onChanged: (final v) async {
            await ref.read(appConfigProvider.notifier).setAutoBackupEnabled(v);
          },
        ),
        if (ref.watch(appConfigProvider).autoBackupEnabled) ...[
          const Gap(15),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: "Backup Frequency",
                  child: ComboBox<BackupFrequency>(
                    value: ref.watch(appConfigProvider).backupFrequency,
                    items: BackupFrequency.values
                        .where((final f) => f != BackupFrequency.none)
                        .map(
                          (final f) => ComboBoxItem(
                            value: f,
                            child: Text(
                              f.name[0].toUpperCase() + f.name.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (final v) async {
                      if (v != null) {
                        await ref
                            .read(appConfigProvider.notifier)
                            .setBackupFrequency(v);
                      }
                    },
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: InfoLabel(
                  label: "Backup Time",
                  child: TimePicker(
                    selected: DateTime(
                      2024,
                      1,
                      1,
                      int.parse(
                        ref.watch(appConfigProvider).backupTime.split(':')[0],
                      ),
                      int.parse(
                        ref.watch(appConfigProvider).backupTime.split(':')[1],
                      ),
                    ),
                    onChanged: (final time) async {
                      final timeStr =
                          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                      await ref
                          .read(appConfigProvider.notifier)
                          .setBackupTime(timeStr);
                    },
                  ),
                ),
              ),
            ],
          ),
          const Gap(15),
          if (ref.watch(appConfigProvider).lastAutoBackup != null)
            Text(
              "Last Auto Backup: ${DateFormat('dd MMM yyyy, hh:mm a').format(ref.watch(appConfigProvider).lastAutoBackup!)}",
              style: const TextStyle(color: Colors.grey),
            ),
        ],
        const Gap(20),
        const Divider(),
        const Gap(20),
        InfoLabel(
          label: "Manual Backup & Restore",
          child: const Text(
            "Export your data to a ZIP file or restore from a previous backup. Note: Logos and images are not included in the backup file.",
          ),
        ),
        const Gap(15),
        Row(
          children: [
            Expanded(
              child: Button(
                onPressed: () async {
                  try {
                    final result = await BackupService(
                      db: ref.read(databaseProvider),
                    ).exportFullBackup();
                    if (!context.mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Export Result'),
                          content: Text(result),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.success,
                        );
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Export Failed'),
                          content: Text(e.toString()),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.error,
                        );
                      },
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.encryption),
                    Gap(8),
                    Text("Export Backup (ZIP)"),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Button(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (final context) => ContentDialog(
                      title: const Text('Restore Backup Confirmation'),
                      content: const Text(
                        'Restoring a backup will overwrite your current business profiles, clients, invoices, and media files. This action cannot be undone.\n\nAre you sure you want to proceed?',
                      ),
                      actions: [
                        Button(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        FilledButton(
                          child: const Text('Restore Data'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;

                  try {
                    final result = await BackupService(
                      db: ref.read(databaseProvider),
                    ).restoreFullBackup();
                    if (!context.mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Restore Result'),
                          content: Text(result),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.success,
                        );
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Restore Failed'),
                          content: Text(e.toString()),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.error,
                        );
                      },
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.upload),
                    Gap(8),
                    Text("Restore Backup (ZIP)"),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        Expander(
          header: Text("Danger Zone", style: TextStyle(color: Colors.red)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Irreversible actions. Proceed with caution."),
              const Gap(10),
              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: const Text("Clear All App Data"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (final dialogContext) {
                      return ContentDialog(
                        title: const Text("Reset Everything?"),
                        content: const Text(
                          "This will delete ALL invoices, clients, estimates, and settings. This cannot be undone.",
                        ),
                        actions: [
                          Button(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.red,
                              ),
                            ),
                            child: const Text("Delete Everything"),
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              try {
                                await ref
                                    .read(invoiceRepositoryProvider)
                                    .deleteAll();
                                await ref
                                    .read(clientRepositoryProvider)
                                    .deleteAll();

                                ref.invalidate(invoiceListProvider);
                                ref.invalidate(clientListProvider);
                                ref.invalidate(estimateListProvider);
                                ref.invalidate(recurringListProvider);

                                if (!context.mounted) return;
                                displayInfoBar(
                                  context,
                                  builder: (final c, final close) => InfoBar(
                                    severity: InfoBarSeverity.success,
                                    title: const Text("Reset Complete"),
                                    content: const Text(
                                      "All data has been cleared.",
                                    ),
                                    onClose: close,
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                displayInfoBar(
                                  context,
                                  builder: (final c, final close) => InfoBar(
                                    severity: InfoBarSeverity.error,
                                    title: const Text("Error"),
                                    content: Text("Failed to clear data: $e"),
                                    onClose: close,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard<T>(
    final BuildContext context,
    final String title,
    final AsyncValue<List<T>> asyncValue,
    final IconData icon,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
              const Gap(8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Gap(8),
          asyncValue.when(
            data: (final data) => Text(
              "${data.length} Items",
              style: FluentTheme.of(context).typography.bodyLarge,
            ),
            loading: () => const ProgressRing(strokeWidth: 2),
            error: (final e, final s) =>
                Text("Error", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDataCard(
    final BuildContext context,
    final String title,
    final List<dynamic> data,
    final IconData icon,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
              const Gap(8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Gap(8),
          Text(
            "${data.length} Items",
            style: FluentTheme.of(context).typography.bodyLarge,
          ),
        ],
      ),
    );
  }
}
