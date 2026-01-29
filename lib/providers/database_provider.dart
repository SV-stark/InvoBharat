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

// Simple provider to track migration status
class MigrationStatusNotifier extends Notifier<String> {
  @override
  String build() => "Initializing...";

  void update(String status) => state = status;
}

final migrationStatusProvider =
    NotifierProvider<MigrationStatusNotifier, String>(
        MigrationStatusNotifier.new);

final appInitializationProvider = FutureProvider<void>((ref) async {
  // Ensure database is ready
  Future.microtask(() {
    ref.read(migrationStatusProvider.notifier).update("Opening Database...");
  });

  ref.watch(databaseProvider);

  // Run Migration
  final migrationService = ref.read(migrationServiceProvider);
  await migrationService.performMigration((status) {
    ref.read(migrationStatusProvider.notifier).update(status);
  });
});
