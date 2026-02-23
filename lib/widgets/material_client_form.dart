import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_form_provider.dart';
import 'package:invobharat/widgets/adaptive_widgets.dart';

class MaterialClientFormDialog extends ConsumerStatefulWidget {
  final Client? client;

  const MaterialClientFormDialog({super.key, this.client});

  @override
  ConsumerState<MaterialClientFormDialog> createState() =>
      _MaterialClientFormDialogState();
}

class _MaterialClientFormDialogState
    extends ConsumerState<MaterialClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _gstinController;
  late final TextEditingController _addressController;
  late final TextEditingController _stateController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _contactController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    // Initialize provider with existing client data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientFormProvider.notifier).loadClient(widget.client);
    });

    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _gstinController = TextEditingController(text: widget.client?.gstin ?? '');
    _addressController =
        TextEditingController(text: widget.client?.address ?? '');
    _stateController = TextEditingController(text: widget.client?.state ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _contactController =
        TextEditingController(text: widget.client?.primaryContact ?? '');
    _notesController = TextEditingController(text: widget.client?.notes ?? '');

    // Sync controllers to provider
    _nameController.addListener(() {
      ref.read(clientFormProvider.notifier).updateName(_nameController.text);
    });
    _gstinController.addListener(() {
      ref.read(clientFormProvider.notifier).updateGstin(_gstinController.text);
    });
    _addressController.addListener(() {
      ref
          .read(clientFormProvider.notifier)
          .updateAddress(_addressController.text);
    });
    _stateController.addListener(() {
      ref.read(clientFormProvider.notifier).updateState(_stateController.text);
    });
    _emailController.addListener(() {
      ref.read(clientFormProvider.notifier).updateEmail(_emailController.text);
    });
    _phoneController.addListener(() {
      ref.read(clientFormProvider.notifier).updatePhone(_phoneController.text);
    });
    _contactController.addListener(() {
      ref
          .read(clientFormProvider.notifier)
          .updatePrimaryContact(_contactController.text);
    });
    _notesController.addListener(() {
      ref.read(clientFormProvider.notifier).updateNotes(_notesController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(clientFormProvider.notifier).save();

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(clientFormProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  String? _validateName(final String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Client name is required';
    }
    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final formState = ref.watch(clientFormProvider);

    return AlertDialog(
      title: Text(widget.client == null ? 'Add Client' : 'Edit Client'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextInput(
                controller: _nameController,
                label: 'Client / Business Name',
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              AppTextInput(
                controller: _gstinController,
                label: 'GSTIN',
                placeholder: 'e.g. 29ABCDE1234F1Z5',
              ),
              const SizedBox(height: 16),
              AppTextInput(
                controller: _addressController,
                label: 'Billing Address',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextInput(
                controller: _stateController,
                label: 'State',
                placeholder: 'e.g. Maharashtra',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextInput(
                      controller: _emailController,
                      label: 'Email',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextInput(
                      controller: _phoneController,
                      label: 'Phone',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextInput(
                controller: _contactController,
                label: 'Primary Contact Person',
              ),
              const SizedBox(height: 16),
              AppTextInput(
                controller: _notesController,
                label: 'Notes (Internal)',
                placeholder: 'Private notes about this client',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: formState.isLoading ? null : _save,
          child: formState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
