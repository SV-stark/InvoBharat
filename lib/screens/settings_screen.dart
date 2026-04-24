import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:gap/gap.dart';

import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/theme_provider.dart';
import 'package:invobharat/services/backup_service.dart';
import 'package:invobharat/widgets/profile_switcher_sheet.dart';
import 'package:invobharat/widgets/about_tab.dart';
import 'package:invobharat/services/email_service.dart';
import 'package:go_router/go_router.dart';
import 'package:indian_formatters/indian_formatters.dart';
import 'package:invobharat/utils/formatters.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isBackupLoading = false;
  bool _isRestoreLoading = false;
  // General & Invoice Config Controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _gstinController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _stateController;
  late TextEditingController _seriesController;
  late TextEditingController _sequenceController;
  late TextEditingController _termsController;
  late TextEditingController _notesController;
  late TextEditingController _currencyController;
  // Bank Details
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _branchNameController;
  // UPI
  late TextEditingController _upiIdController;
  late TextEditingController _upiNameController;
  late TextEditingController _panController;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = ref.read(businessProfileProvider);
    _nameController = TextEditingController(text: profile.companyName);
    _addressController = TextEditingController(text: profile.address);
    _gstinController = TextEditingController(text: profile.gstin);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _stateController = TextEditingController(text: profile.state);
    _seriesController = TextEditingController(text: profile.invoiceSeries);
    _sequenceController = TextEditingController(
      text: profile.invoiceSequence.toString(),
    );
    _termsController = TextEditingController(text: profile.termsAndConditions);
    _notesController = TextEditingController(text: profile.defaultNotes);
    _currencyController = TextEditingController(text: profile.currency);
    _bankNameController = TextEditingController(text: profile.bankName);
    _accountNumberController = TextEditingController(
      text: profile.accountNo,
    );
    _ifscCodeController = TextEditingController(text: profile.ifscCode);
    _branchNameController = TextEditingController(text: profile.branch);
    _upiIdController = TextEditingController(text: profile.upiId);
    _upiNameController = TextEditingController(text: profile.upiName);
    _panController = TextEditingController(text: profile.pan);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _seriesController.dispose();
    _sequenceController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    _currencyController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _branchNameController.dispose();
    _upiIdController.dispose();
    _upiNameController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final currentProfile = ref.read(businessProfileProvider);
      final newProfile = currentProfile.copyWith(
        companyName: _nameController.text,
        address: _addressController.text,
        gstin: _gstinController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        state: _stateController.text,
        invoiceSeries: _seriesController.text,
        invoiceSequence: int.tryParse(_sequenceController.text) ?? 1,
        termsAndConditions: _termsController.text,
        defaultNotes: _notesController.text,
        currency: _currencyController.text,
        bankName: _bankNameController.text,
        accountNo: _accountNumberController.text,
        ifscCode: _ifscCodeController.text,
        branch: _branchNameController.text,
        upiId: _upiIdController.text,
        upiName: _upiNameController.text,
        pan: _panController.text,
      );
      await ref.read(businessProfileListProvider.notifier).updateProfile(newProfile);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings Saved')));
      }
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final currentProfile = ref.read(businessProfileProvider);
      final newProfile = currentProfile.copyWith(logoPath: pickedFile.path);
      await ref.read(businessProfileListProvider.notifier).updateProfile(newProfile);
      setState(() {});
    }
  }

  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final currentProfile = ref.read(businessProfileProvider);
      final newProfile = currentProfile.copyWith(
        signaturePath: pickedFile.path,
      );
      await ref.read(businessProfileListProvider.notifier).updateProfile(newProfile);
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "General", icon: Icon(Icons.settings)),
              Tab(text: "Profiles", icon: Icon(Icons.business)),
              Tab(text: "Backup", icon: Icon(Icons.backup)),
              Tab(text: "Email", icon: Icon(Icons.email)),
              Tab(text: "About", icon: Icon(Icons.info_outline)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeneralSettings(),
            _buildProfileSettings(),
            _buildBackupSettings(),
            const _EmailSettingsTab(),
            const AboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    final profile = ref.watch(businessProfileProvider);
    final themeMode = ref.watch(themeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Appearance"),
            ListTile(
              title: const Text("App Theme"),
              subtitle: Text(
                themeMode.toString().split('.').last.toUpperCase(),
              ),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text("System"),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text("Light"),
                  ),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                ],
                onChanged: (final val) {
                  if (val != null) {
                    ref.read(themeProvider.notifier).setTheme(val);
                  }
                },
              ),
            ),
            const Gap(8),
            const Text("Primary Color"),
            const Gap(8),
            Wrap(
              spacing: 12,
              children: [
                _buildColorOption(Colors.teal),
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.purple),
                _buildColorOption(Colors.indigo),
                _buildColorOption(Colors.deepOrange),
                _buildColorOption(Colors.black),
              ],
            ),
            const Gap(24),
            _buildSectionHeader("Invoice Configuration"),
            _buildTextField("Prefix (e.g. INV-)", _seriesController),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Next Number", _sequenceController),
                ),
                const Gap(16),
                Expanded(
                  child: _buildTextField(
                    "Suffix (e.g. -FY25)",
                    _currencyController,
                  ),
                ),
              ],
            ),
            const Gap(8),
            const Text(
              "Invoice number format: Prefix + Number + Suffix (e.g. INV-001-FY25)",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Gap(16),
            _buildTextField("Default Terms", _termsController, maxLines: 4),
            _buildTextField("Default Notes", _notesController, maxLines: 2),
            const Gap(24),
            _buildSectionHeader("Payment Details"),
            _buildTextField("Bank Name", _bankNameController),
            _buildTextField("Account Number", _accountNumberController),
            _buildTextField("IFSC Code", _ifscCodeController),
            _buildTextField("Branch Name", _branchNameController),
            const Gap(24),
            _buildSectionHeader("UPI Details"),
            _buildTextField("UPI ID (VPA)", _upiIdController),
            _buildTextField("UPI Name", _upiNameController),
            _buildTextField(
              "Business PAN",
              _panController,
              formatters: [PANNumberFormatter()],
            ),
            const Gap(24),
            _buildSectionHeader("Branding"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Tip: Use PNG images with transparent backgrounds for your Logo and Signature for best results on invoices.",
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy_all),
              title: const Text("Item Templates"),
              subtitle: const Text("Manage frequently used items"),
              onTap: () => context.push('/item-templates'),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Logo",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: _pickLogo,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: profile.logoPath != null && profile.logoPath!.isNotEmpty
                              ? FileImage(File(profile.logoPath!))
                              : null,
                          child: profile.logoPath == null || profile.logoPath!.isEmpty
                              ? const Icon(Icons.add_a_photo, size: 30)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Signature",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: _pickSignature,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profile.signaturePath != null && profile.signaturePath!.isNotEmpty
                              ? FileImage(File(profile.signaturePath!))
                              : null,
                          child: profile.signaturePath == null || profile.signaturePath!.isEmpty
                              ? const Icon(Icons.edit, size: 30)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),
            _buildSectionHeader("Business Profile"),
            _buildTextField("Company Name", _nameController),
            _buildTextField("Address", _addressController, maxLines: 3),
            _buildTextField(
              "GSTIN",
              _gstinController,
              formatters: [GSTNumberFormatter()],
              onChanged: (final val) {
                final state = IndianValidators.getGSTState(val);
                if (state != null) {
                  _stateController.text = state;
                }
              },
            ),
            _buildTextField("Email", _emailController),
            _buildTextField(
              "Phone",
              _phoneController,
              formatters: [MobileNumberFormatter()],
            ),
            _buildTextField("State", _stateController),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Save Settings"),
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSettings() {
    final profiles = ref.watch(businessProfileListProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("Manage Profiles"),
        ...profiles.map((final p) {
          final isActive = p.id == activeId;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(p.colorValue),
                child: Text(
                  p.companyName.isNotEmpty
                      ? p.companyName[0].toUpperCase()
                      : "?",
                ),
              ),
              title: Text(p.companyName),
              subtitle: Text(isActive ? "Active Profile" : "Tap to Switch"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteProfile(p),
                    ),
                  if (!isActive)
                    TextButton(
                      child: const Text("Switch"),
                      onPressed: () {
                        ref
                            .read(activeProfileIdProvider.notifier)
                            .selectProfile(p.id);
                        Future.delayed(Duration.zero, () {
                          if (mounted) {
                            _loadProfileData();
                            setState(() {});
                          }
                        });
                      },
                    ),
                ],
              ),
              onTap: () {
                if (!isActive) {
                  ref
                      .read(activeProfileIdProvider.notifier)
                      .selectProfile(p.id);
                  Future.delayed(Duration.zero, () {
                    if (mounted) {
                      _loadProfileData();
                      setState(() {});
                    }
                  });
                }
              },
            ),
          );
        }),
        const Gap(16),
        FilledButton.icon(
          onPressed: () => showProfileSwitcherSheet(context, ref),
          icon: const Icon(Icons.add),
          label: const Text("Add New Profile"),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteProfile(final dynamic profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text("Delete Profile?"),
        content: Text(
          "Are you sure you want to delete '${profile.companyName}'? This will delete all associated invoices and cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(businessProfileListProvider.notifier)
          .deleteProfile(profile.id);
    }
  }

  Widget _buildBackupSettings() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload, size: 64, color: Colors.grey),
          const Gap(16),
          const Text(
            "Backup & Restore",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Gap(32),
          SizedBox(
            width: 250,
            child: ElevatedButton.icon(
              onPressed: _isBackupLoading
                  ? null
                  : () async {
                      setState(() => _isBackupLoading = true);
                      try {
                        final msg = await BackupService().exportFullBackup();
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Export Failed: $e")),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isBackupLoading = false);
                        }
                      }
                    },
              icon: _isBackupLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: const Text("Export Full Backup (ZIP)"),
            ),
          ),
          const Gap(16),
          SizedBox(
            width: 250,
            child: OutlinedButton.icon(
              onPressed: _isRestoreLoading
                  ? null
                  : () async {
                      setState(() => _isRestoreLoading = true);
                      try {
                        final result = await BackupService()
                            .restoreFullBackup();
                        if (!mounted) return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(result)));
                        _loadProfileData();
                        setState(() {});
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Restore Failed: $e")),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isRestoreLoading = false);
                        }
                      }
                    },
              icon: _isRestoreLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: const Text("Restore Data (ZIP)"),
            ),
          ),
          const Gap(32),
          const Text(
            "Supports backing up all profiles and invoices.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(final String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    final String label,
    final TextEditingController controller, {
    final int maxLines = 1,
    final List<TextInputFormatter>? formatters,
    final Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        inputFormatters: formatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (final value) =>
            label == "Company Name" && (value == null || value.isEmpty)
            ? 'Required'
            : null,
      ),
    );
  }

  Widget _buildColorOption(final Color color) {
    final selectedColor = ref.watch(businessProfileProvider).colorValue;
    final isSelected = selectedColor == color.toARGB32();

    return GestureDetector(
      onTap: () {
        ref.read(businessProfileListProvider.notifier).updateColor(color.toARGB32());
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(width: 3, color: Colors.grey) : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}

class _EmailSettingsTab extends StatefulWidget {
  const _EmailSettingsTab();

  @override
  State<_EmailSettingsTab> createState() => _EmailSettingsTabState();
}

class _EmailSettingsTabState extends State<_EmailSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSecure = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await EmailService.getSettingsStatic();
    if (settings != null) {
      if (mounted) {
        setState(() {
          _hostController.text = settings.smtpHost;
          _portController.text = settings.smtpPort.toString();
          _emailController.text = settings.email;
          _usernameController.text = settings.username;
          _passwordController.text = settings.password ?? '';
          _isSecure = settings.isSecure;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = EmailSettings(
        smtpHost: _hostController.text.trim(),
        smtpPort: int.tryParse(_portController.text.trim()) ?? 587,
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        isSecure: _isSecure,
      );

      await EmailService.saveSettingsStatic(settings);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Email Settings Saved")));
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SMTP Configuration",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            const Text(
              "Configure your email provider to send invoices directly from the app.",
            ),
            const Gap(24),
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: "SMTP Host",
                hintText: "e.g. smtp.gmail.com",
              ),
              validator: (final v) =>
                  v == null || v.isEmpty ? "Host is required" : null,
            ),
            const Gap(16),
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: "SMTP Port",
                hintText: "e.g. 587 or 465",
              ),
              keyboardType: TextInputType.number,
              validator: (final v) =>
                  v == null || v.isEmpty ? "Port is required" : null,
            ),
            const Gap(16),
            CheckboxListTile(
              title: const Text("Use SSL/TLS (Secure)"),
              value: _isSecure,
              onChanged: (final v) => setState(() => _isSecure = v!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Gap(16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Sender Email",
                hintText: "you@example.com",
              ),
              validator: (final v) =>
                  v == null || v.isEmpty ? "Email is required" : null,
            ),
            const Gap(16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                hintText: "Often same as email",
              ),
              validator: (final v) =>
                  v == null || v.isEmpty ? "Username is required" : null,
            ),
            const Gap(16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text("Save Configuration"),
              ),
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await EmailService.clearSettingsStatic();
                  await _loadSettings();
                },
                child: const Text("Clear Settings"),
              ),
            ),
            const Gap(64),
          ],
        ),
      ),
    );
  }
}
