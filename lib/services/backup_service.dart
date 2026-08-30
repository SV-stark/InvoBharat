import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:invobharat/services/csv_export_service.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/services/logger_service.dart';
import 'package:invobharat/utils/security_utils.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

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

  BackupService({
    FilePickerWrapper? filePicker,
    CsvExportService? csvService,
    this.db,
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
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'InvoBharat', kDbFileName);
  }

  Future<String> exportFullBackup() async {
    try {
      String? outputFile = await _filePicker.saveFile(
        dialogTitle: 'Save Full Backup (ZIP)',
        fileName:
            'invobharat_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.zip',
        allowedExtensions: ['zip'],
        type: FileType.custom,
        bytes: Uint8List(0),
      );

      if (outputFile == null) return "Backup cancelled";

      if (!outputFile.toLowerCase().endsWith('.zip')) {
        outputFile = '$outputFile.zip';
      }

      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final tempDbPath = p.join(
        Directory.systemTemp.path,
        'invobharat_export_$timestamp.sqlite',
      );

      final List<File> tempFilesToClean = [];

      try {
        File dbFile;
        final currentDb = db;
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
        tempFilesToClean.add(File(tempDbPath));

        final prefs = await SharedPreferences.getInstance();
        final activeProfileId = prefs.getString('active_profile_id') ?? '';
        final schemaVersion = db?.schemaVersion ?? 13;

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

        final tempManifestPath = p.join(
          Directory.systemTemp.path,
          'invobharat_manifest_$timestamp.json',
        );
        final manifestFile = File(tempManifestPath);
        await manifestFile.writeAsString(
          jsonEncode({
            'schemaVersion': schemaVersion,
            'activeProfileId': activeProfileId,
            'exportTimestamp': timestamp,
            'mediaEntries': mediaEntries,
          }),
        );
        tempFilesToClean.add(manifestFile);

        final zipEncoder = ZipFileEncoder();
        zipEncoder.create(outputFile);
        await zipEncoder.addFile(dbFile, kDbFileName);
        await zipEncoder.addFile(manifestFile, 'manifest.json');

        for (final m in mediaEntries) {
          final mediaFile = File(m['originalPath']!);
          if (await mediaFile.exists()) {
            await zipEncoder.addFile(mediaFile, m['zipPath']!);
          }
        }

        await zipEncoder.close();
        return "Full Backup saved to $outputFile";
      } finally {
        for (final f in tempFilesToClean) {
          if (await f.exists()) {
            await f.delete();
          }
        }
      }
    } catch (e) {
      debugPrint("Full Backup Error: $e");
      throw Exception("Failed to create full backup: $e");
    }
  }

  Future<String> restoreFullBackup() async {
    try {
      final PlatformFile? file = await _filePicker.pickFile(
        dialogTitle: 'Select Full Backup (ZIP)',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (file != null && file.path != null) {
        final zipFile = File(file.path!);
        final bytes = await zipFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);

        final dbEntry = archive.findFile(kDbFileName);
        if (dbEntry == null) {
          throw Exception(
            "Invalid Backup: '$kDbFileName' not found inside zip.",
          );
        }

        String? activeProfileIdToRestore;
        List<dynamic> mediaEntries = [];
        final manifestEntry = archive.findFile('manifest.json');
        if (manifestEntry != null) {
          final manifestContent = utf8.decode(
            manifestEntry.content as List<int>,
          );
          final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
          final backedUpSchemaVersion = manifest['schemaVersion'] as int?;
          if (backedUpSchemaVersion != null &&
              backedUpSchemaVersion < kMinCompatibleSchemaVersion) {
            throw Exception(
              "Incompatible backup: schema version $backedUpSchemaVersion (minimum: $kMinCompatibleSchemaVersion)",
            );
          }
          activeProfileIdToRestore = manifest['activeProfileId'] as String?;
          mediaEntries = (manifest['mediaEntries'] as List<dynamic>?) ?? [];
        }

        final dbPath = await _getDbPath();
        final dbDestFile = File(dbPath);

        final currentDb = db;
        if (currentDb != null) {
          await currentDb.close();
          AppDatabase.resetInstance();
        }

        String? backupPath;
        if (await dbDestFile.exists()) {
          backupPath = '$dbPath.bak';
          await dbDestFile.copy(backupPath);
        } else {
          final dbFolder = await getApplicationDocumentsDirectory();
          await Directory(
            '${dbFolder.path}/InvoBharat',
          ).create(recursive: true);
        }

        try {
          if (dbEntry.isFile) {
            final data = dbEntry.content as List<int>;
            await dbDestFile.writeAsBytes(data, flush: true);

            final walFile = File('$dbPath-wal');
            final shmFile = File('$dbPath-shm');
            if (await walFile.exists()) await walFile.delete();
            if (await shmFile.exists()) await shmFile.delete();
          }

          final docDir = await getApplicationDocumentsDirectory();
          final mediaDir = Directory(
            p.join(docDir.path, 'InvoBharat', 'media'),
          );
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

          // Rewrite media paths in restored database
          if (mediaEntries.isNotEmpty && await dbDestFile.exists()) {
            try {
              final rawDb = sqlite3.sqlite3.open(dbPath);
              for (final m in mediaEntries) {
                final profileId = m['profileId'] as String?;
                final type = m['type'] as String?;
                final zipPath = m['zipPath'] as String?;
                if (profileId != null && type != null && zipPath != null) {
                  final fileName = p.basename(zipPath);
                  final localPath = p.join(mediaDir.path, fileName);
                  if (type == 'logo') {
                    rawDb.execute(
                      'UPDATE business_profiles SET logo_path = ? WHERE id = ?',
                      [localPath, profileId],
                    );
                  } else if (type == 'signature') {
                    rawDb.execute(
                      'UPDATE business_profiles SET signature_path = ? WHERE id = ?',
                      [localPath, profileId],
                    );
                  } else if (type == 'stamp') {
                    rawDb.execute(
                      'UPDATE business_profiles SET stamp_path = ? WHERE id = ?',
                      [localPath, profileId],
                    );
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

          return "Restore Successful. Please restart the app to apply changes.";
        } catch (e, st) {
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
      } else {
        return "Restore cancelled";
      }
    } catch (e, st) {
      LoggerService.talker.handle(e, st, "Restore Error");
      throw Exception("Failed to restore backup: $e");
    }
  }
}
