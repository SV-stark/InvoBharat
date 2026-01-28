import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/business_profile_provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../widgets/profile_switcher_sheet.dart';
import '../widgets/about_tab.dart';
import '../services/email_service.dart'; // NEW
import 'item_templates_screen.dart'; // NEW import

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
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
    _sequenceController =
        TextEditingController(text: profile.invoiceSequence.toString());
    _termsController = TextEditingController(text: profile.termsAndConditions);
    _notesController = TextEditingController(text: profile.defaultNotes);
    _currencyController = TextEditingController(text: profile.currencySymbol);
    _bankNameController = TextEditingController(text: profile.bankName);
    _accountNumberController =
        TextEditingController(text: profile.accountNumber);
    _ifscCodeController = TextEditingController(text: profile.ifscCode);
    _branchNameController = TextEditingController(text: profile.branchName);
    _upiIdController = TextEditingController(text: profile.upiId ?? '');
    _upiNameController = TextEditingController(text: profile.upiName ?? '');
  }

  // Method to reload controllers when profile switches (if we stayed on screen,
  // but usually we might pop? Actually if user switches profile in this screen via tab 2,
  // tab 1 should update).
  // We can listen to changes in build.

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
    super.dispose();
  }

  void _save() {
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
        currencySymbol: _currencyController.text,
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        ifscCode: _ifscCodeController.text,
        branchName: _branchNameController.text,
        upiId: _upiIdController.text,
        upiName: _upiNameController.text,
      );
      ref.read(businessProfileNotifierProvider).updateProfile(newProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings Saved')),
      );
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final currentProfile = ref.read(businessProfileProvider);
      final newProfile = currentProfile.copyWith(logoPath: pickedFile.path);
      ref.read(businessProfileNotifierProvider).updateProfile(newProfile);
    }
  }

  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final currentProfile = ref.read(businessProfileProvider);
      final newProfile =
          currentProfile.copyWith(signaturePath: pickedFile.path);
      ref.read(businessProfileNotifierProvider).updateProfile(newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch profile changes to update controllers if needed?
    // Doing strict sync might be annoying if user is typing.
    // But if profile changes externally (switcher), we should reload.
    // For now, let's assume one active profile edit at a time.

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "General", icon: Icon(Icons.settings)),
              Tab(text: "Profiles", icon: Icon(Icons.business)),
              Tab(text: "Backup", icon: Icon(Icons.backup)),
              Tab(text: "Email", icon: Icon(Icons.email)), // NEW
              Tab(text: "About", icon: Icon(Icons.info_outline)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeneralSettings(),
            _buildProfileSettings(),
            _buildBackupSettings(),
            const _EmailSettingsTab(), // NEW
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
              subtitle:
                  Text(themeMode.toString().split('.').last.toUpperCase()),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                      value: ThemeMode.system, child: Text("System")),
                  DropdownMenuItem(
                      value: ThemeMode.light, child: Text("Light")),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(themeProvider.notifier).setTheme(val);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text("Primary Color"),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),
            _buildSectionHeader("Invoice Configuration"),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        "Series (e.g. INV-)", _seriesController)),
                const SizedBox(width: 16),
                Expanded(
                    child:
                        _buildTextField("Next Sequence", _sequenceController)),
              ],
            ),
            _buildTextField("Currency Symbol", _currencyController),
            _buildTextField("Default Terms", _termsController, maxLines: 4),
            _buildTextField("Default Notes", _notesController, maxLines: 2),
            const SizedBox(height: 24),
            _buildSectionHeader("Payment Details"),
            _buildTextField("Bank Name", _bankNameController),
            _buildTextField("Account Number", _accountNumberController),
            _buildTextField("IFSC Code", _ifscCodeController),
            _buildTextField("Branch Name", _branchNameController),
            const SizedBox(height: 24),
            _buildSectionHeader("UPI Details"),
            _buildTextField("UPI ID (VPA)", _upiIdController),
            _buildTextField("UPI Name", _upiNameController),
            const SizedBox(height: 24),
            _buildSectionHeader("Branding"), // KEEP
            ListTile(
              leading: const Icon(Icons.copy_all),
              title: const Text("Item Templates"),
              subtitle: const Text("Manage frequently used items"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ItemTemplatesScreen())),
            ),
            const Divider(), // Added Divider
            // ... existing ...
            Row(
              children: [
                Expanded(
                  child: Column(children: [
                    const Text("Logo",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                        onTap: _pickLogo,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: profile.logoPath != null
                              ? FileImage(File(profile.logoPath!))
                              : null,
                          child: profile.logoPath == null
                              ? const Icon(Icons.add_a_photo, size: 30)
                              : null,
                        )),
                  ]),
                ),
                Expanded(
                  child: Column(children: [
                    const Text("Signature",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                        onTap: _pickSignature,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profile.signaturePath != null
                              ? FileImage(File(profile.signaturePath!))
                              : null,
                          child: profile.signaturePath == null
                              ? const Icon(Icons.edit, size: 30)
                              : null,
                        )),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Business Profile"),
            _buildTextField("Company Name", _nameController),
            _buildTextField("Address", _addressController, maxLines: 3),
            _buildTextField("GSTIN", _gstinController),
            _buildTextField("Email", _emailController),
            _buildTextField("Phone", _phoneController),
            _buildTextField("State", _stateController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Save Settings"),
              ),
            ),
            const SizedBox(height: 20),
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
        ...profiles.map((p) {
          final isActive = p.id == activeId;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(p.colorValue),
                child: Text(p.companyName.isNotEmpty
                    ? p.companyName[0].toUpperCase()
                    : "?"),
              ),
              title: Text(p.companyName),
              subtitle: Text(isActive ? "Active Profile" : "Tap to Switch"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive)
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteProfile(p)),
                  if (!isActive)
                    TextButton(
                      child: const Text("Switch"),
                      onPressed: () {
                        ref
                            .read(activeProfileIdProvider.notifier)
                            .selectProfile(p.id);
                        // Reload controllers for the newly active profile
                        // But we are in a tab view, wait for rebuild?
                        // setState to trigger rebuild of other tab?
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
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => showProfileSwitcherSheet(context, ref),
          icon: const Icon(Icons.add),
          label: const Text("Add New Profile"),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteProfile(dynamic profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Profile?"),
        content: Text(
            "Are you sure you want to delete '${profile.companyName}'? This will delete all associated invoices and cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
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
    // We can use a simpler UI here
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Backup & Restore",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            width: 250,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Export logic
                try {
                  final msg = await BackupService().exportFullBackup(ref);
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Export Failed: $e")));
                  }
                }
              },
              icon: const Icon(Icons.download),
              label: const Text("Export Full Backup (ZIP)"),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 250,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Restore logic
                try {
                  final result = await BackupService().restoreFullBackup(ref);
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                  _loadProfileData();
                  setState(() {});
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Restore Failed: $e")),
                  );
                }
              },
              icon: const Icon(Icons.upload),
              label: const Text("Restore Data (ZIP)"),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Supports backing up all profiles and invoices.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              )),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            // Only validate required fields if necessary.
            // For now, let's keep it loose or validate specific ones like Company Name.
            label == "Company Name" && (value == null || value.isEmpty)
                ? 'Required'
                : null,
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final selectedColor = ref.watch(businessProfileProvider).colorValue;
    final isSelected = selectedColor == color.toARGB32();

    return GestureDetector(
      onTap: () {
        ref.read(businessProfileNotifierProvider).updateColor(color.toARGB32());
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

// NEW EMAIL TAB
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
    final settings = await EmailService.getSettings();
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
        smtpPort: int.parse(_portController.text.trim()),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        isSecure: _isSecure,
      );

      await EmailService.saveSettings(settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email Settings Saved")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SMTP Configuration",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
                "Configure your email provider to send invoices directly from the app."),
            const SizedBox(height: 24),
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                  labelText: "SMTP Host", hintText: "e.g. smtp.gmail.com"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Host is required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                  labelText: "SMTP Port", hintText: "e.g. 587 or 465"),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? "Port is required" : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Use SSL/TLS (Secure)"),
              value: _isSecure,
              onChanged: (v) => setState(() => _isSecure = v!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: "Sender Email", hintText: "you@example.com"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Email is required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                  labelText: "Username", hintText: "Often same as email"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Username is required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              // Password optional (though usually required)
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text("Save Configuration"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await EmailService.clearSettings();
                  _loadSettings();
                },
                child: const Text("Clear Settings"),
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
