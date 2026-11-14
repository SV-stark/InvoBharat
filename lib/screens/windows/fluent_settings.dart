import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:invobharat/screens/windows/settings/appearance_settings_tab.dart';
import 'package:invobharat/screens/windows/settings/banking_settings_tab.dart';
import 'package:invobharat/screens/windows/settings/business_info_settings_tab.dart';
import 'package:invobharat/screens/windows/settings/data_settings_tab.dart';
import 'package:invobharat/screens/windows/settings/email_settings_tab.dart';
import 'package:invobharat/screens/windows/settings/invoice_style_settings_tab.dart';
import 'package:invobharat/screens/windows/settings/profiles_settings_tab.dart';

class FluentSettings extends ConsumerStatefulWidget {
  const FluentSettings({super.key});

  @override
  ConsumerState<FluentSettings> createState() => _FluentSettingsState();
}

class _FluentSettingsState extends ConsumerState<FluentSettings> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = const [
    {'icon': FluentIcons.group, 'label': 'Profiles'},
    {'icon': FluentIcons.color, 'label': 'Appearance'},
    {'icon': FluentIcons.shop, 'label': 'Business Info'},
    {'icon': FluentIcons.edit_mail, 'label': 'Invoice Style'},
    {'icon': FluentIcons.bank, 'label': 'Banking'},
    {'icon': FluentIcons.mail, 'label': 'Email Settings'},
    {'icon': FluentIcons.database, 'label': 'My Data'},
  ];

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('Settings')),
      content: Column(
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (final context, final index) {
                final tab = _tabs[index];
                final isSelected = _selectedIndex == index;
                final theme = FluentTheme.of(context);
                final color = isSelected ? theme.accentColor : theme.cardColor;
                final fgColor = isSelected
                    ? Colors.white
                    : theme.typography.body?.color;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Card(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tab['icon'], size: 24, color: fgColor),
                          const Gap(8),
                          Text(
                            tab['label'],
                            style: TextStyle(
                              color: fgColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_selectedIndex) {
      case 0:
        return const ProfilesSettingsTab();
      case 1:
        return const AppearanceSettingsTab();
      case 2:
        return const BusinessInfoSettingsTab();
      case 3:
        return const InvoiceStyleSettingsTab();
      case 4:
        return const BankingSettingsTab();
      case 5:
        return const EmailSettingsTab();
      case 6:
        return const DataSettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
