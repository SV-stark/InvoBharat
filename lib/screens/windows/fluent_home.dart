import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fluent_dashboard.dart';

import 'fluent_invoice_form.dart';
import 'fluent_settings.dart';
import '../clients_screen.dart';

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
            icon: const Icon(FluentIcons.contact),
            title: const Text('Clients'),
            body: const ClientsScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.add),
            title: const Text('New Invoice'),
            body: const FluentInvoiceForm(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: const FluentSettings(),
          ),
        ],
      ),
    );
  }
}
