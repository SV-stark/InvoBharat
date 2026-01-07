import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_profile_provider.dart';
import '../models/business_profile.dart';
import 'package:uuid/uuid.dart';

void showProfileSwitcherSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) => const ProfileSwitcherSheet(),
  );
}

class ProfileSwitcherSheet extends ConsumerWidget {
  const ProfileSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(businessProfileListProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select Business Profile",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (profiles.isEmpty)
            const Text("No profiles found")
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final p = profiles[index];
                  final isActive = p.id == activeId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p.color,
                      child: Text(p.companyName.isNotEmpty
                          ? p.companyName[0].toUpperCase()
                          : "?"),
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
          ListTile(
            leading: const Icon(Icons.add_business),
            title: const Text("Create New Profile"),
            onTap: () async {
              Navigator.pop(context);
              _showCreateProfileDialog(context, ref);
            },
            contentPadding: EdgeInsets.zero,
          )
        ],
      ),
    );
  }

  void _showCreateProfileDialog(BuildContext context, WidgetRef ref) {
    if (Platform.isWindows) {
      _showFluentCreateProfileDialog(context, ref);
      return;
    }

    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Business Profile"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
              labelText: "Company Name", hintText: "Enter business name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _createProfile(context, ref, nameController.text);
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  void _showFluentCreateProfileDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => fluent.ContentDialog(
        title: const Text("New Business Profile"),
        content: fluent.TextBox(
          controller: nameController,
          placeholder: "Enter business name",
        ),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          fluent.FilledButton(
            onPressed: () async {
              await _createProfile(context, ref, nameController.text);
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  Future<void> _createProfile(
      BuildContext context, WidgetRef ref, String name) async {
    if (name.isNotEmpty) {
      try {
        final newProfile = BusinessProfile.defaults().copyWith(
          id: const Uuid().v4(),
          companyName: name,
        );

        await ref
            .read(businessProfileListProvider.notifier)
            .addProfile(newProfile);

        await ref
            .read(activeProfileIdProvider.notifier)
            .selectProfile(newProfile.id);

        if (context.mounted) {
          Navigator.pop(context);
          if (!Platform.isWindows) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile Created Successfully")));
          }
        }
      } catch (e) {
        debugPrint("Error creating profile: $e");
        if (context.mounted && !Platform.isWindows) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error creating profile: $e")));
        }
      }
    }
  }
}
