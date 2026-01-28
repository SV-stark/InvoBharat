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

  Future<void> performMigration(Function(String) onProgress) async {
    final prefs = await SharedPreferences.getInstance();
    final isMigrated = prefs.getBool('db_migration_completed_v1') ?? false;

    if (isMigrated) {
      if (kDebugMode) print("Data already migrated to SQLite. Skipping.");
      return;
    }

    if (kDebugMode) print("Starting Migration from JSON to SQLite...");
    onProgress("Checking for existing data...");

    // 1. Fetch all Business Profiles
    final profilesList = prefs.getStringList('business_profiles_list') ?? [];

    if (profilesList.isEmpty) {
      await _markMigrated(prefs);
      return;
    }

    try {
      int profileCount = 0;
      for (var profileJson in profilesList) {
        profileCount++;
        final profileMap = jsonDecode(profileJson);
        final profileId = profileMap['id'];
        final companyName =
            profileMap['companyName'] ?? "Profile $profileCount";

        if (profileId == null) continue;

        if (kDebugMode) print("Migrating Profile: $profileId");
        onProgress("Migrating Profile: $companyName");

        // 2. Migrate Clients
        await _migrateClients(profileId, onProgress);

        // 3. Migrate Invoices
        await _migrateInvoices(profileId, onProgress);
      }

      onProgress("Finalizing Migration...");
      await _markMigrated(prefs);
      if (kDebugMode) print("Migration Completed Successfully.");
    } catch (e) {
      if (kDebugMode) print("CRITICAL MIGRATION ERROR: $e");
      onProgress("Error: $e");
      // Delay so user can see error?
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _migrateClients(
      String profileId, Function(String) onProgress) async {
    final fileRepo = FileClientRepository(profileId: profileId);
    final sqlRepo = SqlClientRepository(database);

    onProgress("Reading Clients...");
    final clients = await fileRepo.getAllClients();

    int count = 0;
    int total = clients.length;

    for (var client in clients) {
      final c = client.copyWith(profileId: profileId);
      await sqlRepo.saveClient(c);
      count++;
      if (count % 10 == 0) {
        await Future.delayed(Duration.zero);
        onProgress("Migrating Clients ($count/$total)...");
      }
    }
    if (kDebugMode) print("Migrated ${clients.length} clients.");
  }

  Future<void> _migrateInvoices(
      String profileId, Function(String) onProgress) async {
    final fileRepo = FileInvoiceRepository(profileId: profileId);
    final sqlRepo = SqlInvoiceRepository(database);

    onProgress("Reading Invoices...");
    final invoices = await fileRepo.getAllInvoices();

    int count = 0;
    int total = invoices.length;

    for (var invoice in invoices) {
      // Save using SQL logic which handles items and payments
      await sqlRepo.saveInvoice(invoice);
      count++;
      if (count % 10 == 0) {
        await Future.delayed(Duration.zero);
        onProgress("Migrating Invoices ($count/$total)...");
      }
    }
    if (kDebugMode) print("Migrated ${invoices.length} invoices.");
  }

  Future<void> _markMigrated(SharedPreferences prefs) async {
    await prefs.setBool('db_migration_completed_v1', true);
  }
}
