import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/sql_client_repository.dart';
import '../data/client_repository.dart';
import '../models/client.dart';
import 'database_provider.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SqlClientRepository(db);
});

final clientListProvider =
    NotifierProvider<ClientListNotifier, List<Client>>(ClientListNotifier.new);

class ClientListNotifier extends Notifier<List<Client>> {
  @override
  List<Client> build() {
    // Watch the dependency
    ref.watch(clientRepositoryProvider);
    _loadClients();
    return [];
  }

  Future<void> _loadClients() async {
    // Access repository using ref.read inside methods or ref.watch in build.
    // Since we watched it in build, we can read it here or state might be reset if repo changes.
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
