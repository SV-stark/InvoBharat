import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/providers/recurring_provider.dart';
import 'package:invobharat/models/recurring_profile.dart';

void main() {
  group('RecurringService Date Calculation', () {
    late ProviderContainer container;
    late RecurringService service;

    setUp(() {
      container = ProviderContainer();
      service = container.read(recurringServiceProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('Daily interval adds 1 day', () {
      final date = DateTime(2023, 1, 1);
      final next = service.calculateNextDate(date, RecurringInterval.daily);
      expect(next, DateTime(2023, 1, 2));
    });

    test('Weekly interval adds 7 days', () {
      final date = DateTime(2023, 1, 1);
      final next = service.calculateNextDate(date, RecurringInterval.weekly);
      expect(next, DateTime(2023, 1, 8));
    });

    test('Monthly interval adds 1 month', () {
      final date = DateTime(2023, 1, 31);
      final next = service.calculateNextDate(date, RecurringInterval.monthly);
      expect(next.month, 2);
      expect(next.day, 28);
    });

    test('Monthly interval normal case', () {
      final date = DateTime(2023, 1, 15);
      final next = service.calculateNextDate(date, RecurringInterval.monthly);
      expect(next, DateTime(2023, 2, 15));
    });

    test('Yearly interval adds 1 year', () {
      final date = DateTime(2023, 5, 20);
      final next = service.calculateNextDate(date, RecurringInterval.yearly);
      expect(next, DateTime(2024, 5, 20));
    });
  });
}
