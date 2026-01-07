import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/theme_provider.dart';

class FluentSettings extends ConsumerWidget {
  const FluentSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);
    final themeMode = ref.watch(themeProvider);

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      children: [
        Expander(
          header: const Text("Appearance"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleSwitch(
                checked: themeMode == ThemeMode.dark,
                content: const Text("Dark Mode"),
                onChanged: (v) {
                  ref
                      .read(themeProvider.notifier)
                      .setTheme(v ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expander(
          header: const Text("Business Profile"),
          content: Column(
            children: [
              InfoLabel(
                label: "Company Name",
                child: TextFormBox(
                  initialValue: profile.companyName,
                  onChanged: (v) => ref
                      .read(businessProfileProvider.notifier)
                      .updateProfile(profile.copyWith(companyName: v)),
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "GSTIN",
                child: TextFormBox(
                  initialValue: profile.gstin,
                  onChanged: (v) => ref
                      .read(businessProfileProvider.notifier)
                      .updateProfile(profile.copyWith(gstin: v)),
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Address",
                child: TextFormBox(
                  initialValue: profile.address,
                  maxLines: 3,
                  onChanged: (v) => ref
                      .read(businessProfileProvider.notifier)
                      .updateProfile(profile.copyWith(address: v)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
