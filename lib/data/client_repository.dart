import '../models/client.dart';

abstract class ClientRepository {
  Future<void> saveClient(Client client);
  Future<Client?> getClient(String id);
  Future<List<Client>> getAllClients();
  Future<void> deleteClient(String id);
  Future<void> deleteAll();
}
