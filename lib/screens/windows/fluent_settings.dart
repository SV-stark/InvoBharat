// ignore_for_file: unawaited_futures
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:invobharat/models/business_profile.dart';
import 'package:indian_formatters/indian_formatters.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/theme_provider.dart';
import 'package:invobharat/providers/app_config_provider.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/providers/estimate_provider.dart';
import 'package:invobharat/providers/recurring_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/utils/constants.dart';
import 'package:invobharat/utils/validators.dart';
import 'package:invobharat/services/backup_service.dart';
import 'package:invobharat/models/bank_account.dart' as bank_model;
import 'package:invobharat/providers/bank_provider.dart';
import 'package:gap/gap.dart';

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
  Widget build(final BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    if (_stateController.text.isEmpty && profile.state.isNotEmpty) {
      _stateController.text = profile.state;
    }

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
          checked: themeMode == ThemeMode.dark,
          content: Text(themeMode == ThemeMode.dark ? "Dark" : "Light"),
          onChanged: (final v) {
            ref
                .read(themeProvider.notifier)
                .setTheme(v ? ThemeMode.dark : ThemeMode.light);
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
                value: PaneDisplayMode.auto,
                child: Text("Auto (Recommended)"),
              ),
              ComboBoxItem(
                value: PaneDisplayMode.expanded,
                child: Text("Always Open"),
              ),
              ComboBoxItem(
                value: PaneDisplayMode.compact,
                child: Text("Compact (Icons Only)"),
              ),
              ComboBoxItem(
                value: PaneDisplayMode.minimal,
                child: Text("Minimal (Hamburger)"),
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

  Widget _buildBusinessSection() {
    final profile = ref.watch(businessProfileProvider);
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
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      ref
                          .read(businessProfileListProvider.notifier)
                          .updateProfile(
                            profile.copyWith(logoPath: image.path),
                          );
                    }
                  },
                ),
                if (profile.logoPath != null &&
                    profile.logoPath!.isNotEmpty) ...[
                  const Gap(10),
                  HyperlinkButton(
                    child: const Text("Remove Logo"),
                    onPressed: () {
                      ref
                          .read(businessProfileListProvider.notifier)
                          .updateProfile(profile.copyWith(logoPath: ""));
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
        const Gap(20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      width: 100,
                      height: 60,
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
                            final picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              ref
                                  .read(businessProfileListProvider.notifier)
                                  .updateProfile(
                                    profile.copyWith(signaturePath: image.path),
                                  );
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
                            final picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              ref
                                  .read(businessProfileListProvider.notifier)
                                  .updateProfile(
                                    profile.copyWith(stampPath: image.path),
                                  );
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
                  onChanged: (final v) => ref
                      .read(businessProfileListProvider.notifier)
                      .updateProfile(profile.copyWith(invoiceSeries: v)),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: InfoLabel(
                label: "Current Sequence No",
                child: NumberBox(
                  value: profile.invoiceSequence,
                  onChanged: (final v) {
                    if (v != null) {
                      ref
                          .read(businessProfileListProvider.notifier)
                          .updateProfile(profile.copyWith(invoiceSequence: v));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        InfoLabel(
          label: "Currency Symbol",
          child: ComboBox<String>(
            value: profile.currency,
            items: [
              '₹',
              '\$',
              '€',
              '£',
              '¥',
            ].map((final e) => ComboBoxItem(value: e, child: Text(e))).toList(),
            onChanged: (final val) {
              if (val != null) {
                ref
                    .read(businessProfileListProvider.notifier)
                    .updateProfile(profile.copyWith(currency: val));
              }
            },
          ),
        ),
        const Gap(10),
        InfoLabel(
          label: "Terms & Conditions",
          child: TextFormBox(
            initialValue: profile.termsAndConditions,
            maxLines: 3,
            onChanged: (final v) => ref
                .read(businessProfileListProvider.notifier)
                .updateProfile(profile.copyWith(termsAndConditions: v)),
          ),
        ),
      ],
    );
  }

  Widget _buildBankingSection() {
    final banksAsync = ref.watch(bankListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Bank Accounts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Button(
              onPressed: () => _showAddEditBankDialog(context),
              child: const Row(
                children: [Icon(FluentIcons.add), Gap(8), Text("Add Bank")],
              ),
            ),
          ],
        ),
        const Gap(20),
        banksAsync.when(
          data: (final banks) {
            if (banks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "No bank accounts found. Add one to get started.",
                  ),
                ),
              );
            }
            return Column(
              children: banks.map((final bank) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(FluentIcons.bank),
                      title: Text(bank.bankName),
                      subtitle: Text("${bank.accountNo} (${bank.ifscCode})"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (bank.isDefault)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Tooltip(
                                message: "Default Bank",
                                child: Icon(
                                  FluentIcons.favorite_star_fill,
                                  color: Colors.warningPrimaryColor,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () =>
                                _showAddEditBankDialog(context, bank: bank),
                          ),
                          IconButton(
                            icon: Icon(FluentIcons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteBank(bank),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (!bank.isDefault) {
                          ref
                              .read(bankListProvider.notifier)
                              .setDefaultBank(bank.id);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: ProgressBar()),
          error: (final err, final stack) => Text("Error: $err"),
        ),
        const Gap(32),
        const Divider(),
        const Gap(20),
        const Text(
          "UPI Details (Shared across all banks)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: InfoLabel(
                label: "UPI ID (VPA)",
                child: TextFormBox(
                  initialValue: ref.watch(businessProfileProvider).upiId,
                  placeholder: "e.g. name@bank",
                  onChanged: (final v) {
                    final profile = ref.read(businessProfileProvider);
                    ref
                        .read(businessProfileListProvider.notifier)
                        .updateProfile(profile.copyWith(upiId: v));
                  },
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: InfoLabel(
                label: "UPI Name",
                child: TextFormBox(
                  initialValue: ref.watch(businessProfileProvider).upiName,
                  placeholder: "e.g. Business Name",
                  onChanged: (final v) {
                    final profile = ref.read(businessProfileProvider);
                    ref
                        .read(businessProfileListProvider.notifier)
                        .updateProfile(profile.copyWith(upiName: v));
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddEditBankDialog(
    final BuildContext context, {
    final bank_model.BankAccount? bank,
  }) async {
    final nameCtrl = TextEditingController(text: bank?.bankName);
    final accCtrl = TextEditingController(text: bank?.accountNo);
    final ifscCtrl = TextEditingController(text: bank?.ifscCode);
    final branchCtrl = TextEditingController(text: bank?.branch);

    await showDialog<bool>(
      context: context,
      builder: (final context) => ContentDialog(
        title: Text(bank == null ? "Add Bank Account" : "Edit Bank Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoLabel(
              label: "Bank Name",
              child: TextBox(controller: nameCtrl),
            ),
            const Gap(10),
            InfoLabel(
              label: "Account Number",
              child: TextBox(controller: accCtrl),
            ),
            const Gap(10),
            InfoLabel(
              label: "IFSC Code",
              child: TextBox(
                controller: ifscCtrl,
                onChanged: (final v) {
                  if (v.length >= 4) {
                    final bName = IndianValidators.getBankFromIFSC(v);
                    if (bName != null && nameCtrl.text.isEmpty) {
                      nameCtrl.text = bName;
                    }
                  }
                },
              ),
            ),
            const Gap(10),
            InfoLabel(
              label: "Branch",
              child: TextBox(controller: branchCtrl),
            ),
          ],
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || accCtrl.text.isEmpty) {
                return;
              }
              final profile = ref.read(businessProfileProvider);
              final newBank = bank_model.BankAccount(
                id: bank?.id ?? const Uuid().v4(),
                profileId: profile.id,
                bankName: nameCtrl.text.trim(),
                accountNo: accCtrl.text.trim(),
                ifscCode: ifscCtrl.text.trim(),
                branch: branchCtrl.text.trim(),
                isDefault: bank?.isDefault ?? false,
              );
              await ref.read(bankListProvider.notifier).saveBank(newBank);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(bank == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteBank(final bank_model.BankAccount bank) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final context) => ContentDialog(
        title: const Text("Delete Bank Account?"),
        content: Text(
          "Are you sure you want to delete '${bank.bankName}' (${bank.accountNo})?",
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bankListProvider.notifier).deleteBank(bank.id);
    }
  }

  Widget _buildDataSection() {
    return Column(
      children: [
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
            const Gap(8),
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
        const Gap(8),
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
            const Gap(8),
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
        const Gap(20),
        const Divider(),
        const Gap(20),

        const Gap(20),
        const Divider(),
        const Gap(20),
        const Text(
          "Auto Backup Schedule",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Gap(10),
        const Text(
          "Schedule automatic backups of your database to ensure your data is always safe.",
          style: TextStyle(color: Colors.grey),
        ),
        const Gap(15),
        ToggleSwitch(
          checked: ref.watch(appConfigProvider).autoBackupEnabled,
          content: const Text("Enable Auto Backup"),
          onChanged: (final v) {
            ref.read(appConfigProvider.notifier).setAutoBackupEnabled(v);
          },
        ),
        if (ref.watch(appConfigProvider).autoBackupEnabled) ...[
          const Gap(15),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: "Backup Frequency",
                  child: ComboBox<BackupFrequency>(
                    value: ref.watch(appConfigProvider).backupFrequency,
                    items: BackupFrequency.values
                        .where((final f) => f != BackupFrequency.none)
                        .map(
                          (final f) => ComboBoxItem(
                            value: f,
                            child: Text(
                              f.name[0].toUpperCase() + f.name.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (final v) {
                      if (v != null) {
                        ref
                            .read(appConfigProvider.notifier)
                            .setBackupFrequency(v);
                      }
                    },
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: InfoLabel(
                  label: "Backup Time",
                  child: TimePicker(
                    selected: DateTime(
                      2024,
                      1,
                      1,
                      int.parse(
                        ref.watch(appConfigProvider).backupTime.split(':')[0],
                      ),
                      int.parse(
                        ref.watch(appConfigProvider).backupTime.split(':')[1],
                      ),
                    ),
                    onChanged: (final time) {
                      final timeStr =
                          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                      ref
                          .read(appConfigProvider.notifier)
                          .setBackupTime(timeStr);
                    },
                  ),
                ),
              ),
            ],
          ),
          const Gap(15),
          if (ref.watch(appConfigProvider).lastAutoBackup != null)
            Text(
              "Last Auto Backup: ${DateFormat('dd MMM yyyy, hh:mm a').format(ref.watch(appConfigProvider).lastAutoBackup!)}",
              style: const TextStyle(color: Colors.grey),
            ),
        ],
        const Gap(20),
        const Divider(),
        const Gap(20),
        InfoLabel(
          label: "Manual Backup & Restore",
          child: const Text(
            "Export your data to a ZIP file or restore from a previous backup. Note: Logos and images are not included in the backup file.",
          ),
        ),
        const Gap(15),
        Row(
          children: [
            Expanded(
              child: Button(
                onPressed: () async {
                  try {
                    final result = await BackupService().exportFullBackup();
                    if (!mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Export Result'),
                          content: Text(result),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.success,
                        );
                      },
                    );
                  } catch (e) {
                    if (!mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Export Failed'),
                          content: Text(e.toString()),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.error,
                        );
                      },
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.encryption),
                    Gap(8),
                    Text("Export Backup (ZIP)"),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Button(
                onPressed: () async {
                  try {
                    final result = await BackupService().restoreFullBackup();
                    if (!mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Restore Result'),
                          content: Text(result),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.success,
                        );
                      },
                    );
                  } catch (e) {
                    if (!mounted) return;
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text('Restore Failed'),
                          content: Text(e.toString()),
                          action: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: close,
                          ),
                          severity: InfoBarSeverity.error,
                        );
                      },
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.upload),
                    Gap(8),
                    Text("Restore Backup (ZIP)"),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        Expander(
          header: Text("Danger Zone", style: TextStyle(color: Colors.red)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Irreversible actions. Proceed with caution."),
              const Gap(10),
              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: const Text("Clear All App Data"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (final dialogContext) {
                      return ContentDialog(
                        title: const Text("Reset Everything?"),
                        content: const Text(
                          "This will delete ALL invoices, clients, estimates, and settings. This cannot be undone.",
                        ),
                        actions: [
                          Button(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.red,
                              ),
                            ),
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
                                displayInfoBar(
                                  context,
                                  builder: (final c, final close) => InfoBar(
                                    severity: InfoBarSeverity.success,
                                    title: const Text("Reset Complete"),
                                    content: const Text(
                                      "All data has been cleared.",
                                    ),
                                    onClose: close,
                                  ),
                                );
                              } catch (e) {
                                final context = this.context;
                                if (!context.mounted) return;
                                displayInfoBar(
                                  context,
                                  builder: (final c, final close) => InfoBar(
                                    severity: InfoBarSeverity.error,
                                    title: const Text("Error"),
                                    content: Text("Failed to clear data: $e"),
                                    onClose: close,
                                  ),
                                );
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
          ),
        ),
      ],
    );
  }

  Widget _buildProfilesSection(
    final BuildContext context,
    final WidgetRef ref,
  ) {
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
                leading: CircleAvatar(
                  backgroundColor: isActive
                      ? FluentTheme.of(context).accentColor
                      : Colors.grey,
                  radius: 16,
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
                            displayInfoBar(
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
                          showDialog(
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

  Widget _buildDataCard<T>(
    final BuildContext context,
    final String title,
    final AsyncValue<List<T>> asyncValue,
    final IconData icon,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
              const Gap(8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Gap(8),
          asyncValue.when(
            data: (final data) => Text(
              "${data.length} Items",
              style: FluentTheme.of(context).typography.bodyLarge,
            ),
            loading: () => const ProgressRing(strokeWidth: 2),
            error: (final e, final s) =>
                Text("Error", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDataCard(
    final BuildContext context,
    final String title,
    final List<dynamic> data,
    final IconData icon,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
              const Gap(8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Gap(8),
          Text(
            "${data.length} Items",
            style: FluentTheme.of(context).typography.bodyLarge,
          ),
        ],
      ),
    );
  }
}
