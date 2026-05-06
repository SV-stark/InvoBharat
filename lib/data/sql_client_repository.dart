import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/client.dart' as model;
import 'package:invobharat/data/client_repository.dart';

class SqlClientRepository implements ClientRepository {
  final AppDatabase database;
  final String profileId;

  SqlClientRepository(this.database, this.profileId);

  @override
  Future<void> saveClient(final model.Client client) async {
    await database.into(database.clients).insertOnConflictUpdate(
      ClientsCompanion(
        id: Value(client.id.isEmpty ? const Uuid().v4() : client.id),
        profileId: Value(profileId), // Use repository profileId
        name: Value(client.name),
        address: Value(client.address),
        gstin: Value(client.gstin),
        pan: Value(client.pan),
        state: Value(client.state),
        stateCode: Value(client.stateCode),
        email: Value(client.email),
        phone: Value(client.phone),
      ),
    );
  }

  @override
  Future<model.Client?> getClient(final String id) async {
    final query = database.select(database.clients)
      ..where((final tbl) => tbl.id.equals(id) & tbl.profileId.equals(profileId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToClient(row);
  }

  @override
  Future<List<model.Client>> getAllClients() async {
    final rows = await (database.select(database.clients)
          ..where((final tbl) => tbl.profileId.equals(profileId)))
        .get();
    return rows.map(_mapRowToClient).toList();
  }

  @override
  Future<void> deleteClient(final String id) async {
    await (database.delete(database.clients)
          ..where((final tbl) => tbl.id.equals(id) & tbl.profileId.equals(profileId)))
        .go();
  }

  @override
  Future<void> deleteAll() async {
    await (database.delete(database.clients)
          ..where((final tbl) => tbl.profileId.equals(profileId)))
        .go();
  }

  model.Client _mapRowToClient(final Client row) {
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
