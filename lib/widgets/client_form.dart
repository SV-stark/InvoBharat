import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../providers/client_provider.dart';

class ClientFormDialog extends ConsumerStatefulWidget {
  final Client? client;

  const ClientFormDialog({super.key, this.client});

  @override
  ConsumerState<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends ConsumerState<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _gstinController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _contactController;
  late TextEditingController _notesController;
  late TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _gstinController = TextEditingController(text: widget.client?.gstin ?? '');
    _addressController =
        TextEditingController(text: widget.client?.address ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _contactController =
        TextEditingController(text: widget.client?.primaryContact ?? '');
    _notesController = TextEditingController(text: widget.client?.notes ?? '');
    _stateController = TextEditingController(text: widget.client?.state ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: widget.client?.id ?? '',
        name: _nameController.text,
        gstin: _gstinController.text,
        address: _addressController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        primaryContact: _contactController.text,
        notes: _notesController.text,
        state: _stateController.text,
      );

      if (widget.client == null) {
        await ref.read(clientListProvider.notifier).addClient(client);
      } else {
        await ref.read(clientListProvider.notifier).updateClient(client);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.client == null ? 'Add Client' : 'Edit Client'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: 'Client / Business Name',
                child: TextFormBox(
                  controller: _nameController,
                  placeholder: 'Enter client name',
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'GSTIN',
                child: TextFormBox(
                  controller: _gstinController,
                  placeholder: 'e.g. 29ABCDE1234F1Z5',
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Billing Address',
                child: TextFormBox(
                  controller: _addressController,
                  placeholder: 'Enter full address',
                  minLines: 3,
                  maxLines: 5,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'State',
                child: TextFormBox(
                  controller: _stateController,
                  placeholder: 'e.g. Maharashtra',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: 'Email',
                      child: TextFormBox(
                        controller: _emailController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoLabel(
                      label: 'Phone',
                      child: TextFormBox(
                        controller: _phoneController,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Primary Contact Person',
                child: TextFormBox(
                  controller: _contactController,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Notes (Internal)',
                child: TextFormBox(
                  controller: _notesController,
                  placeholder: 'Private notes about this client',
                ),
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
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
