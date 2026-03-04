import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:invobharat/models/estimate.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/estimate_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EstimateRepository', () {
    late EstimateRepository repository;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('estimate_test');
      final mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;
      when(
        () => mockPathProvider.getApplicationDocumentsPath(),
      ).thenAnswer((_) async => tempDir.path);

      repository = EstimateRepository(profileId: 'biz-1');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final testEstimate = Estimate(
      id: 'est-1',
      estimateNo: 'EST-001',
      date: DateTime(2024, 1, 1),
      expiryDate: DateTime(2024, 1, 10),
      supplier: const Supplier(name: 'S', address: 'A', gstin: 'G'),
      receiver: const Receiver(name: 'R', address: 'A', gstin: 'G'),
      items: [],
      status: 'Draft',
    );

    test('saveEstimate and getAllEstimates should work', () async {
      await repository.saveEstimate(testEstimate);

      final estimates = await repository.getAllEstimates();
      expect(estimates.length, 1);
      expect(estimates.first.estimateNo, 'EST-001');
    });

    test('deleteEstimate should remove file', () async {
      await repository.saveEstimate(testEstimate);
      await repository.deleteEstimate('est-1');

      final estimates = await repository.getAllEstimates();
      expect(estimates.isEmpty, true);
    });
  });

  group('EstimateListNotifier', () {
    late ProviderContainer container;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('estimate_notifier_test');
      final mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;
      when(
        () => mockPathProvider.getApplicationDocumentsPath(),
      ).thenAnswer((_) async => tempDir.path);

      container = ProviderContainer(
        overrides: [
          activeProfileIdProvider.overrideWith(
            () => FakeActiveProfileIdNotifier('biz-1'),
          ),
        ],
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initial state should be empty then load', () async {
      final state = await container.read(estimateListProvider.future);
      expect(state, isEmpty);
    });
  });
}

class FakeActiveProfileIdNotifier extends ActiveProfileIdNotifier {
  final String initial;
  FakeActiveProfileIdNotifier(this.initial);
  @override
  String build() => initial;
}
