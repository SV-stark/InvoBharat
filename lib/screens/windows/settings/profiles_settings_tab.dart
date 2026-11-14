import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';

class ProfilesSettingsTab extends ConsumerWidget {
  const ProfilesSettingsTab({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final profiles = ref.watch(businessProfileListProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return Column(
      children: [
        ...profiles.map((final p) {
          final isActive = p.id == activeId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              borderColor: isActive
                  ? FluentTheme.of(context).accentColor
                  : null,
              child: ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? FluentTheme.of(context).accentColor
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.companyName.isNotEmpty
                        ? p.companyName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  p.companyName,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : null,
                  ),
                ),
                subtitle: Text(
                  isActive ? 'Active Profile' : 'Switch to this profile',
                ),
                trailing: Row(
                  children: [
                    if (!isActive)
                      Button(
                        child: const Text("Switch"),
                        onPressed: () {
                          ref
                              .read(activeProfileIdProvider.notifier)
                              .selectProfile(p.id);
                        },
                      ),
                    const Gap(8),
                    if (profiles.length > 1)
                      IconButton(
                        icon: const Icon(FluentIcons.delete),
                        onPressed: () async {
                          if (isActive) {
                            await displayInfoBar(
                              context,
                              builder: (final context, final close) {
                                return InfoBar(
                                  title: const Text("Cannot Delete"),
                                  content: const Text(
                                    "Cannot delete the active profile. Switch to another profile first.",
                                  ),
                                  severity: InfoBarSeverity.error,
                                  onClose: close,
                                );
                              },
                            );
                            return;
                          }
                          await showDialog(
                            context: context,
                            builder: (final context) {
                              return ContentDialog(
                                title: const Text("Delete Profile?"),
                                content: Text(
                                  "Are you sure you want to delete ${p.companyName}? All associated data might be lost.",
                                ),
                                actions: [
                                  Button(
                                    child: const Text("Cancel"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  FilledButton(
                                    child: const Text("Delete"),
                                    onPressed: () {
                                      ref
                                          .read(
                                            businessProfileListProvider
                                                .notifier,
                                          )
                                          .deleteProfile(p.id);
                                      Navigator.pop(context);
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
            ),
          );
        }),
        const Gap(10),
        Button(
          child: const Text("Create New Profile"),
          onPressed: () {
            final TextEditingController nameCtrl = TextEditingController();
            showDialog(
              context: context,
              builder: (final context) {
                return ContentDialog(
                  title: const Text("New Business Profile"),
                  content: TextBox(
                    controller: nameCtrl,
                    placeholder: "Company Name",
                  ),
                  actions: [
                    Button(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FilledButton(
                      child: const Text("Create"),
                      onPressed: () {
                        if (nameCtrl.text.isNotEmpty) {
                          final newProfile = BusinessProfile.defaults()
                              .copyWith(
                                id: const Uuid().v4(),
                                companyName: nameCtrl.text,
                              );
                          ref
                              .read(businessProfileListProvider.notifier)
                              .addProfile(newProfile);
                          Navigator.pop(context);
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
    );
  }
}
