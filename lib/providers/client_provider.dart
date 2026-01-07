import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/client_repository.dart';
import '../models/client.dart';
import 'business_profile_provider.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final profile = ref.watch(businessProfileProvider);
  return ClientRepository(profileId: profile.id);
});

final clientListProvider =
    NotifierProvider<ClientListNotifier, List<Client>>(ClientListNotifier.new);

class ClientListNotifier extends Notifier<List<Client>> {
  @override
  List<Client> build() {
    _loadClients();
    return [];
  }

  Future<void> _loadClients() async {
    final repository = ref.read(clientRepositoryProvider);
    state = await repository.getAllClients();
  }

  Future<void> addClient(Client client) async {
    final repository = ref.read(clientRepositoryProvider);

    // Assign ID if missing (though UI should ideally handle this, or we do it here)
    Client newClient = client;
    if (newClient.id.isEmpty) {
      newClient = newClient.copyWith(id: const Uuid().v4());
    }

    await repository.saveClient(newClient);
    await _loadClients(); // Reload to sort and update
  }

  Future<void> updateClient(Client client) async {
    final repository = ref.read(clientRepositoryProvider);
    await repository.saveClient(client);
    await _loadClients();
  }

  Future<void> deleteClient(String clientId) async {
    final repository = ref.read(clientRepositoryProvider);
    await repository.deleteClient(clientId);
    await _loadClients();
  }

  // Method to refresh manually if needed (e.g. after profile switch)
  Future<void> refresh() async {
    await _loadClients();
  }
}
