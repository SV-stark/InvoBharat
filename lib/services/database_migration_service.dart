import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invobharat/models/client.dart' as model_client;
import 'package:invobharat/models/invoice.dart' as model_invoice;
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/data/sql_client_repository.dart';

import 'package:invobharat/database/database.dart';
import 'dart:convert';

class DatabaseMigrationService {
  final AppDatabase database;

  DatabaseMigrationService(this.database);

  Future<void> performMigration(final Function(String) onProgress) async {
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
    final String profileId,
    final Function(String) onProgress,
  ) async {
    final sqlRepo = SqlClientRepository(database);

    onProgress("Starting Client Migration...");

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/InvoBharat/profiles/$profileId/clients';
      final dir = Directory(path);

      if (!await dir.exists()) return;

      int count = 0;
      await for (final file in dir.list(followLinks: false)) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final String contents = await file.readAsString();
            final client = model_client.Client.fromJson(jsonDecode(contents));
            final c = client.copyWith(profileId: profileId);
            await sqlRepo.saveClient(c);
            count++;

            if (count % 5 == 0) {
              onProgress("Migrated $count clients...");
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error migrating client file ${file.path}: $e");
            }
          }
        }
      }
      if (kDebugMode) print("Migrated $count clients.");
    } catch (e) {
      if (kDebugMode) print("Error accessing client directory: $e");
    }
  }

  Future<void> _migrateInvoices(
    final String profileId,
    final Function(String) onProgress,
  ) async {
    final sqlRepo = SqlInvoiceRepository(database);

    onProgress("Starting Invoice Migration...");

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/InvoBharat/profiles/$profileId/invoices';
      final dir = Directory(path);

      if (!await dir.exists()) return;

      int count = 0;
      await for (final file in dir.list(followLinks: false)) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final String contents = await file.readAsString();
            final invoice = model_invoice.Invoice.fromJson(
              jsonDecode(contents),
            );
            await sqlRepo.saveInvoice(invoice);
            count++;

            if (count % 5 == 0) {
              onProgress("Migrated $count invoices...");
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error migrating invoice file ${file.path}: $e");
            }
          }
        }
      }
      if (kDebugMode) print("Migrated $count invoices.");
    } catch (e) {
      if (kDebugMode) print("Error accessing invoice directory: $e");
    }
  }

  Future<void> _markMigrated(final SharedPreferences prefs) async {
    await prefs.setBool('db_migration_completed_v1', true);
  }
}
