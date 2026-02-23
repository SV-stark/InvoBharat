import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invobharat/screens/windows/fluent_dashboard.dart';

import 'package:invobharat/screens/windows/fluent_invoice_wizard.dart';
import 'package:invobharat/screens/windows/fluent_settings.dart';
import 'package:invobharat/screens/clients_screen.dart';
import 'package:invobharat/screens/windows/fluent_recurring_screen.dart';
import 'package:invobharat/screens/windows/fluent_estimates_screen.dart';
import 'package:invobharat/screens/windows/fluent_item_templates_screen.dart';
import 'package:invobharat/screens/aging_report_screen.dart';

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
          appBar: NavigationAppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Image.asset('logo.png', width: 24, height: 24),
            ),
            title: Text('InvoBharat',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            automaticallyImplyLeading: false,
            actions: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: CommandBar(
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.add),
                        label: const Text('New Invoice'),
                        onPressed: () {
                          setState(() => topIndex = 1);
                        },
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.contact),
                        label: const Text('New Client'),
                        onPressed: () {
                          setState(() => topIndex = 5);
                        },
                      ),
                      const CommandBarSeparator(),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.refresh),
                        label: const Text('Refresh'),
                        onPressed: () {
                          // Refresh current view
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          pane: NavigationPane(
            selected: topIndex,
            onChanged: (final index) => setState(() => topIndex = index),
            displayMode: MediaQuery.of(context).size.width > 1000
                ? PaneDisplayMode.auto
                : PaneDisplayMode.compact,
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
                                  color: FluentTheme.of(context)
                                      .accentColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'logo.png',
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (final context, final error, final stackTrace) {
                                      return Icon(FluentIcons.invoice,
                                          size: 40,
                                          color: FluentTheme.of(context)
                                              .accentColor);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("InvoBharat",
                                        style: FluentTheme.of(context)
                                            .typography
                                            .titleLarge!
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("Version 1.0.0",
                                        style: FluentTheme.of(context)
                                            .typography
                                            .caption),
                                    const SizedBox(height: 12),
                                    const Text(
                                        "A modern, high-performance invoicing solution tailored for Indian businesses. Built with Flutter & Riverpod."),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Made with ❤️ in India",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const Text(
                                      "Developed by SV-stark",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text("Links & Resources",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Links placeholders
                          const Text("Visit GitHub Repository"),
                          const SizedBox(height: 10),
                          HyperlinkButton(
                            child: const Text("github.com/SV-stark/InvoBharat"),
                            onPressed: () => launchUrl(Uri.parse(
                                "https://github.com/SV-stark/InvoBharat")),
                          ),
                        ],
                      ),
                      actions: [
                        Button(
                            child: const Text("Close"),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
