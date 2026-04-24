import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_form_provider.dart';
import 'package:invobharat/providers/client_provider.dart';

class MockClientListNotifier extends Notifier<List<Client>>
    with Mock
    implements ClientListNotifier {}

void main() {
  group('ClientFormNotifier', () {
    late ProviderContainer container;
    late MockClientListNotifier mockClientListNotifier;

    setUp(() {
      mockClientListNotifier = MockClientListNotifier();
      container = ProviderContainer(
        overrides: [
          clientListProvider.overrideWith(() => mockClientListNotifier),
        ],
      );
    });

    test('initial state should be empty', () {
      final state = container.read(clientFormProvider);
      expect(state.name, '');
      expect(state.isLoading, false);
    });

    test('updateName should update state', () {
      container.read(clientFormProvider.notifier).updateName('New Client');
      expect(container.read(clientFormProvider).name, 'New Client');
    });

    test('loadClient should populate form', () {
      final client = const Client(
        id: '1',
        name: 'Existing',
        address: 'Addr',
        gstin: 'GST',
        state: 'S',
        profileId: 'p1',
      );
      container.read(clientFormProvider.notifier).loadClient(client);

      final state = container.read(clientFormProvider);
      expect(state.id, '1');
      expect(state.name, 'Existing');
    });

    test('save should show error if name is empty', () async {
      final result = await container.read(clientFormProvider.notifier).save();
      expect(result, false);
      expect(
        container.read(clientFormProvider).errorMessage,
        contains('required'),
      );
    });

    test('save should call addClient for new client', () async {
      registerFallbackValue(const Client(id: '', name: '', profileId: ''));
      when(
        () => mockClientListNotifier.addClient(any()),
      ).thenAnswer((_) async => {});

      container.read(clientFormProvider.notifier).updateName('New');
      final result = await container.read(clientFormProvider.notifier).save();

      expect(result, true);
      verify(() => mockClientListNotifier.addClient(any())).called(1);
    });
  });
}
