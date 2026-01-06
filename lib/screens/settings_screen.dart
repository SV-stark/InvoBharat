import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/business_profile_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _gstinController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _seriesController;
  late TextEditingController _sequenceController;
  late TextEditingController _termsController;
  late TextEditingController _notesController;
  late TextEditingController _currencyController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(businessProfileProvider);
    _nameController = TextEditingController(text: profile.companyName);
    _addressController = TextEditingController(text: profile.address);
    _gstinController = TextEditingController(text: profile.gstin);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _seriesController = TextEditingController(text: profile.invoiceSeries);
    _sequenceController =
        TextEditingController(text: profile.invoiceSequence.toString());
    _termsController = TextEditingController(text: profile.termsAndConditions);
    _notesController = TextEditingController(text: profile.defaultNotes);
    _currencyController = TextEditingController(text: profile.currencySymbol);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _seriesController.dispose();
    _sequenceController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    _currencyController.dispose();
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
        invoiceSeries: _seriesController.text,
        invoiceSequence: int.tryParse(_sequenceController.text) ?? 1,
        termsAndConditions: _termsController.text,
        defaultNotes: _notesController.text,
        currencySymbol: _currencyController.text,
      );
      ref.read(businessProfileProvider.notifier).updateProfile(newProfile);
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
      ref.read(businessProfileProvider.notifier).updateProfile(newProfile);
    }
  }

  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final currentProfile = ref.read(businessProfileProvider);
      final newProfile =
          currentProfile.copyWith(signaturePath: pickedFile.path);
      ref.read(businessProfileProvider.notifier).updateProfile(newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
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
                    DropdownMenuItem(
                        value: ThemeMode.dark, child: Text("Dark")),
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
                      child: _buildTextField(
                          "Next Sequence", _sequenceController)),
                ],
              ),
              _buildTextField("Currency Symbol", _currencyController),
              _buildTextField("Default Terms", _termsController, maxLines: 4),
              _buildTextField("Default Notes", _notesController, maxLines: 2),
              const SizedBox(height: 24),
              _buildSectionHeader("Branding"),
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
        ref
            .read(businessProfileProvider.notifier)
            .updateColor(color.toARGB32());
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
