import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/services/database_migration_service.dart';
import 'dart:async';

final databaseProvider = Provider<AppDatabase>((final ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final appSettingsServiceProvider = Provider<AppSettingsService>((final ref) {
  final db = ref.watch(databaseProvider);
  return AppSettingsService(db);
});

final migrationServiceProvider = Provider<DatabaseMigrationService>((
  final ref,
) {
  final db = ref.watch(databaseProvider);
  return DatabaseMigrationService(db);
});

// Simple provider to track migration status
class MigrationStatusNotifier extends Notifier<String> {
  @override
  String build() => "Initializing...";

  void update(final String status) => state = status;
}

final migrationStatusProvider =
    NotifierProvider<MigrationStatusNotifier, String>(
      MigrationStatusNotifier.new,
    );

final appInitializationProvider = FutureProvider<void>((final ref) async {
  // Ensure database is ready
  Future.microtask(() {
    ref.read(migrationStatusProvider.notifier).update("Opening Database...");
  });

  ref.watch(databaseProvider);

  // Run Migration
  final migrationService = ref.read(migrationServiceProvider);
  await migrationService.performMigration((final status) {
    ref.read(migrationStatusProvider.notifier).update(status);
  });
});
