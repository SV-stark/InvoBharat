import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/business_profile.dart'; 
import '../providers/business_profile_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final profile = ref.read(businessProfileProvider);
    _nameController = TextEditingController(text: profile.companyName);
    _addressController = TextEditingController(text: profile.address);
    _gstinController = TextEditingController(text: profile.gstin);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
      );
      ref.read(businessProfileProvider.notifier).updateProfile(newProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings Saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Branding"), // Moved Branding up
              Center(
                  child: Column(children: [
                      GestureDetector(
                          onTap: _pickLogo,
                          child: CircleAvatar(
                              radius: 40,
                              backgroundImage: profile.logoPath != null ? FileImage(File(profile.logoPath!)) : null,
                              child: profile.logoPath == null ? const Icon(Icons.add_a_photo, size: 30) : null,
                          )
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _pickLogo, child: const Text("Upload Company Logo"))
                  ])
              ),
              const SizedBox(height: 16),
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildColorOption(MaterialColor color) {
    final selectedColor = ref.watch(businessProfileProvider).colorValue;
    final isSelected = selectedColor == color.value;

    return GestureDetector(
      onTap: () {
        ref.read(businessProfileProvider.notifier).updateColor(color.value);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
             if (isSelected) BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)
          ]
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
