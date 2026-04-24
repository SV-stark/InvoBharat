import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/providers/recurring_provider.dart';
import 'package:invobharat/models/recurring_profile.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/models/business_profile.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRecurringRepository mockRepo;
  late BusinessProfile testProfile;

  setUpAll(() {
    registerFallbackValue(
      RecurringProfile(
        id: '',
        profileId: '',
        interval: RecurringInterval.monthly,
        nextRunDate: DateTime.now(),
        baseInvoice: Invoice(
          invoiceDate: DateTime.now(),
          supplier: const Supplier(),
          receiver: const Receiver(),
          items: [],
        ),
      ),
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockRecurringRepository();
    testProfile = BusinessProfile.defaults().copyWith(id: 'test-profile');

    when(() => mockRepo.getAllProfiles(any())).thenAnswer((_) async => []);
  });

  ProviderContainer createContainer({
    final List<dynamic> overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        recurringRepositoryProvider.overrideWithValue(mockRepo),
        businessProfileProvider.overrideWithValue(testProfile),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('RecurringProvider', () {
    test('initial state should be empty', () async {
      final container = createContainer();
      final profiles = container.read(recurringListProvider);
      expect(profiles, const AsyncValue<List<RecurringProfile>>.loading());
      
      final data = await container.read(recurringListProvider.future);
      expect(data, isEmpty);
    });

    test('addProfile should update state', () async {
      final container = createContainer();
      final profile = RecurringProfile(
        id: 'p1',
        profileId: 'test-profile',
        interval: RecurringInterval.monthly,
        nextRunDate: DateTime.now(),
        baseInvoice: Invoice(
          invoiceDate: DateTime.now(),
          supplier: const Supplier(),
          receiver: const Receiver(),
          items: [],
        ),
      );

      when(() => mockRepo.saveProfile(any())).thenAnswer((_) async => Future.value());

      await container.read(recurringListProvider.notifier).addProfile(profile);
      final profiles = await container.read(recurringListProvider.future);

      expect(profiles, contains(profile));
      verify(() => mockRepo.saveProfile(profile)).called(1);
    });
  });
}
