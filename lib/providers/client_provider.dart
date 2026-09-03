import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/data/sql_client_repository.dart';
import 'package:invobharat/data/client_repository.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/database_provider.dart';

import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/services/logger_service.dart';

final clientRepositoryProvider = Provider<ClientRepository>((final ref) {
  final db = ref.watch(databaseProvider);
  final profile = ref.watch(businessProfileProvider);
  return SqlClientRepository(db, profile.id);
});

final clientListProvider = NotifierProvider<ClientListNotifier, List<Client>>(
  ClientListNotifier.new,
);

class ClientListNotifier extends Notifier<List<Client>> {
  @override
  List<Client> build() {
    // Watch the dependency
    ref.watch(clientRepositoryProvider);
    _loadClients();
    return [];
  }

  Future<void> _loadClients() async {
    try {
      final repository = ref.read(clientRepositoryProvider);
      state = await repository.getAllClients();
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Error loading clients");
    }
  }

  Future<void> addClient(final Client client) async {
    try {
      final repository = ref.read(clientRepositoryProvider);

      Client newClient = client;
      if (newClient.id.isEmpty) {
        newClient = newClient.copyWith(id: const Uuid().v4());
      }

      await repository.saveClient(newClient);
      await _loadClients();
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Error adding client");
    }
  }

  Future<void> updateClient(final Client client) async {
    try {
      final repository = ref.read(clientRepositoryProvider);
      await repository.saveClient(client);
      await _loadClients();
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Error updating client");
    }
  }

  Future<void> deleteClient(final String clientId) async {
    try {
      final repository = ref.read(clientRepositoryProvider);
      await repository.deleteClient(clientId);
      await _loadClients();
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Error deleting client");
    }
  }
}
