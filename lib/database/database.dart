import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:invobharat/database/tables.dart';
import 'package:invobharat/services/logger_service.dart';

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
    Estimates,
    EstimateItems,
    RecurringProfilesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([final QueryExecutor? executor])
    : super(executor ?? _openConnection()) {
    _instance = this;
  }

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();
  static void resetInstance() {
    _instance = null;
  }

  @override
  int get schemaVersion => 17;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (final Migrator m) async {
        await m.createAll();
        await _createIndexes(m.database);
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
          } catch (e, st) {
            LoggerService.talker.handle(e, st, "Migration V2 Backfill Error");
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
          } catch (e, st) {
            LoggerService.talker.handle(e, st, "Migration V4 Backfill Error");
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
          await m.database.customStatement('PRAGMA foreign_keys = OFF;');
          await m.database.customStatement('PRAGMA legacy_alter_table = ON;');
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

              // 3. Copy data from temp to new table (only columns that existed in temp table)
              final pragmaResult = await m.database
                  .customSelect('PRAGMA table_info(`$tempName`)')
                  .get();
              final existingCols = pragmaResult
                  .map((final r) => r.read<String>('name'))
                  .toSet();
              final columnsToCopy = table.$columns
                  .map((final c) => c.name)
                  .where((final name) => existingCols.contains(name))
                  .join(', ');

              if (columnsToCopy.isNotEmpty) {
                await m.database.customStatement(
                  'INSERT INTO `$tableName` ($columnsToCopy) SELECT $columnsToCopy FROM `$tempName`',
                );
              }

              // 4. Drop temp table
              await m.database.customStatement('DROP TABLE `$tempName`');
            }
          });
          await m.database.customStatement('PRAGMA legacy_alter_table = OFF;');
          await m.database.customStatement('PRAGMA foreign_keys = ON;');
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
          } catch (e, st) {
            LoggerService.talker.handle(e, st, "Migration V9 Backfill Error");
          }
        }
        if (from < 10) {
          await m.addColumn(invoices, invoices.receiverPhone);
        }
        if (from < 11) {
          await m.addColumn(invoices, invoices.ewayBillNo);
          await m.addColumn(invoices, invoices.vehicleNo);
          await m.addColumn(invoices, invoices.irnNo);
        }
        if (from < 12) {
          await m.database.customStatement('PRAGMA foreign_keys = OFF;');
          await m.database.customStatement('PRAGMA legacy_alter_table = ON;');
          await m.database.transaction(() async {
            final table = clients;
            final tableName = table.actualTableName;
            final tempName = '${tableName}_temp';

            // 1. Rename existing table to temp
            await m.database.customStatement(
              'ALTER TABLE `$tableName` RENAME TO `$tempName`',
            );

            // 2. Create new table with updated constraints (no UNIQUE constraint)
            await m.createTable(table);

            // 3. Copy all columns
            final columnsToCopy = table.$columns
                .map((final c) => c.name)
                .join(', ');
            await m.database.customStatement(
              'INSERT INTO `$tableName` ($columnsToCopy) SELECT $columnsToCopy FROM `$tempName`',
            );

            // 4. Drop temp table
            await m.database.customStatement('DROP TABLE `$tempName`');

            // 5. Create partial unique index where gstin is not empty/null
            await m.database.customStatement(
              "CREATE UNIQUE INDEX IF NOT EXISTS `idx_clients_profile_gstin` ON `clients` (profile_id, gstin) WHERE gstin IS NOT NULL AND gstin != '' AND gstin != 'null'",
            );
          });
          await m.database.customStatement('PRAGMA legacy_alter_table = OFF;');
          await m.database.customStatement('PRAGMA foreign_keys = ON;');
        }
        if (from < 13) {
          await m.createTable(estimates);
          await m.createTable(estimateItems);
          await m.createTable(recurringProfilesTable);

          await m.database.customStatement('PRAGMA foreign_keys = OFF;');
          await m.database.customStatement('PRAGMA legacy_alter_table = ON;');
          await m.database.transaction(() async {
            final table = invoices;
            final tableName = table.actualTableName;
            final tempName = '${tableName}_temp';

            await m.database.customStatement(
              'ALTER TABLE `$tableName` RENAME TO `$tempName`',
            );

            await m.createTable(table);

            final columnsToCopy = table.$columns
                .map((final c) => c.name)
                .join(', ');
            await m.database.customStatement(
              'INSERT INTO `$tableName` ($columnsToCopy) SELECT $columnsToCopy FROM `$tempName`',
            );

            await m.database.customStatement('DROP TABLE `$tempName`');
          });
          await m.database.customStatement('PRAGMA legacy_alter_table = OFF;');
          await m.database.customStatement('PRAGMA foreign_keys = ON;');
        }
        if (from < 14) {
          await _createIndexes(m.database);
        }
        if (from < 15) {
          final pragmaResult = await m.database
              .customSelect('PRAGMA table_info(`business_profiles`)')
              .get();
          final existingCols = pragmaResult
              .map((final r) => r.read<String>('name'))
              .toSet();
          if (!existingCols.contains('stamp_x')) {
            await m.addColumn(businessProfiles, businessProfiles.stampX);
          }
          if (!existingCols.contains('stamp_y')) {
            await m.addColumn(businessProfiles, businessProfiles.stampY);
          }
          if (!existingCols.contains('signature_x')) {
            await m.addColumn(businessProfiles, businessProfiles.signatureX);
          }
          if (!existingCols.contains('signature_y')) {
            await m.addColumn(businessProfiles, businessProfiles.signatureY);
          }
          await _createIndexes(m.database);
        }
        if (from < 16) {
          await _repairCorruptedForeignKeys(m.database);
          await _createIndexes(m.database);
        }
        if (from < 17) {
          final pragmaResult = await m.database
              .customSelect('PRAGMA table_info(`clients`)')
              .get();
          final existingCols = pragmaResult
              .map((final r) => r.read<String>('name'))
              .toSet();
          if (!existingCols.contains('primary_contact')) {
            await m.addColumn(clients, clients.primaryContact);
          }
          if (!existingCols.contains('notes')) {
            await m.addColumn(clients, clients.notes);
          }
          await _createIndexes(m.database);
        }
      },
      beforeOpen: (final details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        if (details.wasCreated) {
          // ...
        }
      },
    );
  }

  static Future<void> _repairCorruptedForeignKeys(
    final GeneratedDatabase db,
  ) async {
    try {
      await db.customStatement('PRAGMA foreign_keys = OFF;');
      await db.customStatement('PRAGMA legacy_alter_table = ON;');

      final tablesWithTemp = await db
          .customSelect(
            "SELECT name, sql FROM sqlite_master WHERE type='table' AND sql LIKE '%_temp%'",
          )
          .get();

      if (tablesWithTemp.isNotEmpty) {
        for (final row in tablesWithTemp) {
          final tableName = row.read<String>('name');
          final tableInfo = db.allTables
              .cast<TableInfo<Table, dynamic>?>()
              .firstWhere(
                (final t) => t?.actualTableName == tableName,
                orElse: () => null,
              );

          if (tableInfo != null) {
            final tempBackupName = '${tableName}_repair_tmp';
            await db.customStatement(
              'ALTER TABLE `$tableName` RENAME TO `$tempBackupName`',
            );
            await Migrator(db).createTable(tableInfo);

            final pragmaResult = await db
                .customSelect('PRAGMA table_info(`$tempBackupName`)')
                .get();
            final existingCols = pragmaResult
                .map((final r) => r.read<String>('name'))
                .toSet();
            final columnsToCopy = tableInfo.$columns
                .map((final c) => c.name)
                .where((final name) => existingCols.contains(name))
                .join(', ');

            if (columnsToCopy.isNotEmpty) {
              await db.customStatement(
                'INSERT INTO `$tableName` ($columnsToCopy) SELECT $columnsToCopy FROM `$tempBackupName`',
              );
            }
            await db.customStatement('DROP TABLE `$tempBackupName`');
          }
        }
      }
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Schema Foreign Key Repair Error");
    } finally {
      await db.customStatement('PRAGMA legacy_alter_table = OFF;');
      await db.customStatement('PRAGMA foreign_keys = ON;');
    }
  }

  static Future<void> _repairDuplicateInvoiceNumbers(
    final GeneratedDatabase db,
  ) async {
    try {
      final duplicates = await db.customSelect(
        '''
        SELECT profile_id, invoice_no, COUNT(*) as cnt
        FROM invoices
        GROUP BY profile_id, invoice_no
        HAVING cnt > 1
        ''',
      ).get();

      for (final dup in duplicates) {
        final profileId = dup.read<String>('profile_id');
        final invoiceNo = dup.read<String>('invoice_no');
        final rows = await db.customSelect(
          'SELECT id FROM invoices WHERE profile_id = ? AND invoice_no = ? ORDER BY invoice_date ASC, rowid ASC',
          variables: [
            Variable.withString(profileId),
            Variable.withString(invoiceNo),
          ],
        ).get();

        for (int i = 1; i < rows.length; i++) {
          final id = rows[i].read<String>('id');
          final newNo = '$invoiceNo-dup$i';
          await db.customStatement(
            'UPDATE invoices SET invoice_no = ? WHERE id = ?',
            [newNo, id],
          );
        }
      }
    } catch (e, st) {
      LoggerService.talker.handle(
        e,
        st,
        "Error resolving duplicate invoice numbers",
      );
    }
  }

  static Future<void> _createIndexes(final GeneratedDatabase db) async {
    await db.customStatement(
      "CREATE UNIQUE INDEX IF NOT EXISTS `idx_business_profiles_gstin` ON `business_profiles` (gstin) WHERE gstin IS NOT NULL AND gstin != '' AND gstin != 'null';",
    );
    await db.customStatement(
      "CREATE UNIQUE INDEX IF NOT EXISTS `idx_clients_profile_gstin` ON `clients` (profile_id, gstin) WHERE gstin IS NOT NULL AND gstin != '' AND gstin != 'null';",
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_invoices_profile_date ON invoices (profile_id, invoice_date);',
    );
    await _repairDuplicateInvoiceNumbers(db);
    await db.customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_invoices_profile_number ON invoices (profile_id, invoice_no);',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_invoices_profile_type ON invoices (profile_id, type);',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_invoices_profile_client ON invoices (profile_id, client_id);',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_invoices_client_id ON invoices (client_id);',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON invoice_items (invoice_id);',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_payments_invoice_id ON payments (invoice_id);',
    );
  }

  Future<void> vacuumInto(final String path) async {
    await customStatement('VACUUM INTO ?', [path]);
  }
}

QueryExecutor _openConnection() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return NativeDatabase.memory();
  }
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
      if (smtpHost != null && smtpHost.isNotEmpty) {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'smtp_host', value: smtpHost);
        await secureStorage.write(
          key: 'smtp_port',
          value: (prefs.getInt('smtp_port') ?? 587).toString(),
        );
        await secureStorage.write(
          key: 'smtp_email',
          value: prefs.getString('smtp_email') ?? '',
        );
        await secureStorage.write(
          key: 'smtp_username',
          value: prefs.getString('smtp_username') ?? '',
        );
        await secureStorage.write(
          key: 'smtp_is_secure',
          value: (prefs.getBool('smtp_is_secure') ?? true).toString(),
        );
        await prefs.remove('smtp_host');
        await prefs.remove('smtp_port');
        await prefs.remove('smtp_email');
        await prefs.remove('smtp_username');
        await prefs.remove('smtp_is_secure');
      }

      final legacyPassword = prefs.getString('smtp_password');
      if (legacyPassword != null && legacyPassword.isNotEmpty) {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'smtp_password', value: legacyPassword);
        await prefs.remove('smtp_password');
      }
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Settings Migration Error");
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
