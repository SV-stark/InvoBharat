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
    StateNotifierProvider.autoDispose<ClientListNotifier, List<Client>>((ref) {
  return ClientListNotifier(ref);
});

class ClientListNotifier extends StateNotifier<List<Client>> {
  final Ref ref;

  ClientListNotifier(this.ref) : super([]) {
    // Watch the repository provider to trigger rebuilds on profile change
    ref.watch(clientRepositoryProvider);
    _loadClients();
  }

  Future<void> _loadClients() async {
    final repository = ref.read(clientRepositoryProvider);
    state = await repository.getAllClients();
  }

  Future<void> addClient(Client client) async {
    final repository = ref.read(clientRepositoryProvider);

    Client newClient = client;
    if (newClient.id.isEmpty) {
      newClient = newClient.copyWith(id: const Uuid().v4());
    }

    await repository.saveClient(newClient);
    await _loadClients();
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
}
