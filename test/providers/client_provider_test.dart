import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:invobharat/data/client_repository.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Client(id: 'fallback', name: 'fallback'));
  });

  group('ClientListNotifier', () {
    late MockClientRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockClientRepository();
      container = ProviderContainer(
        overrides: [clientRepositoryProvider.overrideWithValue(mockRepository)],
      );

      // Setup default mock responses
      when(() => mockRepository.getAllClients()).thenAnswer((_) async => []);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should load clients from repository', () async {
      final clients = [
        const Client(id: '1', name: 'Client 1'),
        const Client(id: '2', name: 'Client 2'),
      ];
      when(
        () => mockRepository.getAllClients(),
      ).thenAnswer((_) async => clients);

      // Access the provider to trigger build()
      container.read(clientListProvider);

      // Give it a moment to finish async _loadClients
      await Future.delayed(Duration.zero);

      expect(container.read(clientListProvider), clients);
    });

    test('addClient should save to repository and reload', () async {
      final client = const Client(id: '', name: 'New Client');
      final savedClient = const Client(id: 'generated-id', name: 'New Client');

      when(() => mockRepository.saveClient(any())).thenAnswer((_) async => {});
      when(
        () => mockRepository.getAllClients(),
      ).thenAnswer((_) async => [savedClient]);

      await container.read(clientListProvider.notifier).addClient(client);

      verify(() => mockRepository.saveClient(any())).called(1);
      expect(container.read(clientListProvider).length, 1);
      expect(container.read(clientListProvider).first.name, 'New Client');
    });

    test('deleteClient should remove from repository and reload', () async {
      when(
        () => mockRepository.deleteClient(any()),
      ).thenAnswer((_) async => {});
      when(() => mockRepository.getAllClients()).thenAnswer((_) async => []);

      await container.read(clientListProvider.notifier).deleteClient('123');

      verify(() => mockRepository.deleteClient('123')).called(1);
      expect(container.read(clientListProvider), isEmpty);
    });
  });
}
