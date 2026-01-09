import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fluent_dashboard.dart';

import 'fluent_invoice_wizard.dart';
import 'fluent_settings.dart';
import '../clients_screen.dart';
import 'fluent_recurring_screen.dart';
import 'fluent_estimates_screen.dart';

import '../../providers/app_config_provider.dart';

class FluentHome extends ConsumerStatefulWidget {
  const FluentHome({super.key});

  @override
  ConsumerState<FluentHome> createState() => _FluentHomeState();
}

class _FluentHomeState extends ConsumerState<FluentHome> {
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);
    return NavigationView(
      appBar: NavigationAppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset('logo.png', width: 24, height: 24),
        ),
        title: Text('InvoBharat',
            style:
                GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: appConfig.paneDisplayMode,
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
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.contact),
            title: const Text('Clients'),
            body: const ClientsScreen(),
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
                builder: (context) => ContentDialog(
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
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Image.asset(
                                'logo.png',
                                width: 60,
                                height: 60,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(FluentIcons.invoice,
                                      size: 40,
                                      color:
                                          FluentTheme.of(context).accentColor);
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
                                        .copyWith(fontWeight: FontWeight.bold)),
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
    );
  }
}
