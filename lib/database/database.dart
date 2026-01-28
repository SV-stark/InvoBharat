import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
    tables: [BusinessProfiles, Clients, Invoices, InvoiceItems, Payments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onCreate: (Migrator m) async {
      await m.createAll();
    }, onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // ... (existing v2 migration)
        // Add new supplier columns
        await m.addColumn(invoices, invoices.supplierName);
        await m.addColumn(invoices, invoices.supplierAddress);
        await m.addColumn(invoices, invoices.supplierGstin);
        await m.addColumn(invoices, invoices.supplierEmail);
        await m.addColumn(invoices, invoices.supplierPhone);

        // Backfill using active profile
        try {
          final prefs = await SharedPreferences.getInstance();
          final activeId = prefs.getString('active_profile_id');
          final profilesList = prefs.getStringList('business_profiles_list');

          if (activeId != null && profilesList != null) {
            // Find active profile map
            Map<String, dynamic>? activeProfile;
            for (var s in profilesList) {
              final map = jsonDecode(s);
              if (map['id'] == activeId) {
                activeProfile = map;
                break;
              }
            }

            if (activeProfile != null) {
              // Run Update
              final name = activeProfile['companyName'] ?? '';
              final addr = activeProfile['address'] ?? '';
              final gst = activeProfile['gstin'] ?? '';
              final email = activeProfile['email'] ?? '';
              final phone = activeProfile['phone'] ?? '';

              // SQL Injection? Bound parameters are safer.
              await m.database.customStatement(
                  'UPDATE invoices SET supplier_name = ?, supplier_address = ?, supplier_gstin = ?, supplier_email = ?, supplier_phone = ? WHERE supplier_name IS NULL',
                  [name, addr, gst, email, phone]);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Migration V2 Backfill Error: $e");
          }
        }
      }
      if (from < 3) {
        await m.addColumn(invoices, invoices.originalInvoiceNumber);
        await m.addColumn(invoices, invoices.originalInvoiceDate);
      }
      if (from < 4) {
        // Add Receiver Snapshot Columns
        await m.addColumn(invoices, invoices.receiverName);
        await m.addColumn(invoices, invoices.receiverAddress);
        await m.addColumn(invoices, invoices.receiverGstin);
        await m.addColumn(invoices, invoices.receiverPan);
        await m.addColumn(invoices, invoices.receiverState);
        await m.addColumn(invoices, invoices.receiverStateCode);
        await m.addColumn(invoices, invoices.receiverEmail);

        // Backfill Receiver Details from Linked Client
        // Since we are using SQLite, we can use a subquery update or a join update if supported.
        // Standard SQLite:
        // UPDATE invoices SET receiver_name = (SELECT name FROM clients WHERE clients.id = invoices.client_id)

        try {
          await m.database.customStatement('''
            UPDATE invoices SET 
              receiver_name = (SELECT name FROM clients WHERE clients.id = invoices.client_id),
              receiver_address = (SELECT address FROM clients WHERE clients.id = invoices.client_id),
              receiver_gstin = (SELECT gstin FROM clients WHERE clients.id = invoices.client_id),
              receiver_pan = (SELECT pan FROM clients WHERE clients.id = invoices.client_id),
              receiver_state = (SELECT state FROM clients WHERE clients.id = invoices.client_id),
              receiver_state_code = (SELECT state_code FROM clients WHERE clients.id = invoices.client_id),
              receiver_email = (SELECT email FROM clients WHERE clients.id = invoices.client_id)
            WHERE client_id IS NOT NULL AND receiver_name IS NULL
           ''');
        } catch (e) {
          if (kDebugMode) {
            print("Migration V4 Backfill Error: $e");
          }
        }
      }
    }, beforeOpen: (details) async {
      // We can do data migration here too if needed
      if (details.wasCreated) {
        // ...
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'InvoBharat', 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
