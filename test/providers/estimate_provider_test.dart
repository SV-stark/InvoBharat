import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/providers/estimate_provider.dart';
import 'package:invobharat/models/estimate.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/models/business_profile.dart';

class MockEstimateRepository extends Mock implements EstimateRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockEstimateRepository mockRepo;
  late BusinessProfile testProfile;

  setUpAll(() {
    registerFallbackValue(
      Estimate(
        id: '',
        date: DateTime.now(),
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [],
      ),
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockEstimateRepository();
    testProfile = BusinessProfile.defaults().copyWith(id: 'test-profile');

    when(() => mockRepo.getAllEstimates()).thenAnswer((_) async => []);
  });

  ProviderContainer createContainer({
    final List<dynamic> overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        estimateRepositoryProvider.overrideWithValue(mockRepo),
        businessProfileProvider.overrideWithValue(testProfile),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('EstimateProvider', () {
    test('initial state should be empty', () async {
      final container = createContainer();
      final estimates = await container.read(estimateListProvider.future);
      expect(estimates, isEmpty);
    });

    test('addEstimate should update state', () async {
      final container = createContainer();
      final estimate = Estimate(
        id: 'est1',
        estimateNo: 'EST-001',
        date: DateTime.now(),
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [],
      );

      when(() => mockRepo.saveEstimate(any())).thenAnswer((_) async => Future.value());

      await container.read(estimateListProvider.notifier).saveEstimate(estimate);
      final estimates = await container.read(estimateListProvider.future);

      expect(estimates, contains(estimate));
      verify(() => mockRepo.saveEstimate(estimate)).called(1);
    });

    test('deleteEstimate should remove from state', () async {
      final estimate = Estimate(
        id: 'est1',
        estimateNo: 'EST-001',
        date: DateTime.now(),
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [],
      );

      when(() => mockRepo.getAllEstimates()).thenAnswer((_) async => [estimate]);
      when(() => mockRepo.deleteEstimate(any())).thenAnswer((_) async => Future.value());

      final container = createContainer();
      
      await container.read(estimateListProvider.notifier).deleteEstimate('est1');
      final estimates = await container.read(estimateListProvider.future);

      expect(estimates, isEmpty);
      verify(() => mockRepo.deleteEstimate('est1')).called(1);
    });
  });
}
