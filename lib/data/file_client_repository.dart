import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/client.dart';
import 'client_repository.dart';

class FileClientRepository implements ClientRepository {
  final String profileId;

  FileClientRepository({required this.profileId});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/InvoBharat/profiles/$profileId/clients';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  @override
  Future<void> saveClient(Client client) async {
    final path = await _localPath;
    final fileName = 'client_${client.id}.json';
    final file = File('$path/$fileName');
    await file.writeAsString(jsonEncode(client.toJson()));
  }

  @override
  Future<Client?> getClient(String id) async {
    try {
      final path = await _localPath;
      final file = File('$path/client_$id.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        return Client.fromJson(jsonDecode(contents));
      }
      return null;
    } catch (e) {
      debugPrint("Error loading client $id: $e");
      return null;
    }
  }

  @override
  Future<void> deleteClient(String clientId) async {
    final path = await _localPath;
    final fileName = 'client_$clientId.json';
    final file = File('$path/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<Client>> getAllClients() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      List<Client> clients = [];

      if (!await dir.exists()) return [];

      final List<FileSystemEntity> files = dir.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final String contents = await file.readAsString();
            clients.add(Client.fromJson(jsonDecode(contents)));
          } catch (e) {
            debugPrint("Error parsing client file ${file.path}: $e");
          }
        }
      }

      // Sort by name alphabetically
      clients
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return clients;
    } catch (e) {
      debugPrint("Error loading clients: $e");
      return [];
    }
  }

  @override
  Future<void> deleteAll() async {
    final path = await _localPath;
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
