import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:invobharat/models/recurring_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/invoice_series_provider.dart';

class RecurringService {
  final Ref ref;

  RecurringService(this.ref);

  Future<int> checkAndRun(final String businessProfileId) async {
    final repo = ref.read(invoiceRepositoryProvider);
    final profiles = await repo.getAllRecurringProfiles();
    int generatedCount = 0;

    for (var profile in profiles) {
      if (!profile.isActive) continue;

      if (DateTime.now().isAfter(profile.nextRunDate) ||
          DateTime.now().isAtSameMomentAs(profile.nextRunDate)) {
        try {
          await _generateInvoice(profile);
          generatedCount++;

          final nextDate = calculateNextDate(
            profile.nextRunDate,
            profile.interval,
          );
          final updatedProfile = profile.copyWith(
            lastRunDate: DateTime.now(),
            nextRunDate: nextDate,
          );
          await repo.saveRecurringProfile(updatedProfile);
        } catch (e) {
          debugPrint(
            "Failed to generate recurring invoice for profile ${profile.id}: $e",
          );
        }
      }
    }

    if (generatedCount > 0) {
      ref.invalidate(recurringListProvider);
      ref.invalidate(invoiceListProvider);
    }

    return generatedCount;
  }

  DateTime calculateNextDate(
    final DateTime current,
    final RecurringInterval interval,
  ) {
    switch (interval) {
      case RecurringInterval.daily:
        return current.add(const Duration(days: 1));
      case RecurringInterval.weekly:
        return current.add(const Duration(days: 7));
      case RecurringInterval.monthly:
        final next = DateTime(current.year, current.month + 1);
        final lastDayOfMonth = DateTime(next.year, next.month + 1, 0).day;
        return DateTime(
          next.year,
          next.month,
          current.day.clamp(1, lastDayOfMonth),
        );
      case RecurringInterval.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }

  Future<void> _generateInvoice(final RecurringProfile profile) async {
    final profiles = ref.read(businessProfileListProvider);
    final index = profiles.indexWhere((final p) => p.id == profile.profileId);
    if (index == -1) return;

    final businessProfile = profiles[index];
    final seriesList = ref.read(invoiceSeriesProvider);
    final defaultSeries = seriesList.isNotEmpty
        ? seriesList.first
        : InvoiceSeries(
            prefix: businessProfile.invoiceSeries,
            sequence: businessProfile.invoiceSequence,
          );
    final invoiceNo =
        "${defaultSeries.prefix}${defaultSeries.sequence.toString().padLeft(3, '0')}";

    final newInvoice = profile.baseInvoice.copyWith(
      id: const Uuid().v4(),
      profileId: profile.profileId,
      invoiceNo: invoiceNo,
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(
        Duration(days: profile.dueDays ?? 7),
      ),
      payments: [],
    );

    await ref.read(invoiceRepositoryProvider).saveInvoice(newInvoice);

    await ref
        .read(invoiceSeriesProvider.notifier)
        .incrementSequence(defaultSeries.prefix);
  }
}

final recurringServiceProvider = Provider((final ref) => RecurringService(ref));

final recurringListProvider =
    AsyncNotifierProvider<RecurringListNotifier, List<RecurringProfile>>(
      RecurringListNotifier.new,
    );

class RecurringListNotifier extends AsyncNotifier<List<RecurringProfile>> {
  @override
  Future<List<RecurringProfile>> build() async {
    final repo = ref.watch(invoiceRepositoryProvider);
    return await repo.getAllRecurringProfiles();
  }

  Future<void> addProfile(final RecurringProfile profile) async {
    final repo = ref.read(invoiceRepositoryProvider);
    await repo.saveRecurringProfile(profile);
    ref.invalidateSelf();
  }

  Future<void> deleteProfile(final String id) async {
    final repo = ref.read(invoiceRepositoryProvider);
    await repo.deleteRecurringProfile(id);
    ref.invalidateSelf();
  }

  Future<void> updateProfile(final RecurringProfile profile) async {
    final repo = ref.read(invoiceRepositoryProvider);
    await repo.saveRecurringProfile(profile);
    ref.invalidateSelf();
  }

  Future<void> runChecks() async {
    final profile = ref.read(businessProfileProvider);
    await ref.read(recurringServiceProvider).checkAndRun(profile.id);
  }
}
