import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/database/database.dart' hide BusinessProfile;
import 'package:drift/native.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/providers/invoice_series_provider.dart';

void main() {
  group('invoiceSeriesProvider', () {
    late AppDatabase db;
    late AppSettingsService settingsService;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      settingsService = AppSettingsService(db);
      final profile = BusinessProfile.defaults().copyWith(
        id: 'test-prof-1',
        invoiceSeries: 'INV/',
        invoiceSequence: 1,
      );

      container = ProviderContainer(
        overrides: [
          appSettingsServiceProvider.overrideWithValue(settingsService),
          businessProfileProvider.overrideWithValue(profile),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('addSeries and incrementSequence manages multiple prefixes', () async {
      // Trigger initial load
      container.read(invoiceSeriesProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(invoiceSeriesProvider.notifier);
      await notifier.addSeries('TAX/', 10);

      var state = container.read(invoiceSeriesProvider);
      expect(state.any((s) => s.prefix == 'TAX/' && s.sequence == 10), isTrue);

      await notifier.incrementSequence('TAX/');
      state = container.read(invoiceSeriesProvider);
      final taxSeries = state.firstWhere((s) => s.prefix == 'TAX/');
      expect(taxSeries.sequence, 11);

      await notifier.removeSeries('TAX/');
      state = container.read(invoiceSeriesProvider);
      expect(state.any((s) => s.prefix == 'TAX/'), isFalse);
    });
  });
}
