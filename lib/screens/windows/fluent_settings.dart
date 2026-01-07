import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/business_profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../utils/constants.dart';
import '../../services/backup_service.dart';

class FluentSettings extends ConsumerStatefulWidget {
  const FluentSettings({super.key});

  @override
  ConsumerState<FluentSettings> createState() => _FluentSettingsState();
}

class _FluentSettingsState extends ConsumerState<FluentSettings> {
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
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final themeMode = ref.watch(themeProvider);
    final appConfig = ref.watch(appConfigProvider);

    if (_stateController.text.isEmpty && profile.state.isNotEmpty) {
      _stateController.text = profile.state;
    }

    // Common accent colors
    final List<Color> accentColors = [
      Colors.teal,
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.magenta,
      Colors.yellow,
    ];

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      children: [
        // --- Appearance ---
        Expander(
          header: Text("Appearance",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FluentTheme.of(context).accentColor)),
          initiallyExpanded: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Theme Mode",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ToggleSwitch(
                checked: themeMode == ThemeMode.dark,
                content: Text(themeMode == ThemeMode.dark ? "Dark" : "Light"),
                onChanged: (v) {
                  ref
                      .read(themeProvider.notifier)
                      .setTheme(v ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              const SizedBox(height: 20),
              const Text("Sidebar Behavior",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ComboBox<PaneDisplayMode>(
                value: appConfig.paneDisplayMode,
                items: const [
                  ComboBoxItem(
                      value: PaneDisplayMode.open, child: Text("Always Open")),
                  ComboBoxItem(
                      value: PaneDisplayMode.compact,
                      child: Text("Compact (Icons Only)")),
                  ComboBoxItem(
                      value: PaneDisplayMode.minimal,
                      child: Text("Minimal (Hamburger)")),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    ref
                        .read(appConfigProvider.notifier)
                        .setPaneDisplayMode(mode);
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text("Accent Color",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: accentColors.map((color) {
                  final isSelected = profile.colorValue == color.toARGB32();
                  return IconButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      shape: WidgetStateProperty.all(const CircleBorder()),
                      backgroundColor: WidgetStateProperty.all(color),
                    ),
                    onPressed: () {
                      ref.read(businessProfileProvider.notifier).updateProfile(
                          profile.copyWith(colorValue: color.toARGB32()));
                    },
                    icon: isSelected
                        ? const Icon(FluentIcons.check_mark,
                            color: Colors.white, size: 16)
                        : const SizedBox(width: 16, height: 16),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // --- Business Profile ---
        Expander(
          header: Text("Business Profile (Supplier)",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FluentTheme.of(context).accentColor)),
          content: Column(
            children: [
              // Logo Picker
              Row(
                children: [
                  Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: (profile.logoPath != null &&
                              profile.logoPath!.isNotEmpty)
                          ? Image.file(File(profile.logoPath!),
                              fit: BoxFit.contain)
                          : const Center(
                              child: Icon(FluentIcons.photo2, size: 30))),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Button(
                        child: const Text("Select Brand Logo"),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            ref
                                .read(businessProfileProvider.notifier)
                                .updateProfile(
                                    profile.copyWith(logoPath: image.path));
                          }
                        },
                      ),
                      if (profile.logoPath != null) ...[
                        const SizedBox(height: 10),
                        HyperlinkButton(
                          child: const Text("Remove Logo"),
                          onPressed: () {
                            ref
                                .read(businessProfileProvider.notifier)
                                .updateProfile(profile.copyWith(logoPath: ""));
                          },
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Signature & Stamp
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Signature Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Digital Signature",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: (profile.signaturePath != null &&
                                      profile.signaturePath!.isNotEmpty)
                                  ? Image.file(File(profile.signaturePath!),
                                      fit: BoxFit.contain)
                                  : const Center(
                                      child: Icon(FluentIcons.edit, size: 24))),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Button(
                                child: const Text("Upload Signature"),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image != null) {
                                    ref
                                        .read(businessProfileProvider.notifier)
                                        .updateProfile(profile.copyWith(
                                            signaturePath: image.path));
                                  }
                                },
                              ),
                              if (profile.signaturePath != null) ...[
                                const SizedBox(height: 5),
                                HyperlinkButton(
                                  child: const Text("Remove"),
                                  onPressed: () {
                                    ref
                                        .read(businessProfileProvider.notifier)
                                        .updateProfile(profile.copyWith(
                                            signaturePath: ""));
                                  },
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  // Stamp Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Business Stamp",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(
                                    50), // Circular for stamp
                              ),
                              child: (profile.stampPath != null &&
                                      profile.stampPath!.isNotEmpty)
                                  ? ClipOval(
                                      child: Image.file(
                                          File(profile.stampPath!),
                                          fit: BoxFit.cover),
                                    )
                                  : const Center(
                                      child: Icon(FluentIcons.tag, size: 24))),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Button(
                                child: const Text("Upload Stamp"),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image != null) {
                                    ref
                                        .read(businessProfileProvider.notifier)
                                        .updateProfile(profile.copyWith(
                                            stampPath: image.path));
                                  }
                                },
                              ),
                              if (profile.stampPath != null) ...[
                                const SizedBox(height: 5),
                                HyperlinkButton(
                                  child: const Text("Remove"),
                                  onPressed: () {
                                    ref
                                        .read(businessProfileProvider.notifier)
                                        .updateProfile(
                                            profile.copyWith(stampPath: ""));
                                  },
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "GSTIN",
                      child: TextFormBox(
                        initialValue: profile.gstin,
                        onChanged: (v) => ref
                            .read(businessProfileProvider.notifier)
                            .updateProfile(profile.copyWith(gstin: v)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "Phone",
                      child: TextFormBox(
                        initialValue: profile.phone,
                        onChanged: (v) => ref
                            .read(businessProfileProvider.notifier)
                            .updateProfile(profile.copyWith(phone: v)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Email",
                child: TextFormBox(
                  initialValue: profile.email,
                  onChanged: (v) => ref
                      .read(businessProfileProvider.notifier)
                      .updateProfile(profile.copyWith(email: v)),
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
              const SizedBox(height: 10),
              InfoLabel(
                label: "State",
                child: AutoSuggestBox<String>(
                  controller: _stateController,
                  items: IndianStates.states
                      .map(
                          (e) => AutoSuggestBoxItem<String>(value: e, label: e))
                      .toList(),
                  onSelected: (item) {
                    ref
                        .read(businessProfileProvider.notifier)
                        .updateProfile(profile.copyWith(state: item.value!));
                  },
                  onChanged: (text, reason) {
                    if (reason == TextChangedReason.userInput) {
                      ref
                          .read(businessProfileProvider.notifier)
                          .updateProfile(profile.copyWith(state: text));
                    }
                  },
                  placeholder: "Select State",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // --- Invoice Customization ---
        Expander(
          header: Text("Invoice Customization",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FluentTheme.of(context).accentColor)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "Invoice Series Prefix",
                      child: TextFormBox(
                        initialValue: profile.invoiceSeries,
                        onChanged: (v) => ref
                            .read(businessProfileProvider.notifier)
                            .updateProfile(profile.copyWith(invoiceSeries: v)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "Current Sequence No",
                      child: NumberBox(
                        value: profile.invoiceSequence,
                        onChanged: (v) {
                          if (v != null) {
                            ref
                                .read(businessProfileProvider.notifier)
                                .updateProfile(
                                    profile.copyWith(invoiceSequence: v));
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Currency Symbol",
                child: ComboBox<String>(
                  value: profile.currencySymbol,
                  items: ['₹', '\$', '€', '£', '¥']
                      .map((e) => ComboBoxItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(businessProfileProvider.notifier)
                          .updateProfile(profile.copyWith(currencySymbol: val));
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Terms & Conditions",
                child: TextFormBox(
                  initialValue: profile.termsAndConditions,
                  maxLines: 3,
                  onChanged: (v) => ref
                      .read(businessProfileProvider.notifier)
                      .updateProfile(profile.copyWith(termsAndConditions: v)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // --- Banking Details ---
        Expander(
          header: Text("Bank Details (For Payments)",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FluentTheme.of(context).accentColor)),
          content: Column(
            children: [
              InfoLabel(
                label: "Bank Name",
                child: TextFormBox(
                  initialValue: profile.bankName,
                  onChanged: (v) => ref
                      .read(businessProfileProvider.notifier)
                      .updateProfile(profile.copyWith(bankName: v)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "Account Number",
                      child: TextFormBox(
                        initialValue: profile.accountNumber,
                        onChanged: (v) => ref
                            .read(businessProfileProvider.notifier)
                            .updateProfile(profile.copyWith(accountNumber: v)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "IFSC Code",
                      child: TextFormBox(
                        initialValue: profile.ifscCode,
                        onChanged: (v) => ref
                            .read(businessProfileProvider.notifier)
                            .updateProfile(profile.copyWith(ifscCode: v)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Branch Name",
                child: TextFormBox(
                  initialValue: profile.branchName,
                  onChanged: (v) => ref
                      .read(businessProfileProvider.notifier)
                      .updateProfile(profile.copyWith(branchName: v)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // --- Data Management ---
        Expander(
            header: Text("Data Management",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: FluentTheme.of(context).accentColor)),
            content: Column(
              children: [
                InfoLabel(
                  label: "Backup & Restore",
                  child: const Text(
                      "Export your data to a JSON file or restore from a previous backup. Note: Logos are not included in the backup file."),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        onPressed: () async {
                          try {
                            final result =
                                await BackupService().exportData(ref);
                            if (context.mounted) {
                              displayInfoBar(context,
                                  builder: (context, close) {
                                return InfoBar(
                                  title: const Text('Export Result'),
                                  content: Text(result),
                                  action: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: close),
                                  severity: InfoBarSeverity.success,
                                );
                              });
                            }
                          } catch (e) {
                            if (context.mounted) {
                              displayInfoBar(context,
                                  builder: (context, close) {
                                return InfoBar(
                                  title: const Text('Export Failed'),
                                  content: Text(e.toString()),
                                  action: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: close),
                                  severity: InfoBarSeverity.error,
                                );
                              });
                            }
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FluentIcons.encryption),
                            SizedBox(width: 8),
                            Text("Export Backup"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Button(
                        onPressed: () async {
                          try {
                            final result =
                                await BackupService().importData(ref);
                            if (context.mounted) {
                              displayInfoBar(context,
                                  builder: (context, close) {
                                return InfoBar(
                                  title: const Text('Import Result'),
                                  content: Text(result),
                                  action: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: close),
                                  severity: InfoBarSeverity.success,
                                );
                              });
                            }
                          } catch (e) {
                            if (context.mounted) {
                              displayInfoBar(context,
                                  builder: (context, close) {
                                return InfoBar(
                                  title: const Text('Import Failed'),
                                  content: Text(e.toString()),
                                  action: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: close),
                                  severity: InfoBarSeverity.error,
                                );
                              });
                            }
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FluentIcons.download),
                            SizedBox(width: 8),
                            Text("Import Backup"),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )),
      ],
    );
  }
}
