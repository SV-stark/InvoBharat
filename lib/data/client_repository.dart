import 'package:invobharat/models/client.dart';

abstract class ClientRepository {
  Future<void> saveClient(final Client client);
  Future<Client?> getClient(final String id);
  Future<List<Client>> getAllClients();
  Future<void> deleteClient(final String id);
  Future<void> deleteAll();
}
