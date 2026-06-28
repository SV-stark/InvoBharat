import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';

import 'package:invobharat/services/csv_export_service.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/database/database.dart';

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
  }) {
    return FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName ?? '',
      allowedExtensions: allowedExtensions,
      type: type,
      bytes: bytes,
    );
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
  final AppDatabase? _db;

  BackupService({
    final FilePickerWrapper? filePicker,
    final CsvExportService? csvService,
    final AppDatabase? db,
  }) : _filePicker = filePicker ?? DefaultFilePickerWrapper(),
       _csvService = csvService ?? CsvExportService(),
       _db = db;

  Future<String> exportData(final SqlInvoiceRepository repository) async {
    try {
      // 1. Fetch Data
      final invoices = await repository.getAllInvoices();

      // 2. Generate CSV
      final csvString = await _csvService.generateInvoiceCsv(invoices);

      // 3. Save to file
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

      try {
        File dbFile;
        if (_db != null) {
          // Safe path: VACUUM INTO gives a consistent snapshot including WAL data
          await _db.vacuumInto(tempDbPath);
          dbFile = File(tempDbPath);
        } else {
          // Fallback: zip the raw file (legacy behaviour, WAL not guaranteed)
          final dbPath = await _getDbPath();
          dbFile = File(dbPath);
          if (!await dbFile.exists()) {
            throw Exception("Database file not found at $dbPath");
          }
        }

        final schemaVersion = _db?.schemaVersion ?? 10;
        final tempManifestPath = p.join(
          Directory.systemTemp.path,
          'invobharat_manifest_$timestamp.json',
        );
        final manifestFile = File(tempManifestPath);
        await manifestFile.writeAsString(jsonEncode({'schemaVersion': schemaVersion}));

        final zipEncoder = ZipFileEncoder();
        zipEncoder.create(outputFile);
        await zipEncoder.addFile(dbFile, kDbFileName);
        await zipEncoder.addFile(manifestFile, 'manifest.json');
        await zipEncoder.close();

        return "Full Backup saved to $outputFile";
      } finally {
        // Clean up the temp files if they were created
        final tempFile = File(tempDbPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        final tempManifestFile = File(p.join(
          Directory.systemTemp.path,
          'invobharat_manifest_$timestamp.json',
        ));
        if (await tempManifestFile.exists()) {
          await tempManifestFile.delete();
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

        final prefsEntry = archive.findFile('manifest.json');
        if (prefsEntry != null) {
          final manifestContent = String.fromCharCodes(
            prefsEntry.content as List<int>,
          );
          final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
          final backedUpSchemaVersion = manifest['schemaVersion'] as int?;
          if (backedUpSchemaVersion != null &&
              backedUpSchemaVersion < kMinCompatibleSchemaVersion) {
            throw Exception(
              "Incompatible backup: schema version $backedUpSchemaVersion (minimum: $kMinCompatibleSchemaVersion)",
            );
          }
        }

        final dbPath = await _getDbPath();
        final dbDestFile = File(dbPath);

        if (_db != null) {
          await _db.close();
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

            // Delete stale WAL and SHM files to prevent the database engine
            // from replaying an old log over the freshly restored file.
            final walFile = File('$dbPath-wal');
            final shmFile = File('$dbPath-shm');
            if (await walFile.exists()) await walFile.delete();
            if (await shmFile.exists()) await shmFile.delete();
          }
          return "Restore Successful. Please restart the app to apply changes.";
        } catch (e) {
          if (backupPath != null) {
            final backupFile = File(backupPath);
            if (await backupFile.exists()) {
              await backupFile.copy(dbPath);
            }
          }
          rethrow;
        }
      } else {
        return "Restore cancelled";
      }
    } catch (e) {
      debugPrint("Restore Error: $e");
      throw Exception("Failed to restore backup: $e");
    }
  }
}
