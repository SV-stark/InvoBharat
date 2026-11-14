import 'package:fluent_ui/fluent_ui.dart';
import 'package:material_ui/material_ui.dart' as fm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/theme_provider.dart';
import 'package:invobharat/providers/app_config_provider.dart';

class AppearanceSettingsTab extends ConsumerWidget {
  const AppearanceSettingsTab({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final appConfig = ref.watch(appConfigProvider);
    final profile = ref.watch(businessProfileProvider);
    final List<Map<String, dynamic>> accentColors = [
      {'name': 'Teal', 'color': const Color(0xFF009688)},
      {'name': 'Blue', 'color': const Color(0xFF2196F3)},
      {'name': 'Indigo', 'color': const Color(0xFF3F51B5)},
      {'name': 'Purple', 'color': const Color(0xFF9C27B0)},
      {'name': 'Pink', 'color': const Color(0xFFE91E63)},
      {'name': 'Red', 'color': const Color(0xFFF44336)},
      {'name': 'Orange', 'color': const Color(0xFFFF9800)},
      {'name': 'Green', 'color': const Color(0xFF4CAF50)},
      {'name': 'Slate', 'color': const Color(0xFF607D8B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Theme Mode", style: TextStyle(fontWeight: FontWeight.bold)),
        const Gap(10),
        ToggleSwitch(
          checked: themeMode == fm.ThemeMode.dark,
          content: Text(themeMode == fm.ThemeMode.dark ? "Dark" : "Light"),
          onChanged: (final v) {
            ref
                .read(themeProvider.notifier)
                .setTheme(v ? fm.ThemeMode.dark : fm.ThemeMode.light);
          },
        ),
        const Gap(24),
        const Text(
          "Sidebar Behavior",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Gap(10),
        SizedBox(
          width: 250,
          child: ComboBox<PaneDisplayMode>(
            value: appConfig.paneDisplayMode,
            items: const [
              ComboBoxItem(
                value: PaneDisplayMode.expanded,
                child: Text("Always Open"),
              ),
              ComboBoxItem(
                value: PaneDisplayMode.compact,
                child: Text("Compact (Icons Only)"),
              ),
            ],
            onChanged: (final mode) {
              if (mode != null) {
                ref.read(appConfigProvider.notifier).setPaneDisplayMode(mode);
              }
            },
          ),
        ),
        const Gap(24),
        const Text(
          "Accent Color",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: accentColors.map((final item) {
            final color = item['color'] as Color;
            final isSelected = profile.colorValue == color.toARGB32();
            return Tooltip(
              message: item['name'],
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(businessProfileListProvider.notifier)
                      .updateProfile(
                        profile.copyWith(colorValue: color.toARGB32()),
                      );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: FluentTheme.of(context).accentColor,
                            width: 3,
                          )
                        : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            FluentIcons.check_mark,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        const Gap(20),
        const InfoBar(
          title: Text("Custom Branding"),
          content: Text(
            "The accent color is saved per-profile. This allows you to have different branding for each business you manage.",
          ),
        ),
      ],
    );
  }
}
