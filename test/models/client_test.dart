import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/models/client.dart';

void main() {
  group('Client', () {
    test('should create a Client with required fields', () {
      const client = Client(id: 'c1', name: 'John Doe');

      expect(client.id, 'c1');
      expect(client.name, 'John Doe');
      expect(client.profileId, 'default');
      expect(client.gstin, '');
      expect(client.address, '');
    });

    test('toJson() should return a valid map', () {
      const client = Client(
        id: 'c1',
        name: 'John Doe',
        gstin: '29ABCDE1234F1Z5',
      );

      final json = client.toJson();

      expect(json['id'], 'c1');
      expect(json['name'], 'John Doe');
      expect(json['gstin'], '29ABCDE1234F1Z5');
    });

    test('fromJson() should create a client from a valid map', () {
      final json = {'id': 'c1', 'name': 'John Doe', 'gstin': '29ABCDE1234F1Z5'};

      final client = Client.fromJson(json);

      expect(client.id, 'c1');
      expect(client.name, 'John Doe');
      expect(client.gstin, '29ABCDE1234F1Z5');
    });

    test('copyWith() should return a new instance with updated fields', () {
      const client = Client(id: 'c1', name: 'John Doe');
      final updatedClient = client.copyWith(name: 'Jane Doe');

      expect(updatedClient.name, 'Jane Doe');
      expect(updatedClient.id, 'c1');
    });
  });
}
