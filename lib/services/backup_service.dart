import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:invobharat/services/csv_export_service.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/services/logger_service.dart';
import 'package:invobharat/utils/security_utils.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:uuid/uuid.dart';

final backupServiceProvider = Provider<BackupService>((final ref) {
  return BackupService(
    db: ref.watch(databaseProvider),
    ref: ref,
  );
});

const kDbFileName = 'db.sqlite';
const kMinCompatibleSchemaVersion = 5;

class ImportResult {
  final int successCount;
  final int skippedCount;
  final String? skippedCsv;

  ImportResult(this.successCount, this.skippedCount, this.skippedCsv);
}

abstract class FilePickerWrapper {
  Future<String?> saveFile({
    final String? dialogTitle,
    final String? fileName,
    final List<String>? allowedExtensions,
    final FileType type = FileType.any,
    required final Uint8List bytes,
  });
  Future<PlatformFile?> pickFile({
    final String? dialogTitle,
    final FileType type = FileType.any,
    final List<String>? allowedExtensions,
  });
}

class DefaultFilePickerWrapper implements FilePickerWrapper {
  @override
  Future<String?> saveFile({
    final String? dialogTitle,
    final String? fileName,
    final List<String>? allowedExtensions,
    final FileType type = FileType.any,
    required final Uint8List bytes,
  }) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName ?? '',
      allowedExtensions: allowedExtensions,
      type: type,
      bytes: bytes,
    );
    return uri?.toFilePath();
  }

  @override
  Future<PlatformFile?> pickFile({
    final String? dialogTitle,
    final FileType type = FileType.any,
    final List<String>? allowedExtensions,
  }) {
    return FilePicker.pickFile(
      dialogTitle: dialogTitle,
      type: type,
      allowedExtensions: allowedExtensions,
    );
  }
}

class BackupService {
  final FilePickerWrapper _filePicker;
  final CsvExportService _csvService;
  final AppDatabase? db;
  final Ref? ref;

  BackupService({
    FilePickerWrapper? filePicker,
    CsvExportService? csvService,
    this.db,
    this.ref,
  }) : _filePicker = filePicker ?? DefaultFilePickerWrapper(),
       _csvService = csvService ?? CsvExportService();

  Future<String> exportData(final SqlInvoiceRepository repository) async {
    try {
      final invoices = await repository.getAllInvoices();
      final csvString = await _csvService.generateInvoiceCsv(invoices);

      String? outputFile = await _filePicker.saveFile(
        dialogTitle: 'Save CSV Backup',
        fileName:
            'invobharat_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
        bytes: Uint8List.fromList(utf8.encode(csvString)),
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.csv')) {
          outputFile = '$outputFile.csv';
        }

        final file = File(outputFile);
        await file.writeAsString(csvString);
        return "Backup saved successfully to $outputFile";
      } else {
        return "Backup cancelled";
      }
    } catch (e) {
      debugPrint("Export Error: $e");
      throw Exception("Failed to export data: $e");
    }
  }

  Future<String> _getDbPath() async {
    final file = await getAppDatabaseFile();
    return file.path;
  }

  Future<void> _pruneDbBackups(
    final Directory dir,
    final String baseName,
  ) async {
    try {
      if (!await dir.exists()) return;
      final files = await dir.list().toList();
      final backupFiles = <File>[];
      for (final entity in files) {
        if (entity is File) {
          final name = p.basename(entity.path);
          if (name.startsWith('$baseName.') && name.endsWith('.bak')) {
            backupFiles.add(entity);
          }
        }
      }
      if (backupFiles.length > 3) {
        backupFiles.sort(
          (final a, final b) =>
              a.lastModifiedSync().compareTo(b.lastModifiedSync()),
        );
        final toDelete = backupFiles.take(backupFiles.length - 3);
        for (final f in toDelete) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("Failed to prune db backups: $e");
    }
  }

  Future<String> exportFullBackup() async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String? outputFile = await _filePicker.saveFile(
        dialogTitle: 'Save Full Backup (ZIP)',
        fileName: 'invobharat_backup_$timestamp.zip',
        allowedExtensions: ['zip'],
        type: FileType.custom,
        bytes: Uint8List(0),
      );

      if (outputFile == null) return "Backup cancelled";

      if (!outputFile.toLowerCase().endsWith('.zip')) {
        outputFile = '$outputFile.zip';
      }

      await createBackupArchive(outputFilePath: outputFile, database: db);
      return "Full Backup saved to $outputFile";
    } catch (e) {
      debugPrint("Full Backup Error: $e");
      throw Exception("Failed to create full backup: $e");
    }
  }

  /// Creates a complete backup zip archive containing SQLite DB, manifest, and all profile media.
  /// Shared between manual export and automated background backups.
  Future<void> createBackupArchive({
    required final String outputFilePath,
    final AppDatabase? database,
  }) async {
    final currentDb = database ?? db;
    final sessionId = const Uuid().v4();
    final tempDir = Directory(
      p.join(Directory.systemTemp.path, 'invobharat_backup_$sessionId'),
    );
    await tempDir.create(recursive: true);

    final tempDbPath = p.join(tempDir.path, 'export.sqlite');
    final tempManifestPath = p.join(tempDir.path, 'manifest.json');
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    try {
      File dbFile;
      if (currentDb != null) {
        await currentDb.vacuumInto(tempDbPath);
        dbFile = File(tempDbPath);
      } else {
        final dbPath = await _getDbPath();
        dbFile = File(dbPath);
        if (!await dbFile.exists()) {
          throw Exception("Database file not found at $dbPath");
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final activeProfileId = prefs.getString('active_profile_id') ?? '';
      final schemaVersion = currentDb?.schemaVersion ?? 17;

      final List<Map<String, String>> mediaEntries = [];
      if (currentDb != null) {
        final profiles = await currentDb
            .select(currentDb.businessProfiles)
            .get();
        for (final prof in profiles) {
          for (final entry in [
            {'type': 'logo', 'path': prof.logoPath},
            {'type': 'signature', 'path': prof.signaturePath},
            {'type': 'stamp', 'path': prof.stampPath},
          ]) {
            final String? srcPath = entry['path'];
            if (srcPath != null &&
                srcPath.isNotEmpty &&
                File(srcPath).existsSync()) {
              final String ext = p.extension(srcPath);
              final String zipMediaName =
                  'media/${prof.id}_${entry['type']}$ext';
              mediaEntries.add({
                'profileId': prof.id,
                'type': entry['type']!,
                'zipPath': zipMediaName,
                'originalPath': srcPath,
              });
            }
          }
        }
      }

      final manifestFile = File(tempManifestPath);
      await manifestFile.writeAsString(
        jsonEncode({
          'schemaVersion': schemaVersion,
          'activeProfileId': activeProfileId,
          'exportTimestamp': timestamp,
          'mediaEntries': mediaEntries,
        }),
      );

      final tempZipPath = p.join(tempDir.path, 'staging.zip');
      final zipEncoder = ZipFileEncoder();
      try {
        zipEncoder.create(tempZipPath);
        await zipEncoder.addFile(dbFile, kDbFileName);
        await zipEncoder.addFile(manifestFile, 'manifest.json');

        for (final m in mediaEntries) {
          final mediaFile = File(m['originalPath']!);
          if (await mediaFile.exists()) {
            await zipEncoder.addFile(mediaFile, m['zipPath']!);
          }
        }
      } finally {
        try {
          await zipEncoder.close();
        } catch (_) {}
      }

      final stagingFile = File(tempZipPath);
      final destFile = File(outputFilePath);
      if (await destFile.exists()) {
        await destFile.delete();
      }
      await stagingFile.copy(outputFilePath);
    } finally {
      if (await tempDir.exists()) {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  static Archive _decodeArchive(final Uint8List bytes) {
    return ZipDecoder().decodeBytes(bytes);
  }

  static Future<Archive> decodeZipInIsolate(final Uint8List bytes) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _decodeArchive(bytes);
    }
    return Isolate.run(() => _decodeArchive(bytes));
  }

  Future<String> restoreFullBackup() async {
    try {
      final PlatformFile? file = await _filePicker.pickFile(
        dialogTitle: 'Select Full Backup (ZIP)',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (file == null || file.path == null) {
        return "Restore cancelled";
      }

      final zipFile = File(file.path!);
      final bytes = await zipFile.readAsBytes();

      // Pre-decompression Zip-bomb & malformed entry protection
      const int maxTotalUncompressedBytes = 500 * 1024 * 1024; // 500 MB max
      const int maxFileCount = 10000;

      try {
        final zipDir = ZipDirectory.read(InputStream(bytes));
        if (zipDir.fileHeaders.length > maxFileCount) {
          throw Exception(
            "Invalid backup: File count (${zipDir.fileHeaders.length}) exceeds safe limit ($maxFileCount).",
          );
        }

        int totalExpectedBytes = 0;
        for (final h in zipDir.fileHeaders) {
          totalExpectedBytes += (h.uncompressedSize ?? 0);
          if (totalExpectedBytes > maxTotalUncompressedBytes) {
            throw Exception(
              "Invalid backup: Total uncompressed size exceeds 500 MB limit (potential zip-bomb).",
            );
          }
          if (h.filename.contains('..') ||
              h.filename.startsWith('/') ||
              h.filename.startsWith('\\')) {
            throw Exception(
              "Invalid backup: Malicious entry name detected '${h.filename}'.",
            );
          }
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception("Invalid backup archive structure: $e");
      }

      final archive = await decodeZipInIsolate(bytes);

      final dbEntry = archive.findFile(kDbFileName);
      if (dbEntry == null || !dbEntry.isFile) {
        throw Exception("Invalid Backup: '$kDbFileName' not found inside zip.");
      }

      String? activeProfileIdToRestore;
      List<dynamic> mediaEntries = [];
      final manifestEntry = archive.findFile('manifest.json');
      final currentSchemaVersion = db?.schemaVersion ?? 18;
      int? backedUpSchemaVersion;

      if (manifestEntry != null && manifestEntry.isFile) {
        final manifestContent = utf8.decode(
          manifestEntry.content as List<int>,
        );
        final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
        backedUpSchemaVersion = manifest['schemaVersion'] as int?;
        if (backedUpSchemaVersion != null) {
          if (backedUpSchemaVersion < kMinCompatibleSchemaVersion) {
            throw Exception(
              "Incompatible backup: schema version $backedUpSchemaVersion (minimum supported: $kMinCompatibleSchemaVersion)",
            );
          }
          if (backedUpSchemaVersion > currentSchemaVersion) {
            throw Exception(
              "Incompatible backup: backup was created with a newer app schema ($backedUpSchemaVersion vs current $currentSchemaVersion). Please update InvoBharat.",
            );
          }
        }
        activeProfileIdToRestore = manifest['activeProfileId'] as String?;
        mediaEntries = (manifest['mediaEntries'] as List<dynamic>?) ?? [];
      }

      final dbPath = await _getDbPath();
      final dbDestFile = File(dbPath);
      final tempRestoredDbPath = p.join(
        Directory.systemTemp.path,
        'invobharat_restore_${const Uuid().v4()}.sqlite',
      );
      final tempRestoredFile = File(tempRestoredDbPath);

      String? backupPath;
      try {
        // 1. Write to temp file and verify SQLite integrity
        final dbData = dbEntry.content as List<int>;
        await tempRestoredFile.writeAsBytes(dbData, flush: true);

        try {
          final testDb = sqlite3.sqlite3.open(tempRestoredDbPath);
          final check = testDb.select('PRAGMA integrity_check(1);');
          if (check.isEmpty || check.first.columnAt(0) != 'ok') {
            testDb.close();
            throw Exception("Database integrity check failed on backup file.");
          }
          if (backedUpSchemaVersion == null) {
            final uvRes = testDb.select('PRAGMA user_version;');
            if (uvRes.isNotEmpty && uvRes.first.isNotEmpty) {
              backedUpSchemaVersion = uvRes.first.columnAt(0) as int?;
            }
          }
          testDb.close();
        } catch (e) {
          throw Exception("Restored database integrity check failed: $e");
        }

        if (backedUpSchemaVersion != null) {
          if (backedUpSchemaVersion < kMinCompatibleSchemaVersion) {
            throw Exception(
              "Incompatible backup: schema version $backedUpSchemaVersion (minimum supported: $kMinCompatibleSchemaVersion)",
            );
          }
          if (backedUpSchemaVersion > currentSchemaVersion) {
            throw Exception(
              "Incompatible backup: backup was created with a newer app schema ($backedUpSchemaVersion vs current $currentSchemaVersion). Please update InvoBharat.",
            );
          }
        }

        // 2. Close active Drift database connection
        final currentDb = db;
        if (currentDb != null) {
          await currentDb.close();
          AppDatabase.resetInstance();
        }

        // 3. Backup live database file with timestamped multi-generation retention
        if (await dbDestFile.exists()) {
          final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          backupPath = '$dbPath.$ts.bak';
          await dbDestFile.copy(backupPath);
          await _pruneDbBackups(dbDestFile.parent, p.basename(dbPath));
        } else {
          await dbDestFile.parent.create(recursive: true);
        }

        // 4. Atomic move into destination
        try {
          if (await dbDestFile.exists()) {
            await dbDestFile.delete();
          }
          await tempRestoredFile.rename(dbPath);
        } catch (_) {
          await tempRestoredFile.copy(dbPath);
          await tempRestoredFile.delete();
        }

        final walFile = File('$dbPath-wal');
        final shmFile = File('$dbPath-shm');
        if (await walFile.exists()) await walFile.delete();
        if (await shmFile.exists()) await shmFile.delete();

        // 5. Extract Media files safely
        final docDir = await getApplicationDocumentsDirectory();
        final mediaDir = Directory(p.join(docDir.path, 'InvoBharat', 'media'));
        if (!await mediaDir.exists()) {
          await mediaDir.create(recursive: true);
        }

        for (final m in mediaEntries) {
          final String? zipPath = m['zipPath'];
          if (zipPath != null) {
            final mediaArchiveFile = archive.findFile(zipPath);
            if (mediaArchiveFile != null && mediaArchiveFile.isFile) {
              final safeFileName = SecurityUtils.sanitizeFilename(
                p.basename(zipPath),
              );
              final resolvedPath = SecurityUtils.safeResolve(
                p.join(mediaDir.path, safeFileName),
                mediaDir.path,
              );
              if (resolvedPath != null) {
                final targetFile = File(resolvedPath);
                await targetFile.writeAsBytes(
                  mediaArchiveFile.content as List<int>,
                  flush: true,
                );
              }
            }
          }
        }

        // 6. Rewrite media paths in restored database
        if (mediaEntries.isNotEmpty && await dbDestFile.exists()) {
          try {
            final rawDb = sqlite3.sqlite3.open(dbPath);
            for (final m in mediaEntries) {
              final profileId = m['profileId'] as String?;
              final type = m['type'] as String?;
              final zipPath = m['zipPath'] as String?;
              if (profileId != null && type != null && zipPath != null) {
                final safeFileName = SecurityUtils.sanitizeFilename(
                  p.basename(zipPath),
                );
                final resolvedPath = SecurityUtils.safeResolve(
                  p.join(mediaDir.path, safeFileName),
                  mediaDir.path,
                );
                if (resolvedPath != null) {
                  if (type == 'logo') {
                    rawDb.execute(
                      'UPDATE business_profiles SET logo_path = ? WHERE id = ?',
                      [resolvedPath, profileId],
                    );
                  } else if (type == 'signature') {
                    rawDb.execute(
                      'UPDATE business_profiles SET signature_path = ? WHERE id = ?',
                      [resolvedPath, profileId],
                    );
                  } else if (type == 'stamp') {
                    rawDb.execute(
                      'UPDATE business_profiles SET stamp_path = ? WHERE id = ?',
                      [resolvedPath, profileId],
                    );
                  }
                }
              }
            }
            rawDb.execute('PRAGMA wal_checkpoint(TRUNCATE);');
            rawDb.close();
          } catch (e, st) {
            LoggerService.talker.handle(e, st, "Media path rewrite error");
          }
        }

        if (activeProfileIdToRestore != null &&
            activeProfileIdToRestore.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'active_profile_id',
            activeProfileIdToRestore,
          );
        }

        if (ref != null) {
          ref!.invalidate(databaseProvider);
          try {
            ref!.read(databaseProvider);
          } catch (_) {}
        }

        return "Restore Successful. Database has been safely restored.";
      } catch (e, st) {
        if (await tempRestoredFile.exists()) {
          try {
            await tempRestoredFile.delete();
          } catch (_) {}
        }
        if (backupPath != null) {
          final backupFile = File(backupPath);
          if (await backupFile.exists()) {
            await backupFile.copy(dbPath);
          }
          final walFile = File('$dbPath-wal');
          final shmFile = File('$dbPath-shm');
          if (await walFile.exists()) await walFile.delete();
          if (await shmFile.exists()) await shmFile.delete();
        }
        LoggerService.talker.handle(
          e,
          st,
          "Database Restore Failed during write/media update",
        );
        rethrow;
      }
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Restore Error");
      throw Exception("Failed to restore backup: $e");
    }
  }
}
