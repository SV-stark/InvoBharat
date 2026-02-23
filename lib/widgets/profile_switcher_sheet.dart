import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/providers/business_profile_provider.dart';

void showProfileSwitcherSheet(final BuildContext context, final WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (final context) => const ProfileSwitcherSheet(),
  );
}

class ProfileSwitcherSheet extends ConsumerWidget {
  const ProfileSwitcherSheet({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
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
                itemBuilder: (final context, final index) {
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
        ],
      ),
    );
  }
}
