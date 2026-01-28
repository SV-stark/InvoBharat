import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/file_invoice_repository.dart';
import '../data/sql_invoice_repository.dart';
import '../data/file_client_repository.dart';
import '../data/sql_client_repository.dart';

import '../database/database.dart';
import 'dart:convert';

class DatabaseMigrationService {
  final AppDatabase database;

  DatabaseMigrationService(this.database);

  Future<void> performMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final isMigrated = prefs.getBool('db_migration_completed_v1') ?? false;

    if (isMigrated) {
      if (kDebugMode) print("Data already migrated to SQLite. Skipping.");
      return;
    }

    if (kDebugMode) print("Starting Migration from JSON to SQLite...");

    // 1. Fetch all Business Profiles
    // Profiles are stored in SharedPreferences. We need to iterate them to find JSON files.
    final profilesList = prefs.getStringList('business_profiles_list') ?? [];

    if (profilesList.isEmpty) {
      // No profiles? effectively new app or just default.
      await _markMigrated(prefs);
      return;
    }

    try {
      for (var profileJson in profilesList) {
        final profileMap = jsonDecode(profileJson);
        final profileId = profileMap['id'];

        if (profileId == null) continue;

        if (kDebugMode) print("Migrating Profile: $profileId");

        // 2. Migrate Clients
        await _migrateClients(profileId);

        // 3. Migrate Invoices (and verify/create default clients if needed)
        await _migrateInvoices(profileId);
      }

      await _markMigrated(prefs);
      if (kDebugMode) print("Migration Completed Successfully.");
    } catch (e) {
      if (kDebugMode) print("CRITICAL MIGRATION ERROR: $e");
      // Do NOT mark migrated so it retries next time?
      // Or mark it to prevent boot loop?
      // Safer to retry.
    }
  }

  Future<void> _migrateClients(String profileId) async {
    final fileRepo = FileClientRepository(profileId: profileId);
    final sqlRepo = SqlClientRepository(database);

    final clients = await fileRepo.getAllClients();
    for (var client in clients) {
      // Ensure profileId is set correctly
      final c = client.copyWith(profileId: profileId);
      await sqlRepo.saveClient(c);
    }
    if (kDebugMode) print("Migrated ${clients.length} clients.");
  }

  Future<void> _migrateInvoices(String profileId) async {
    final fileRepo = FileInvoiceRepository(profileId: profileId);
    final sqlRepo = SqlInvoiceRepository(database);

    final invoices = await fileRepo.getAllInvoices();
    int count = 0;
    for (var invoice in invoices) {
      // Save using SQL logic which handles items and payments
      await sqlRepo.saveInvoice(invoice);
      count++;
      if (count % 10 == 0) {
        await Future.delayed(Duration.zero);
      }
    }
    if (kDebugMode) print("Migrated ${invoices.length} invoices.");
  }

  Future<void> _markMigrated(SharedPreferences prefs) async {
    await prefs.setBool('db_migration_completed_v1', true);
  }
}
