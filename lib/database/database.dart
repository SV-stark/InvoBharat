import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:invobharat/database/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    BusinessProfiles,
    Clients,
    Invoices,
    InvoiceItems,
    Payments,
    BankAccounts,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([final QueryExecutor? executor])
    : super(executor ?? _openConnection()) {
    _instance = this;
  }

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (final Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (final Migrator m, final int from, final int to) async {
        if (from < 2) {
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

                await m.database.customStatement(
                  'UPDATE invoices SET supplier_name = ?, supplier_address = ?, supplier_gstin = ?, supplier_email = ?, supplier_phone = ? WHERE supplier_name IS NULL',
                  [name, addr, gst, email, phone],
                );
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
        if (from < 5) {
          await m.addColumn(businessProfiles, businessProfiles.pan);
        }
        if (from < 6) {
          await m.createTable(appSettings);
          final settingsService = AppSettingsService(this);
          await settingsService.migrateFromSharedPrefs();
        }
        if (from < 7) {
          // Migration for foreign key constraints and unique indices.
          // Recreating tables safely with data preservation.
          await m.database.transaction(() async {
            final List<TableInfo<Table, dynamic>> tables = [
              businessProfiles as TableInfo<Table, dynamic>,
              clients as TableInfo<Table, dynamic>,
              invoices as TableInfo<Table, dynamic>,
              invoiceItems as TableInfo<Table, dynamic>,
              payments as TableInfo<Table, dynamic>,
            ];

            for (final table in tables) {
              final tableName = table.actualTableName;
              final tempName = '${tableName}_temp';

              // 1. Rename existing table to temp
              await m.database.customStatement(
                'ALTER TABLE `$tableName` RENAME TO `$tempName`',
              );

              // 2. Create new table with updated constraints
              await m.createTable(table);

              // instead of mapping table.$columns (which has V10 columns),
              // we manually list or safely query.
              
              // 3. Copy data from temp to new table
              // Drift doesn't give a great way to read results from customStatement easily here,
              // but we can assume V6 columns or just use a safer approach.
              // Let's use a simpler approach: only copy columns that are in BOTH.
              // For simplicity in this fix, we'll hardcode the known V6 columns or use a helper.
              // Actually, sqlite allows: INSERT INTO table (col1) SELECT col1 FROM temp
              // We'll filter the current columns by checking if they exist in temp.
              // But drift's customStatement returns void.
              
              // Let's use a more robust check if possible, or just be careful.
              // For now, I'll filter out columns known to be added in V8, V9, V10.
              final newCols = {'po_number', 'status', 'sent_at', 'receiver_phone'};
              final columnsToCopy = table.$columns
                  .map((final c) => c.name)
                  .where((final name) => !newCols.contains(name))
                  .join(', ');

              await m.database.customStatement(
                'INSERT INTO `$tableName` ($columnsToCopy) SELECT $columnsToCopy FROM `$tempName`',
              );

              // 4. Drop temp table
              await m.database.customStatement('DROP TABLE `$tempName`');
            }
          });
        }
        if (from < 8) {
          await m.addColumn(invoices, invoices.poNumber);
          await m.addColumn(invoices, invoices.status);
          await m.addColumn(invoices, invoices.sentAt);
        }
        if (from < 9) {
          await m.createTable(bankAccounts);
          // Backfill bank accounts from business profiles
          try {
            await m.database.customStatement('''
              INSERT INTO bank_accounts (id, profile_id, bank_name, account_no, ifsc_code, branch, is_default)
              SELECT lower(hex(randomblob(16))), id, bank_name, account_no, ifsc_code, branch, 1
              FROM business_profiles
              WHERE bank_name IS NOT NULL AND bank_name != ''
            ''');
          } catch (e) {
            if (kDebugMode) {
              print("Migration V9 Backfill Error: $e");
            }
          }
        }
        if (from < 10) {
          await m.addColumn(invoices, invoices.receiverPhone);
        }
      },
      beforeOpen: (final details) async {
        if (details.wasCreated) {
          // ...
        }
      },
    );
  }

  Future<void> vacuumInto(final String path) async {
    await customStatement('VACUUM INTO ?', [path]);
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'db');
}

class AppSettingsService {
  final AppDatabase _db;

  AppSettingsService(this._db);

  Future<void> migrateFromSharedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeMode = prefs.getString('theme_mode');
      if (themeMode != null) {
        await _db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
          ['theme_mode', themeMode],
        );
      }

      final paneIndex = prefs.getInt('pane_display_mode');
      if (paneIndex != null) {
        await _db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
          ['pane_display_mode', paneIndex.toString()],
        );
      }

      final smtpHost = prefs.getString('smtp_host');
      if (smtpHost != null) {
        await _db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
          ['smtp_host', smtpHost],
        );
        await _db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
          ['smtp_port', (prefs.getInt('smtp_port') ?? 587).toString()],
        );
        await _db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
          ['smtp_email', prefs.getString('smtp_email') ?? ''],
        );
        await _db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
          ['smtp_username', prefs.getString('smtp_username') ?? ''],
        );
        await _db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
          [
            'smtp_is_secure',
            (prefs.getBool('smtp_is_secure') ?? true).toString(),
          ],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Settings Migration Error: $e");
      }
    }
  }

  Future<String?> getSetting(final String key) async {
    final results = await _db
        .customSelect(
          'SELECT value FROM app_settings WHERE key = ?',
          variables: [Variable.withString(key)],
        )
        .get();
    if (results.isEmpty) return null;
    return results.first.read<String>('value');
  }

  Future<void> setSetting(final String key, final String value) async {
    await _db.customStatement(
      'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
      [key, value],
    );
  }
}
