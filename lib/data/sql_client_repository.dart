import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/client.dart' as model;
import 'client_repository.dart';

class SqlClientRepository implements ClientRepository {
  final AppDatabase database;

  SqlClientRepository(this.database);

  @override
  Future<void> saveClient(model.Client client) async {
    await database.into(database.clients).insertOnConflictUpdate(
          ClientsCompanion(
            id: Value(client.id.isEmpty ? const Uuid().v4() : client.id),
            profileId: Value(client.profileId),
            name: Value(client.name),
            address: Value(client.address),
            gstin: Value(client.gstin),
            pan: Value(client.pan), // Added field
            state: Value(client.state),
            stateCode: Value(client.stateCode), // Added field
            email: Value(client.email),
            phone: Value(client.phone),
          ),
        );
  }

  @override
  Future<model.Client?> getClient(String id) async {
    final query = database.select(database.clients)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToClient(row);
  }

  @override
  Future<List<model.Client>> getAllClients() async {
    final rows = await database.select(database.clients).get();
    return rows.map(_mapRowToClient).toList();
  }

  @override
  Future<void> deleteClient(String id) async {
    await (database.delete(database.clients)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<void> deleteAll() async {
    await database.delete(database.clients).go();
  }

  model.Client _mapRowToClient(Client row) {
    return model.Client(
      id: row.id,
      name: row.name,
      gstin: row.gstin,
      address: row.address,
      email: row.email,
      phone: row.phone,
      state: row.state,
      pan: row.pan,
      stateCode: row.stateCode,
      profileId: row.profileId,
    );
  }
}
