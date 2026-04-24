import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:gap/gap.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:uuid/uuid.dart';

void showProfileSwitcherSheet(final BuildContext context, final WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (final context) => const ProfileSwitcherSheet(),
  );
}

class ProfileSwitcherSheet extends ConsumerWidget {
  const ProfileSwitcherSheet({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final profiles = ref.watch(businessProfileListProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final profile = ref.watch(businessProfileProvider);
    final isDefaultProfile =
        profile.id == 'default' || profile.companyName == 'Your Company Name';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Business Profile",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(16),
          if (isDefaultProfile && profiles.isEmpty)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.business_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const Gap(8),
                const Text("No business profiles configured"),
                const Gap(4),
                Text(
                  "Please set up your business profile in Settings first.",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else if (profiles.isEmpty)
            const Text("No profiles found")
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: profiles.length,
                itemBuilder: (final context, final index) {
                  final p = profiles[index];
                  final isActive = p.id == activeId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(p.colorValue),
                      child: Text(
                        p.companyName.isNotEmpty
                            ? p.companyName[0].toUpperCase()
                            : "?",
                      ),
                    ),
                    title: Text(p.companyName),
                    subtitle: Text(p.gstin.isNotEmpty ? p.gstin : "No GSTIN"),
                    trailing: isActive
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      ref
                          .read(activeProfileIdProvider.notifier)
                          .selectProfile(p.id);
                      Navigator.pop(context);
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
          const Divider(),
          const Gap(8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showCreateProfileDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text("Create New Profile"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateProfileDialog(
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final TextEditingController nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text("New Business Profile"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Company Name",
            hintText: "Enter company name",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameCtrl.text),
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      final newProfile = BusinessProfile.defaults().copyWith(
        id: const Uuid().v4(),
        companyName: name.trim(),
      );
      await ref
          .read(businessProfileListProvider.notifier)
          .addProfile(newProfile);
      
      // Auto-select the new profile
      await ref
          .read(activeProfileIdProvider.notifier)
          .selectProfile(newProfile.id);
      
      if (context.mounted) {
        Navigator.pop(context); // Close the sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile '$name' created")),
        );
      }
    }
  }
}
