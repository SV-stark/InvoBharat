import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/utils/validators.dart';

/// Mixin to handle form logic for creating/editing Clients.
///
/// Usage:
/// ```dart
/// class _MyFormState extends ConsumerState<MyForm> with ClientFormMixin {
///   @override
///   void initState() {
///     super.initState();
///     initClientControllers(widget.client);
///   }
///
///   @override
///   void dispose() {
///     disposeClientControllers();
///     super.dispose();
///   }
/// }
/// ```
mixin ClientFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController gstinController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController contactController;
  late TextEditingController notesController;
  late TextEditingController stateController;

  void initClientControllers(final Client? client) {
    nameController = TextEditingController(text: client?.name ?? '');
    gstinController = TextEditingController(text: client?.gstin ?? '');
    addressController = TextEditingController(text: client?.address ?? '');
    emailController = TextEditingController(text: client?.email ?? '');
    phoneController = TextEditingController(text: client?.phone ?? '');
    contactController =
        TextEditingController(text: client?.primaryContact ?? '');
    notesController = TextEditingController(text: client?.notes ?? '');
    stateController = TextEditingController(text: client?.state ?? '');
  }

  void disposeClientControllers() {
    nameController.dispose();
    gstinController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    contactController.dispose();
    notesController.dispose();
    stateController.dispose();
  }

  /// Validates the form and saves the client.
  /// Returns [true] if successful, [false] if validation failed.
  Future<bool> saveClient({
    required final Client? originalClient,
    required final WidgetRef ref, // Passed explicitly or use `ref` from ConsumerState
  }) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    final client = Client(
      id: originalClient?.id ?? '',
      name: nameController.text,
      gstin: gstinController.text,
      address: addressController.text,
      email: emailController.text,
      phone: phoneController.text,
      primaryContact: contactController.text,
      notes: notesController.text,
      state: stateController.text,
    );

    if (originalClient == null) {
      await ref.read(clientListProvider.notifier).addClient(client);
    } else {
      await ref.read(clientListProvider.notifier).updateClient(client);
    }

    return true;
  }

  String? validateName(final String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateEmail(final String? value) => Validators.email(value);
  String? validatePhone(final String? value) => Validators.phone(value);
}
