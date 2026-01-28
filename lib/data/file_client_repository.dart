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
    final List<Client> clients = [];
    await for (final client in streamClients()) {
      clients.add(client);
    }
    clients
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return clients;
  }

  Stream<Client> streamClients() async* {
    try {
      final path = await _localPath;
      final dir = Directory(path);

      if (!await dir.exists()) return;

      int count = 0;
      await for (var file in dir.list(followLinks: false)) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final String contents = await file.readAsString();
            final client = Client.fromJson(jsonDecode(contents));
            yield client;
          } catch (e) {
            // skip
          }
          count++;
          if (count % 20 == 0) {
            await Future.delayed(const Duration(milliseconds: 1));
          }
        }
      }
    } catch (e) {
      debugPrint("Error streaming clients: $e");
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
