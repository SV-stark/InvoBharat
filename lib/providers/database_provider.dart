import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../services/database_migration_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final migrationServiceProvider = Provider<DatabaseMigrationService>((ref) {
  final db = ref.watch(databaseProvider);
  return DatabaseMigrationService(db);
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  // Ensure database is ready
  ref.watch(databaseProvider);

  // Run Migration
  final migrationService = ref.read(migrationServiceProvider);
  await migrationService.performMigration();
});
