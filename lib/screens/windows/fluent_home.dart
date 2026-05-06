import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/screens/windows/fluent_dashboard.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'package:invobharat/services/update_service.dart';

import 'package:invobharat/screens/windows/fluent_invoice_wizard.dart';
import 'package:invobharat/screens/windows/fluent_settings.dart';
import 'package:invobharat/screens/clients_screen.dart';
import 'package:invobharat/screens/windows/fluent_recurring_screen.dart';
import 'package:invobharat/screens/windows/fluent_estimates_screen.dart';
import 'package:invobharat/screens/windows/fluent_item_templates_screen.dart';
import 'package:invobharat/screens/aging_report_screen.dart';
import 'package:invobharat/providers/app_config_provider.dart';

class FluentHome extends ConsumerStatefulWidget {
  const FluentHome({super.key});

  @override
  ConsumerState<FluentHome> createState() => _FluentHomeState();
}

class _FluentHomeState extends ConsumerState<FluentHome> {
  int topIndex = 0;

  @override
  Widget build(final BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          // Only pop if there isn't an active modal or unexpected focus
          // Better to use Navigator.maybePop which respects routing.
          // But we want to ensure it doesn't close if a dropdown/overlay is open?
          // Fluent UI's FlyingWidget or similar usually handles Esc.
          // We can check if we can pop.
          if (Navigator.canPop(context)) {
            Navigator.maybePop(context);
          }
        },
      },
      child: NavigationView(
        titleBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Image.asset('logo.png', width: 24, height: 24),
              const SizedBox(width: 10),
              const Text(
                'InvoBharat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              Tooltip(
                message: 'New Invoice',
                child: IconButton(
                  icon: const Icon(FluentIcons.add),
                  onPressed: () => setState(() => topIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'New Client',
                child: IconButton(
                  icon: const Icon(FluentIcons.contact),
                  onPressed: () => setState(() => topIndex = 5),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Refresh',
                child: IconButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: () {
                    // Global refresh logic if needed
                  },
                ),
              ),
            ],
          ),
        ),
        pane: NavigationPane(
          selected: topIndex,
          onChanged: (final index) => setState(() => topIndex = index),
          displayMode: ref.watch(appConfigProvider).paneDisplayMode,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text('Dashboard'),
              body: const FluentDashboard(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.add),
              title: const Text('New Invoice'),
              body: const FluentInvoiceWizard(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.document_set),
              title: const Text('Estimates'),
              body: const FluentEstimatesScreen(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.repeat_all),
              title: const Text('Recurring'),
              body: const FluentRecurringScreen(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.page_list),
              title: const Text('Templates'),
              body: const FluentItemTemplatesScreen(),
            ),
            PaneItemSeparator(),
            PaneItem(
              icon: const Icon(FluentIcons.contact),
              title: const Text('Clients'),
              body: const ClientsScreen(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.report_document),
              title: const Text('Reports'),
              body: const AgingReportScreen(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings'),
              body: const FluentSettings(),
            ),
          ],
          footerItems: [
            PaneItemAction(
              icon: const Icon(FluentIcons.info),
              title: const Text('About'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (final context) => ContentDialog(
                    title: const Text("About InvoBharat"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: FluentTheme.of(
                                  context,
                                ).accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'logo.png',
                                  width: 60,
                                  height: 60,
                                  errorBuilder:
                                      (
                                        final context,
                                        final error,
                                        final stackTrace,
                                      ) {
                                        return Icon(
                                          FluentIcons.invoice,
                                          size: 40,
                                          color: FluentTheme.of(
                                            context,
                                          ).accentColor,
                                        );
                                      },
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "InvoBharat",
                                    style: FluentTheme.of(context)
                                        .typography
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<PackageInfo>(
                                    future: PackageInfo.fromPlatform(),
                                    builder: (final context, final snapshot) {
                                      final version =
                                          snapshot.data?.version ?? '...';
                                      return Text(
                                        "Version $version",
                                        style: FluentTheme.of(
                                          context,
                                        ).typography.caption,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "A modern, high-performance invoicing solution tailored for Indian businesses. Built with Flutter & Riverpod.",
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Made with ❤️ in India",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const Text(
                                    "Developed by SV-stark",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Links & Resources",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        HyperlinkButton(
                          child: const Text("github.com/SV-stark/InvoBharat"),
                          onPressed: () => launchUrl(
                            Uri.parse("https://github.com/SV-stark/InvoBharat"),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Update Settings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text("Update Channel:"),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 150,
                              child: ComboBox<UpdateChannel>(
                                value:
                                    ref.watch(appConfigProvider).updateChannel,
                                items: const [
                                  ComboBoxItem(
                                    value: UpdateChannel.stable,
                                    child: Text("Stable"),
                                  ),
                                  ComboBoxItem(
                                    value: UpdateChannel.nightly,
                                    child: Text("Nightly"),
                                  ),
                                ],
                                onChanged: (final val) {
                                  if (val != null) {
                                    ref
                                        .read(appConfigProvider.notifier)
                                        .setUpdateChannel(val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      Button(
                        onPressed: () async {
                          final config = ref.read(appConfigProvider);
                          final packageInfo = await PackageInfo.fromPlatform();
                          final currentVersion = packageInfo.version;

                          final updates = await UpdateService.checkForUpdates();
                          final Release? latest =
                              config.updateChannel == UpdateChannel.stable
                                  ? updates['stable']
                                  : updates['nightly'];

                          if (latest == null) {
                            if (context.mounted) {
                              displayInfoBar(
                                context,
                                builder: (final context, final close) {
                                  return const InfoBar(
                                    title: Text("Update Check"),
                                    content: Text(
                                      "No updates found for this channel.",
                                    ),
                                    severity: InfoBarSeverity.info,
                                  );
                                },
                              );
                            }
                            return;
                          }

                          bool updateAvailable = false;
                          if (config.updateChannel == UpdateChannel.stable) {
                            updateAvailable =
                                latest.tagName.compareTo(currentVersion) > 0;
                          } else {
                            updateAvailable = latest.tagName != currentVersion;
                          }

                          if (!updateAvailable) {
                            if (context.mounted) {
                              displayInfoBar(
                                context,
                                builder: (final context, final close) {
                                  return const InfoBar(
                                    title: Text("Update Check"),
                                    content: Text(
                                      "You are on the latest version.",
                                    ),
                                    severity: InfoBarSeverity.success,
                                  );
                                },
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            unawaited(
                              showDialog(
                                context: context,
                                builder: (final context) {
                                  bool isDownloading = false;
                                  return StatefulBuilder(
                                    builder:
                                        (final context, final setDialogState) {
                                      return ContentDialog(
                                        title: Text(
                                          config.updateChannel ==
                                                  UpdateChannel.stable
                                              ? 'New Version Available'
                                              : 'New Nightly Build Available',
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Current: $currentVersion'),
                                            Text('Latest: ${latest.tagName}'),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Published: ${latest.publishedAt}',
                                            ),
                                            if (latest.body != null) ...[
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Changelog:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                latest.body!,
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            if (isDownloading) ...[
                                              const SizedBox(height: 20),
                                              const ProgressBar(),
                                              const SizedBox(height: 10),
                                              const Text(
                                                "Downloading and preparing update...",
                                              ),
                                            ],
                                          ],
                                        ),
                                        actions: [
                                          Button(
                                            onPressed:
                                                isDownloading
                                                    ? null
                                                    : () => Navigator.pop(
                                                      context,
                                                    ),
                                            child: const Text('Later'),
                                          ),
                                          FilledButton(
                                            onPressed:
                                                isDownloading
                                                    ? null
                                                    : () async {
                                                      setDialogState(
                                                        () =>
                                                            isDownloading =
                                                                true,
                                                      );
                                                      try {
                                                        await UpdateService
                                                            .downloadAndInstallUpdate(
                                                              latest,
                                                            );
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          displayInfoBar(
                                                            context,
                                                            builder:
                                                                (
                                                                  final context,
                                                                  final close,
                                                                ) {
                                                              return InfoBar(
                                                                title: const Text(
                                                                  "Update Failed",
                                                                ),
                                                                content: Text(
                                                                  e.toString(),
                                                                ),
                                                                severity:
                                                                    InfoBarSeverity
                                                                        .error,
                                                              );
                                                            },
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        }
                                                      }
                                                    },
                                            child: const Text('Update Now'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        },
                        child: const Text("Check for Updates"),
                      ),
                      Button(
                        child: const Text("Close"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
