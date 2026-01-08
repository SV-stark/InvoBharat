import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fluent_dashboard.dart';

import 'fluent_invoice_form.dart';
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
            body: const FluentInvoiceForm(),
          ),
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
          PaneItem(
            icon: const Icon(FluentIcons.list),
            title: const Text('Estimates'),
            body: const FluentEstimatesScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.repeat_all),
            title: const Text('Recurring'),
            body: const FluentRecurringScreen(),
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
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color:
                                          FluentTheme.of(context).accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                        child: Icon(FluentIcons.invoice,
                                            size: 32, color: Colors.white)),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("InvoBharat",
                                          style: FluentTheme.of(context)
                                              .typography
                                              .title),
                                      const Text("Version 1.0.0"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                  "A comprehensive invoicing solution for Indian businesses.\n\nDeveloped with Flutter & Riverpod for Windows & Linux."),
                              const SizedBox(height: 10),
                              HyperlinkButton(
                                child: const Text("Visit Website"),
                                onPressed: () {
                                  // Open URL
                                },
                              ),
                            ],
                          ),
                          actions: [
                            Button(
                                child: const Text("Close"),
                                onPressed: () => Navigator.pop(context)),
                          ],
                        ));
              }),
        ],
      ),
    );
  }
}
