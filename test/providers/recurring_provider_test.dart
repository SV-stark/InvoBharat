import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/providers/recurring_provider.dart';
import 'package:invobharat/models/recurring_profile.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:drift/native.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/database/database.dart'
    hide Invoice, BusinessProfile, Client;

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class FakeActiveProfileId extends ActiveProfileId {
  @override
  String build() => 'test-profile';
  @override
  Future<void> selectProfile(final String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInvoiceRepository mockRepo;
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
    mockRepo = MockInvoiceRepository();
    testProfile = BusinessProfile.defaults().copyWith(id: 'test-profile');

    when(() => mockRepo.getAllRecurringProfiles()).thenAnswer((_) async => []);
  });

  ProviderContainer createContainer({
    final List<dynamic> overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        invoiceRepositoryProvider.overrideWithValue(mockRepo),
        businessProfileProvider.overrideWithValue(testProfile),
        activeProfileIdProvider.overrideWith(FakeActiveProfileId.new),
        databaseProvider.overrideWith((final ref) {
          final db = AppDatabase(NativeDatabase.memory());
          ref.onDispose(db.close);
          return db;
        }),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('RecurringProvider', () {
    test('initial state should be empty', () async {
      final container = createContainer();
      final profiles = await container.read(recurringListProvider.future);
      expect(profiles, isEmpty);
    });

    test('addProfile should call saveRecurringProfile on repository', () async {
      final container = createContainer();
      final recProfile = RecurringProfile(
        id: 'rec1',
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

      when(
        () => mockRepo.saveRecurringProfile(any()),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockRepo.getAllRecurringProfiles(),
      ).thenAnswer((_) async => [recProfile]);

      await container
          .read(recurringListProvider.notifier)
          .addProfile(recProfile);
      verify(() => mockRepo.saveRecurringProfile(recProfile)).called(1);
    });
  });
}
