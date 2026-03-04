import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:invobharat/models/recurring_profile.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/recurring_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecurringRepository', () {
    late RecurringRepository repository;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('recurring_test');
      final mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;
      when(
        () => mockPathProvider.getApplicationDocumentsPath(),
      ).thenAnswer((_) async => tempDir.path);

      repository = RecurringRepository();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final testProfile = RecurringProfile(
      id: 'rec-1',
      profileId: 'biz-1',
      interval: RecurringInterval.monthly,
      nextRunDate: DateTime(2024, 1, 1),
      isActive: true,
      baseInvoice: Invoice(
        id: 'tmpl-1',
        invoiceNo: '',
        invoiceDate: DateTime(2024, 1, 1),
        supplier: const Supplier(name: 'S', address: 'A', gstin: 'G'),
        receiver: const Receiver(name: 'R', address: 'A', gstin: 'G'),
        items: [],
      ),
    );

    test('saveProfile and getAllProfiles should work', () async {
      await repository.saveProfile(testProfile);

      final profiles = await repository.getAllProfiles('biz-1');
      expect(profiles.length, 1);
      expect(profiles.first.id, 'rec-1');
    });

    test('deleteProfile should remove file', () async {
      await repository.saveProfile(testProfile);
      await repository.deleteProfile('rec-1');

      final profiles = await repository.getAllProfiles('biz-1');
      expect(profiles.isEmpty, true);
    });
  });

  group('RecurringService', () {
    late MockInvoiceRepository mockInvoiceRepo;
    late ProviderContainer container;

    setUp(() {
      mockInvoiceRepo = MockInvoiceRepository();
      container = ProviderContainer(
        overrides: [
          invoiceRepositoryProvider.overrideWithValue(mockInvoiceRepo),
          // For NotifierProviders, we can use overrideWith and return a subclass that returns fixed state
          businessProfileListProvider.overrideWith(
            () => FakeBusinessProfileListNotifier([]),
          ),
          activeProfileIdProvider.overrideWith(
            () => FakeActiveProfileIdNotifier('biz-1'),
          ),
        ],
      );
    });

    test('calculateNextDate should work for intervals', () {
      final service = container.read(recurringServiceProvider);
      final start = DateTime(2024, 1, 1);

      expect(
        service.calculateNextDate(start, RecurringInterval.daily),
        DateTime(2024, 1, 2),
      );
      expect(
        service.calculateNextDate(start, RecurringInterval.weekly),
        DateTime(2024, 1, 8),
      );
      expect(
        service.calculateNextDate(start, RecurringInterval.monthly),
        DateTime(2024, 2, 1),
      );
      expect(
        service.calculateNextDate(start, RecurringInterval.yearly),
        DateTime(2025, 1, 1),
      );
    });
  });
}

class FakeBusinessProfileListNotifier extends BusinessProfileListNotifier {
  final List<BusinessProfile> initial;
  FakeBusinessProfileListNotifier(this.initial);
  @override
  List<BusinessProfile> build() => initial;
}

class FakeActiveProfileIdNotifier extends ActiveProfileIdNotifier {
  final String initial;
  FakeActiveProfileIdNotifier(this.initial);
  @override
  String build() => initial;
}
