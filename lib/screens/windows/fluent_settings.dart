import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../models/business_profile.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/client_provider.dart'; // NEW
import '../../providers/estimate_provider.dart'; // NEW
import '../../providers/recurring_provider.dart'; // NEW
import '../../providers/invoice_repository_provider.dart'; // NEW
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../services/backup_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:path/path.dart' as p;
import 'dart:ui' as ui;

class FluentSettings extends ConsumerStatefulWidget {
  const FluentSettings({super.key});

  @override
  ConsumerState<FluentSettings> createState() => _FluentSettingsState();
}

class _FluentSettingsState extends ConsumerState<FluentSettings> {
  int _selectedIndex = 0;
  late TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    _stateController = TextEditingController();
    _initializeBackgroundRemover();
  }

  Future<void> _initializeBackgroundRemover() async {
    try {
      await BackgroundRemover.instance.initializeOrt();
    } catch (e) {
      debugPrint('Error initializing background remover: $e');
    }
  }

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _tabs = [
    {'icon': FluentIcons.group, 'label': 'Profiles'},
    {'icon': FluentIcons.color, 'label': 'Appearance'},
    {'icon': FluentIcons.shop, 'label': 'Business Info'},
    {'icon': FluentIcons.edit_mail, 'label': 'Invoice Style'},
    {'icon': FluentIcons.bank, 'label': 'Banking'},
    {'icon': FluentIcons.database, 'label': 'My Data'},
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    if (_stateController.text.isEmpty && profile.state.isNotEmpty) {
      _stateController.text = profile.state;
    }

    return ScaffoldPage(
      header: const PageHeader(title: Text('Settings')),
      content: Column(
        children: [
          // Horizontal Tab Bar using Cards
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _selectedIndex == index;
                final theme = FluentTheme.of(context);
                final color = isSelected ? theme.accentColor : theme.cardColor;
                final fgColor =
                    isSelected ? Colors.white : theme.typography.body?.color;

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
                          const SizedBox(height: 8),
                          Text(tab['label'],
                              style: TextStyle(
                                  color: fgColor, fontWeight: FontWeight.bold)),
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
        return _buildProfilesSection(context, ref);
      case 1:
        return _buildAppearanceSection();
      case 2:
        return _buildBusinessSection();
      case 3:
        return _buildInvoiceSection();
      case 4:
        return _buildBankingSection();
      case 5:
        return _buildDataSection();
      default:
        return Container();
    }
  }

  Widget _buildAppearanceSection() {
    final themeMode = ref.watch(themeProvider);
    final appConfig = ref.watch(appConfigProvider);
    final profile = ref.watch(businessProfileProvider);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Theme Mode", style: TextStyle(fontWeight: FontWeight.bold)),
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
              ref.read(appConfigProvider.notifier).setPaneDisplayMode(mode);
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
                ref.read(businessProfileNotifierProvider).updateProfile(
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
    );
  }

  Widget _buildBusinessSection() {
    final profile = ref.watch(businessProfileProvider);
    return Column(
      children: [
        // Logo Picker
        Row(
          children: [
            Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: (profile.logoPath != null &&
                        profile.logoPath!.isNotEmpty)
                    ? Image.file(File(profile.logoPath!), fit: BoxFit.contain)
                    : const Center(child: Icon(FluentIcons.photo2, size: 30))),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Button(
                  child: const Text("Select Brand Logo"),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      ref.read(businessProfileNotifierProvider).updateProfile(
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
                          .read(businessProfileNotifierProvider)
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
                              try {
                                final imageBytes = await image.readAsBytes();
                                final processedImage = await BackgroundRemover
                                    .instance
                                    .removeBg(imageBytes);
                                final byteData = await processedImage
                                    .toByteData(format: ui.ImageByteFormat.png);
                                final processedBytes =
                                    byteData!.buffer.asUint8List();

                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                final fileName = 'sig_${const Uuid().v4()}.png';
                                final savedFile =
                                    File(p.join(appDir.path, fileName));
                                await savedFile.writeAsBytes(processedBytes);

                                ref
                                    .read(businessProfileNotifierProvider)
                                    .updateProfile(profile.copyWith(
                                        signaturePath: savedFile.path));
                              } catch (e) {
                                if (!mounted) return;
                                displayInfoBar(context,
                                    builder: (context, close) {
                                  return InfoBar(
                                    title:
                                        const Text('Background Removal Failed'),
                                    content: Text(e.toString()),
                                    severity: InfoBarSeverity.error,
                                    action: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: close,
                                    ),
                                  );
                                });
                                ref
                                    .read(businessProfileNotifierProvider)
                                    .updateProfile(profile.copyWith(
                                        signaturePath: image.path));
                              }
                            }
                          },
                        ),
                        if (profile.signaturePath != null) ...[
                          const SizedBox(height: 5),
                          HyperlinkButton(
                            child: const Text("Remove"),
                            onPressed: () {
                              ref
                                  .read(businessProfileNotifierProvider)
                                  .updateProfile(
                                      profile.copyWith(signaturePath: ""));
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
                          borderRadius:
                              BorderRadius.circular(50), // Circular for stamp
                        ),
                        child: (profile.stampPath != null &&
                                profile.stampPath!.isNotEmpty)
                            ? ClipOval(
                                child: Image.file(File(profile.stampPath!),
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
                              try {
                                final imageBytes = await image.readAsBytes();
                                final processedImage = await BackgroundRemover
                                    .instance
                                    .removeBg(imageBytes);
                                final byteData = await processedImage
                                    .toByteData(format: ui.ImageByteFormat.png);
                                final processedBytes =
                                    byteData!.buffer.asUint8List();

                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                final fileName =
                                    'stamp_${const Uuid().v4()}.png';
                                final savedFile =
                                    File(p.join(appDir.path, fileName));
                                await savedFile.writeAsBytes(processedBytes);

                                ref
                                    .read(businessProfileNotifierProvider)
                                    .updateProfile(profile.copyWith(
                                        stampPath: savedFile.path));
                              } catch (e) {
                                if (!mounted) return;
                                displayInfoBar(context,
                                    builder: (context, close) {
                                  return InfoBar(
                                    title:
                                        const Text('Background Removal Failed'),
                                    content: Text(e.toString()),
                                    severity: InfoBarSeverity.error,
                                    action: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: close,
                                    ),
                                  );
                                });
                                ref
                                    .read(businessProfileNotifierProvider)
                                    .updateProfile(profile.copyWith(
                                        stampPath: image.path));
                              }
                            }
                          },
                        ),
                        if (profile.stampPath != null) ...[
                          const SizedBox(height: 5),
                          HyperlinkButton(
                            child: const Text("Remove"),
                            onPressed: () {
                              ref
                                  .read(businessProfileNotifierProvider)
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
                .read(businessProfileNotifierProvider)
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
                  validator: Validators.gstin,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (v) => ref
                      .read(businessProfileNotifierProvider)
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
                      .read(businessProfileNotifierProvider)
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
                .read(businessProfileNotifierProvider)
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
                .read(businessProfileNotifierProvider)
                .updateProfile(profile.copyWith(address: v)),
          ),
        ),
        const SizedBox(height: 10),
        InfoLabel(
          label: "State",
          child: AutoSuggestBox<String>(
            controller: _stateController,
            items: IndianStates.states
                .map((e) => AutoSuggestBoxItem<String>(value: e, label: e))
                .toList(),
            onSelected: (item) {
              ref
                  .read(businessProfileNotifierProvider)
                  .updateProfile(profile.copyWith(state: item.value!));
            },
            onChanged: (text, reason) {
              if (reason == TextChangedReason.userInput) {
                ref
                    .read(businessProfileNotifierProvider)
                    .updateProfile(profile.copyWith(state: text));
              }
            },
            placeholder: "Select State",
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSection() {
    final profile = ref.watch(businessProfileProvider);
    return Column(
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
                      .read(businessProfileNotifierProvider)
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
                          .read(businessProfileNotifierProvider)
                          .updateProfile(profile.copyWith(invoiceSequence: v));
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
                    .read(businessProfileNotifierProvider)
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
                .read(businessProfileNotifierProvider)
                .updateProfile(profile.copyWith(termsAndConditions: v)),
          ),
        ),
      ],
    );
  }

  Widget _buildBankingSection() {
    final profile = ref.watch(businessProfileProvider);
    return Column(
      children: [
        InfoLabel(
          label: "Bank Name",
          child: TextFormBox(
            initialValue: profile.bankName,
            onChanged: (v) => ref
                .read(businessProfileNotifierProvider)
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
                      .read(businessProfileNotifierProvider)
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
                      .read(businessProfileNotifierProvider)
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
                .read(businessProfileNotifierProvider)
                .updateProfile(profile.copyWith(branchName: v)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InfoLabel(
                label: "UPI ID (VPA)",
                child: TextFormBox(
                  initialValue: profile.upiId,
                  placeholder: "e.g. name@bank",
                  onChanged: (v) => ref
                      .read(businessProfileNotifierProvider)
                      .updateProfile(profile.copyWith(upiId: v)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InfoLabel(
                label: "UPI Name",
                child: TextFormBox(
                  initialValue: profile.upiName,
                  placeholder: "e.g. Business Name",
                  onChanged: (v) => ref
                      .read(businessProfileNotifierProvider)
                      .updateProfile(profile.copyWith(upiName: v)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      children: [
        // Stats Dashboard
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDataCard(
                context,
                "Invoices",
                ref.watch(invoiceListProvider),
                FluentIcons.invoice,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildClientDataCard(
                context,
                "Clients",
                ref.watch(clientListProvider),
                FluentIcons.contact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDataCard(
                context,
                "Estimates",
                ref.watch(estimateListProvider),
                FluentIcons.document_set,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDataCard(
                context,
                "Recurring",
                ref.watch(recurringListProvider),
                FluentIcons.repeat_all,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),

        // Backup Actions
        InfoLabel(
          label: "Backup & Restore",
          child: const Text(
              "Export your data to a CSV file or restore from a previous backup. Note: Logos and images are not included in the backup file."),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Button(
                onPressed: () async {
                  try {
                    final result = await BackupService().exportData(ref);
                    final context = this.context;
                    if (!context.mounted) return;
                    displayInfoBar(context, builder: (context, close) {
                      return InfoBar(
                        title: const Text('Export Result'),
                        content: Text(result),
                        action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close),
                        severity: InfoBarSeverity.success,
                      );
                    });
                  } catch (e) {
                    final context = this.context;
                    if (!context.mounted) return;
                    displayInfoBar(context, builder: (context, close) {
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
                    final result = await BackupService().importData(ref);
                    final context = this.context;
                    if (!context.mounted) return;
                    displayInfoBar(context, builder: (context, close) {
                      return InfoBar(
                        title: const Text('Import Result'),
                        content: Text(
                            "Restored: ${result.successCount}, Skipped: ${result.skippedCount}"),
                        action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close),
                        severity: InfoBarSeverity.success,
                      );
                    });
                  } catch (e) {
                    final context = this.context;
                    if (!context.mounted) return;
                    displayInfoBar(context, builder: (context, close) {
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
        ),
        const SizedBox(height: 10),
        // Danger Zone
        Expander(
          header: Text("Danger Zone", style: TextStyle(color: Colors.red)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Irreversible actions. Proceed with caution."),
              const SizedBox(height: 10),
              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: const Text("Clear All App Data"),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return ContentDialog(
                          title: const Text("Reset Everything?"),
                          content: const Text(
                              "This will delete ALL invoices, clients, estimates, and settings. This cannot be undone."),
                          actions: [
                            Button(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.pop(dialogContext)),
                            FilledButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.red)),
                                child: const Text("Delete Everything"),
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  try {
                                    await ref
                                        .read(invoiceRepositoryProvider)
                                        .deleteAll();
                                    await ref
                                        .read(clientRepositoryProvider)
                                        .deleteAll();
                                    await ref
                                        .read(estimateRepositoryProvider)
                                        .deleteAll();
                                    await ref
                                        .read(recurringRepositoryProvider)
                                        .deleteAll();

                                    ref.invalidate(invoiceListProvider);
                                    ref.invalidate(clientListProvider);
                                    ref.invalidate(estimateListProvider);
                                    ref.invalidate(recurringListProvider);

                                    final context = this.context;
                                    if (!context.mounted) return;
                                    displayInfoBar(context,
                                        builder: (c, close) => InfoBar(
                                            severity: InfoBarSeverity.success,
                                            title: const Text("Reset Complete"),
                                            content: const Text(
                                                "All data has been cleared."),
                                            onClose: close));
                                  } catch (e) {
                                    final context = this.context;
                                    if (!context.mounted) return;
                                    displayInfoBar(context,
                                        builder: (c, close) => InfoBar(
                                            severity: InfoBarSeverity.error,
                                            title: const Text("Error"),
                                            content: Text(
                                                "Failed to clear data: $e"),
                                            onClose: close));
                                  }
                                })
                          ],
                        );
                      });
                },
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProfilesSection(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(businessProfileListProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return Column(
      children: [
        ...profiles.map((p) {
          final isActive = p.id == activeId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              borderColor:
                  isActive ? FluentTheme.of(context).accentColor : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isActive
                      ? FluentTheme.of(context).accentColor
                      : Colors.grey,
                  radius: 16,
                  child: Text(
                      p.companyName.isNotEmpty
                          ? p.companyName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(p.companyName,
                    style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : null)),
                subtitle: Text(
                    isActive ? 'Active Profile' : 'Switch to this profile'),
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
                    const SizedBox(width: 8),
                    if (profiles.length > 1)
                      IconButton(
                        icon: const Icon(FluentIcons.delete),
                        onPressed: () async {
                          if (isActive) {
                            displayInfoBar(context, builder: (context, close) {
                              return InfoBar(
                                title: const Text("Cannot Delete"),
                                content: const Text(
                                    "Cannot delete the active profile. Switch to another profile first."),
                                severity: InfoBarSeverity.error,
                                onClose: close,
                              );
                            });
                            return;
                          }
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ContentDialog(
                                  title: const Text("Delete Profile?"),
                                  content: Text(
                                      "Are you sure you want to delete ${p.companyName}? All associated data might be lost."),
                                  actions: [
                                    Button(
                                        child: const Text("Cancel"),
                                        onPressed: () =>
                                            Navigator.pop(context)),
                                    FilledButton(
                                        child: const Text("Delete"),
                                        onPressed: () {
                                          ref
                                              .read(businessProfileListProvider
                                                  .notifier)
                                              .deleteProfile(p.id);
                                          Navigator.pop(context);
                                        }),
                                  ],
                                );
                              });
                        },
                      )
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        Button(
          child: const Text("Create New Profile"),
          onPressed: () {
            final TextEditingController nameCtrl = TextEditingController();
            showDialog(
                context: context,
                builder: (context) {
                  return ContentDialog(
                    title: const Text("New Business Profile"),
                    content: TextBox(
                      controller: nameCtrl,
                      placeholder: "Company Name",
                    ),
                    actions: [
                      Button(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context)),
                      FilledButton(
                          child: const Text("Create"),
                          onPressed: () {
                            if (nameCtrl.text.isNotEmpty) {
                              final newProfile =
                                  BusinessProfile.defaults().copyWith(
                                id: const Uuid().v4(),
                                companyName: nameCtrl.text,
                              );
                              ref
                                  .read(businessProfileListProvider.notifier)
                                  .addProfile(newProfile);
                              Navigator.pop(context);
                            }
                          }),
                    ],
                  );
                });
          },
        )
      ],
    );
  }

  Widget _buildDataCard<T>(BuildContext context, String title,
      AsyncValue<List<T>> asyncValue, IconData icon) {
    return Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          asyncValue.when(
            data: (data) => Text("${data.length} Items",
                style: FluentTheme.of(context).typography.bodyLarge),
            loading: () => const ProgressRing(strokeWidth: 2),
            error: (e, s) => Text("Error", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDataCard(
      BuildContext context, String title, List<dynamic> data, IconData icon) {
    return Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Text("${data.length} Items",
              style: FluentTheme.of(context).typography.bodyLarge),
        ],
      ),
    );
  }
}
