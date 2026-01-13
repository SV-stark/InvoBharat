import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/recurring_profile.dart';
import 'business_profile_provider.dart';
import 'invoice_repository_provider.dart';

class RecurringRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/InvoBharat/recurring';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> saveProfile(RecurringProfile profile) async {
    final path = await _localPath;
    final file = File('$path/rec_${profile.id}.json');
    await file.writeAsString(jsonEncode(profile.toJson()));
  }

  Future<void> deleteProfile(String id) async {
    final path = await _localPath;
    final file = File('$path/rec_$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteAll() async {
    final path = await _localPath;
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<List<RecurringProfile>> getAllProfiles(
      String businessProfileId) async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      List<RecurringProfile> profiles = [];
      if (!await dir.exists()) return [];

      final files = dir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final p = RecurringProfile.fromJson(jsonDecode(content));
            if (p.profileId == businessProfileId) {
              profiles.add(p);
            }
          } catch (e) {
            debugPrint("Error parsing recurring profile: $e");
          }
        }
      }
      return profiles;
    } catch (e) {
      return [];
    }
  }
}

final recurringRepositoryProvider = Provider((ref) => RecurringRepository());

class RecurringService {
  final Ref ref;

  RecurringService(this.ref);

  Future<int> checkAndRun(String businessProfileId) async {
    final repo = ref.read(recurringRepositoryProvider);
    final profiles = await repo.getAllProfiles(businessProfileId);
    int generatedCount = 0;

    for (var profile in profiles) {
      if (!profile.isActive) continue;

      if (DateTime.now().isAfter(profile.nextRunDate) ||
          DateTime.now().isAtSameMomentAs(profile.nextRunDate)) {
        // Time to generate!
        await _generateInvoice(profile);
        generatedCount++;

        // Update profile
        final nextDate =
            calculateNextDate(profile.nextRunDate, profile.interval);
        final updatedProfile = profile.copyWith(
          lastRunDate: DateTime.now(),
          nextRunDate: nextDate,
        );
        await repo.saveProfile(updatedProfile);
      }
    }

    if (generatedCount > 0) {
      // Refresh lists if needed
      ref.invalidate(recurringListProvider);
      ref.invalidate(invoiceListProvider);
    }

    return generatedCount;
  }

  DateTime calculateNextDate(DateTime current, RecurringInterval interval) {
    switch (interval) {
      case RecurringInterval.daily:
        return current.add(const Duration(days: 1));
      case RecurringInterval.weekly:
        return current.add(const Duration(days: 7));
      case RecurringInterval.monthly:
        var next = DateTime(current.year, current.month + 1, 1);
        final lastDayOfMonth = DateTime(next.year, next.month + 1, 0).day;
        return DateTime(
            next.year, next.month, current.day.clamp(1, lastDayOfMonth));
      case RecurringInterval.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }

  Future<void> _generateInvoice(RecurringProfile profile) async {
    // Get Business Profile for sequence
    // Use read, but we might be in background? We should be careful.
    // We assume this runs in foreground.
    final businessProfileNotifier =
        ref.read(businessProfileListProvider.notifier);
    // getting active profile from provider might be tricky if we are passing specific ID.
    // Ideally we fetch the specific profile.

    // Logic hack: we can't easily get 'sequence' for arbitrary profile ID without loading it.
    // For now, let's assume we run this for the active profile primarily.
    // If not active, we might desync sequence?
    // Let's rely on BusinessProfileProvider to handle sequence increment.

    // We need to fetch the specific business profile first to get series/sequence.
    // Since BusinessProfileProvider manages list, we can find it.
    final profiles = ref.read(businessProfileListProvider);
    final index = profiles.indexWhere((p) => p.id == profile.profileId);
    if (index == -1) return; // Profile not found

    var businessProfile = profiles[index];

    final invoiceNo =
        "${businessProfile.invoiceSeries}${businessProfile.invoiceSequence}";

    // Create Invoice
    final newInvoice = profile.baseInvoice.copyWith(
      id: const Uuid().v4(),
      invoiceNo: invoiceNo,
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(Duration(
          days: profile.dueDays ?? 7)), // Use profile setting or default 7 days
      payments: [], // Empty payments
    );

    // Save Invoice
    await ref.read(invoiceRepositoryProvider).saveInvoice(newInvoice);

    // Increment Sequence
    final updatedBusinessProfile = businessProfile.copyWith(
        invoiceSequence: businessProfile.invoiceSequence + 1);
    await businessProfileNotifier.updateProfile(updatedBusinessProfile);
  }
}

final recurringServiceProvider = Provider((ref) => RecurringService(ref));

final recurringListProvider =
    AsyncNotifierProvider<RecurringListNotifier, List<RecurringProfile>>(
        RecurringListNotifier.new);

class RecurringListNotifier extends AsyncNotifier<List<RecurringProfile>> {
  @override
  Future<List<RecurringProfile>> build() async {
    final activeId = ref.watch(activeProfileIdProvider);
    if (activeId.isEmpty) return [];
    return ref.read(recurringRepositoryProvider).getAllProfiles(activeId);
  }

  Future<void> addProfile(RecurringProfile profile) async {
    await ref.read(recurringRepositoryProvider).saveProfile(profile);
    ref.invalidateSelf();
  }

  Future<void> deleteProfile(String id) async {
    await ref.read(recurringRepositoryProvider).deleteProfile(id);
    ref.invalidateSelf();
  }

  Future<void> updateProfile(RecurringProfile profile) async {
    await ref.read(recurringRepositoryProvider).saveProfile(profile);
    ref.invalidateSelf();
  }

  Future<void> runChecks() async {
    final activeId = ref.read(activeProfileIdProvider);
    if (activeId.isNotEmpty) {
      await ref.read(recurringServiceProvider).checkAndRun(activeId);
    }
  }
}
