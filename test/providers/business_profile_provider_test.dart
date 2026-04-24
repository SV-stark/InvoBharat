import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/data/business_profile_repository.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';

class MockBusinessProfileRepository extends Mock
    implements BusinessProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(BusinessProfile.defaults());
  });

  group('BusinessProfile Providers', () {
    late MockBusinessProfileRepository mockRepository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockRepository = MockBusinessProfileRepository();
      when(() => mockRepository.getAllProfiles()).thenAnswer((_) async => []);
      when(() => mockRepository.saveProfile(any())).thenAnswer((_) async {});
    });

    test(
      'BusinessProfileListNotifier should load profiles from repository',
      () async {
        final profiles = [
          BusinessProfile.defaults().copyWith(
            id: 'p1',
            companyName: 'Company 1',
          ),
        ];
        when(
          () => mockRepository.getAllProfiles(),
        ).thenAnswer((_) async => profiles);

        final container = ProviderContainer(
          overrides: [
            businessProfileRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final sub = container.listen(businessProfileListProvider, (final prev, final next) {});
        addTearDown(sub.close);

        container.read(businessProfileListProvider);
        // Wait for the async _init to complete
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(businessProfileListProvider), profiles);
      },
    );

    test('ActiveProfileIdNotifier should load and select active ID', () async {
      SharedPreferences.setMockInitialValues({'active_profile_id': 'p1'});

      final container = ProviderContainer(
        overrides: [
          businessProfileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subList = container.listen(businessProfileListProvider, (final prev, final next) {});
      final sub = container.listen(activeProfileIdProvider, (final prev, final next) {});
      addTearDown(subList.close);
      addTearDown(sub.close);

      container.read(activeProfileIdProvider);
      // Wait for the async _loadActiveId to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(activeProfileIdProvider), 'p1');
    });

    test('BusinessProfileNotifierProxy should increment sequence', () async {
      final profile = BusinessProfile.defaults().copyWith(
        id: 'p1',
        invoiceSequence: 10,
      );
      SharedPreferences.setMockInitialValues({'active_profile_id': 'p1'});
      when(
        () => mockRepository.getAllProfiles(),
      ).thenAnswer((_) async => [profile]);
      when(() => mockRepository.saveProfile(any())).thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          businessProfileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subList = container.listen(businessProfileListProvider, (final prev, final next) {});
      final subActive = container.listen(activeProfileIdProvider, (final prev, final next) {});
      addTearDown(subList.close);
      addTearDown(subActive.close);

      container.read(businessProfileListProvider);
      container.read(activeProfileIdProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      final proxy = container.read(businessProfileListProvider.notifier);
      await proxy.incrementInvoiceSequence();

      verify(
        () => mockRepository.saveProfile(
          any(that: predicate<BusinessProfile>((final p) => p.invoiceSequence == 11)),
        ),
      ).called(1);
    });
  });
}
