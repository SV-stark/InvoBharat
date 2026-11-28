import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/utils/constants.dart';
import 'package:invobharat/utils/validators.dart';

class BusinessInfoSettingsTab extends ConsumerStatefulWidget {
  const BusinessInfoSettingsTab({super.key});

  @override
  ConsumerState<BusinessInfoSettingsTab> createState() =>
      _BusinessInfoSettingsTabState();
}

class _BusinessInfoSettingsTabState
    extends ConsumerState<BusinessInfoSettingsTab> {
  late TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    _stateController = TextEditingController();
  }

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    if (_stateController.text.isEmpty && profile.state.isNotEmpty) {
      _stateController.text = profile.state;
    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: (profile.logoPath != null && profile.logoPath!.isNotEmpty)
                  ? Image.file(File(profile.logoPath!), fit: BoxFit.contain)
                  : const Center(child: Icon(FluentIcons.photo2, size: 30)),
            ),
            const Gap(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Button(
                  child: const Text("Select Brand Logo"),
                  onPressed: () async {
                    try {
                      final result = await FilePicker.pickFile(
                        type: FileType.image,
                      );
                      if (result != null && result.path != null) {
                        await ref
                            .read(businessProfileListProvider.notifier)
                            .updateProfile(
                              profile.copyWith(logoPath: result.path!),
                            );
                      }
                    } catch (e) {
                      debugPrint("Error picking logo: $e");
                    }
                  },
                ),
                if (profile.logoPath != null &&
                    profile.logoPath!.isNotEmpty) ...[
                  const Gap(5),
                  HyperlinkButton(
                    child: const Text("Remove"),
                    onPressed: () {
                      ref
                          .read(businessProfileListProvider.notifier)
                          .updateProfile(profile.copyWith(logoPath: ""));
                    },
                  ),
                ],
              ],
            ),
            const Gap(30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Digital Signature",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(5),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          (profile.signaturePath != null &&
                              profile.signaturePath!.isNotEmpty)
                          ? Image.file(
                              File(profile.signaturePath!),
                              fit: BoxFit.contain,
                            )
                          : const Center(
                              child: Icon(FluentIcons.edit, size: 24),
                            ),
                    ),
                    const Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Button(
                          child: const Text("Upload Signature"),
                          onPressed: () async {
                            try {
                              final result = await FilePicker.pickFile(
                                type: FileType.image,
                              );
                              if (result != null && result.path != null) {
                                await ref
                                    .read(businessProfileListProvider.notifier)
                                    .updateProfile(
                                      profile.copyWith(
                                        signaturePath: result.path!,
                                      ),
                                    );
                              }
                            } catch (e) {
                              debugPrint("Error picking signature: $e");
                            }
                          },
                        ),
                        if (profile.signaturePath != null &&
                            profile.signaturePath!.isNotEmpty) ...[
                          const Gap(5),
                          HyperlinkButton(
                            child: const Text("Remove"),
                            onPressed: () {
                              ref
                                  .read(businessProfileListProvider.notifier)
                                  .updateProfile(
                                    profile.copyWith(signaturePath: ""),
                                  );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Gap(30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Business Stamp",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(5),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:
                          (profile.stampPath != null &&
                              profile.stampPath!.isNotEmpty)
                          ? ClipOval(
                              child: Image.file(
                                File(profile.stampPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(FluentIcons.tag, size: 24),
                            ),
                    ),
                    const Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Button(
                          child: const Text("Upload Stamp"),
                          onPressed: () async {
                            try {
                              final result = await FilePicker.pickFile(
                                type: FileType.image,
                              );
                              if (result != null && result.path != null) {
                                await ref
                                    .read(businessProfileListProvider.notifier)
                                    .updateProfile(
                                      profile.copyWith(stampPath: result.path!),
                                    );
                              }
                            } catch (e) {
                              debugPrint("Error picking stamp: $e");
                            }
                          },
                        ),
                        if (profile.stampPath != null &&
                            profile.stampPath!.isNotEmpty) ...[
                          const Gap(5),
                          HyperlinkButton(
                            child: const Text("Remove"),
                            onPressed: () {
                              ref
                                  .read(businessProfileListProvider.notifier)
                                  .updateProfile(
                                    profile.copyWith(stampPath: ""),
                                  );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const Gap(10),
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: InfoBar(
            title: Text("Tip: Use Transparent Images"),
            content: Text(
              "For best results on invoices, use PNG images with transparent backgrounds for your Logo, Signature, and Stamp.",
            ),
          ),
        ),
        const Gap(20),
        InfoLabel(
          label: "Company Name",
          child: TextFormBox(
            initialValue: profile.companyName,
            onChanged: (final v) => ref
                .read(businessProfileListProvider.notifier)
                .updateProfile(profile.copyWith(companyName: v)),
          ),
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: InfoLabel(
                label: "GSTIN",
                child: TextFormBox(
                  initialValue: profile.gstin,
                  validator: Validators.gstin,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (final v) => ref
                      .read(businessProfileListProvider.notifier)
                      .updateProfile(profile.copyWith(gstin: v)),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: InfoLabel(
                label: "Phone",
                child: TextFormBox(
                  initialValue: profile.phone,
                  onChanged: (final v) => ref
                      .read(businessProfileListProvider.notifier)
                      .updateProfile(profile.copyWith(phone: v)),
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        InfoLabel(
          label: "Email",
          child: TextFormBox(
            initialValue: profile.email,
            onChanged: (final v) => ref
                .read(businessProfileListProvider.notifier)
                .updateProfile(profile.copyWith(email: v)),
          ),
        ),
        const Gap(10),
        InfoLabel(
          label: "Address",
          child: TextFormBox(
            initialValue: profile.address,
            maxLines: 3,
            onChanged: (final v) => ref
                .read(businessProfileListProvider.notifier)
                .updateProfile(profile.copyWith(address: v)),
          ),
        ),
        const Gap(10),
        InfoLabel(
          label: "State",
          child: AutoSuggestBox<String>(
            controller: _stateController,
            items: AppStates.states
                .map(
                  (final e) => AutoSuggestBoxItem<String>(value: e, label: e),
                )
                .toList(),
            onSelected: (final item) {
              ref
                  .read(businessProfileListProvider.notifier)
                  .updateProfile(profile.copyWith(state: item.value!));
            },
            onChanged: (final text, final reason) {
              if (reason == TextChangedReason.userInput) {
                ref
                    .read(businessProfileListProvider.notifier)
                    .updateProfile(profile.copyWith(state: text));
              }
            },
            placeholder: "Select State",
          ),
        ),
        const Gap(24),
        const Divider(),
        const Gap(16),
        Text(
          "GST Compliance & Period Lock",
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const Gap(12),
        ToggleSwitch(
          checked: profile.isCompositionDealer,
          content: const Text(
            "Composition Scheme Dealer (Rule 46A — defaults new bills to Bill of Supply)",
          ),
          onChanged: (final v) => ref
              .read(businessProfileListProvider.notifier)
              .updateProfile(profile.copyWith(isCompositionDealer: v)),
        ),
        const Gap(12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: InfoLabel(
                label: "LUT Number (Exports / SEZ)",
                child: TextFormBox(
                  initialValue: profile.lutNumber ?? '',
                  placeholder: "e.g. AD270325001234A",
                  onChanged: (final v) => ref
                      .read(businessProfileListProvider.notifier)
                      .updateProfile(
                        profile.copyWith(
                          lutNumber: v.trim().isEmpty ? null : v.trim(),
                        ),
                      ),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: DatePicker(
                header: "LUT Filing Date",
                selected: profile.lutDate,
                onChanged: (final d) => ref
                    .read(businessProfileListProvider.notifier)
                    .updateProfile(profile.copyWith(lutDate: d)),
              ),
            ),
            if (profile.lutDate != null) ...[
              const Gap(8),
              Button(
                child: const Text("Clear"),
                onPressed: () => ref
                    .read(businessProfileListProvider.notifier)
                    .updateProfile(profile.copyWith(lutDate: null)),
              ),
            ],
          ],
        ),
        const Gap(12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: DatePicker(
                header: "Lock Books Through Date (Close Filed Periods)",
                selected: profile.booksLockedUntil,
                onChanged: (final d) => ref
                    .read(businessProfileListProvider.notifier)
                    .updateProfile(profile.copyWith(booksLockedUntil: d)),
              ),
            ),
            if (profile.booksLockedUntil != null) ...[
              const Gap(8),
              Button(
                child: const Text("Unlock"),
                onPressed: () => ref
                    .read(businessProfileListProvider.notifier)
                    .updateProfile(profile.copyWith(booksLockedUntil: null)),
              ),
            ],
          ],
        ),
        const Gap(4),
        const Text(
          "Invoices dated on or before the lock date cannot be created, edited, cancelled, or deleted.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
