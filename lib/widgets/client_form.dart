import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../providers/client_form_provider.dart';
import '../widgets/adaptive_widgets.dart';
import '../utils/validators.dart';

class ClientFormDialog extends ConsumerStatefulWidget {
  final Client? client;

  const ClientFormDialog({super.key, this.client});

  @override
  ConsumerState<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends ConsumerState<ClientFormDialog> {
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
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('Error'),
            content: Text(error),
            severity: InfoBarSeverity.error,
          ),
        );
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Client name is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(clientFormProvider);

    return ContentDialog(
      title: Text(widget.client == null ? 'Add Client' : 'Edit Client'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextInput(
                label: 'Client / Business Name',
                controller: _nameController,
                placeholder: 'Enter client name',
                validator: _validateName,
              ),
              const SizedBox(height: 8),
              AppTextInput(
                label: 'GSTIN',
                controller: _gstinController,
                placeholder: 'e.g. 29ABCDE1234F1Z5',
              ),
              const SizedBox(height: 8),
              AppTextInput(
                label: 'Billing Address',
                controller: _addressController,
                placeholder: 'Enter full address',
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              AppTextInput(
                label: 'State',
                controller: _stateController,
                placeholder: 'e.g. Maharashtra',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextInput(
                      label: 'Email',
                      controller: _emailController,
                      validator: Validators.email,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextInput(
                      label: 'Phone',
                      controller: _phoneController,
                      validator: Validators.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppTextInput(
                label: 'Primary Contact Person',
                controller: _contactController,
              ),
              const SizedBox(height: 8),
              AppTextInput(
                label: 'Notes (Internal)',
                controller: _notesController,
                placeholder: 'Private notes about this client',
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: formState.isLoading ? null : _save,
          child: formState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: ProgressRing(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
