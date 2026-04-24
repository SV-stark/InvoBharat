import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:uuid/uuid.dart';

/// State for the Client Form
class ClientFormState {
  final String? id;
  final String name;
  final String gstin;
  final String address;
  final String email;
  final String phone;
  final String state;
  final String primaryContact;
  final String notes;
  final String pan;
  final String stateCode;

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ClientFormState({
    this.id,
    this.name = '',
    this.gstin = '',
    this.address = '',
    this.email = '',
    this.phone = '',
    this.state = '',
    this.primaryContact = '',
    this.notes = '',
    this.pan = '',
    this.stateCode = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ClientFormState copyWith({
    final String? id,
    final String? name,
    final String? gstin,
    final String? address,
    final String? email,
    final String? phone,
    final String? state,
    final String? primaryContact,
    final String? notes,
    final String? pan,
    final String? stateCode,
    final bool? isLoading,
    final String? errorMessage,
    final bool? isSuccess,
    final bool clearError = false,
  }) {
    return ClientFormState(
      id: id ?? this.id,
      name: name ?? this.name,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      primaryContact: primaryContact ?? this.primaryContact,
      notes: notes ?? this.notes,
      pan: pan ?? this.pan,
      stateCode: stateCode ?? this.stateCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  Client toClient() {
    return Client(
      id: id ?? const Uuid().v4(),
      name: name,
      gstin: gstin,
      address: address,
      email: email,
      phone: phone,
      state: state,
      primaryContact: primaryContact,
      notes: notes,
      pan: pan,
      stateCode: stateCode,
    );
  }
}

/// Notifier for managing Client Form state and logic
class ClientFormNotifier extends Notifier<ClientFormState> {
  @override
  ClientFormState build() => const ClientFormState();

  /// Load an existing client for editing, or reset for new client
  void loadClient(final Client? client) {
    if (client == null) {
      state = const ClientFormState();
    } else {
      state = ClientFormState(
        id: client.id,
        name: client.name,
        gstin: client.gstin,
        address: client.address,
        email: client.email,
        phone: client.phone,
        state: client.state,
        primaryContact: client.primaryContact,
        notes: client.notes,
        pan: client.pan,
        stateCode: client.stateCode,
      );
    }
  }

  void updateName(final String value) => state = state.copyWith(name: value);
  void updateGstin(final String value) => state = state.copyWith(gstin: value);
  void updateAddress(final String value) => state = state.copyWith(address: value);
  void updateEmail(final String value) => state = state.copyWith(email: value);
  void updatePhone(final String value) => state = state.copyWith(phone: value);
  void updateState(final String value) => state = state.copyWith(state: value);
  void updatePrimaryContact(final String value) =>
      state = state.copyWith(primaryContact: value);
  void updateNotes(final String value) => state = state.copyWith(notes: value);
  void updatePan(final String value) => state = state.copyWith(pan: value);
  void updateStateCode(final String value) =>
      state = state.copyWith(stateCode: value);

  /// Validate and save the client
  Future<bool> save() async {
    // Validation
    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Client name is required');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final client = state.toClient();

      // Use the existing client provider to save
      if (state.id == null) {
        await ref.read(clientListProvider.notifier).addClient(client);
      } else {
        await ref.read(clientListProvider.notifier).updateClient(client);
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save client: $e',
      );
      return false;
    }
  }

  /// Reset the form
  void reset() {
    state = const ClientFormState();
  }
}

/// Provider for Client Form
final clientFormProvider =
    NotifierProvider<ClientFormNotifier, ClientFormState>(
  ClientFormNotifier.new,
);
