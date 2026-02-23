import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/data/business_profile_repository.dart';
import 'package:invobharat/data/sql_business_profile_repository.dart';
import 'package:invobharat/providers/database_provider.dart';

// --- Providers ---

final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>((
  final ref,
) {
  final db = ref.watch(databaseProvider);
  return SqlBusinessProfileRepository(db);
});

final businessProfileListProvider =
    NotifierProvider<BusinessProfileListNotifier, List<BusinessProfile>>(
      BusinessProfileListNotifier.new,
    );

final activeProfileIdProvider =
    NotifierProvider<ActiveProfileIdNotifier, String>(
      ActiveProfileIdNotifier.new,
    );

final businessProfileProvider = Provider<BusinessProfile>((final ref) {
  final profiles = ref.watch(businessProfileListProvider);
  final activeId = ref.watch(activeProfileIdProvider);

  if (profiles.isEmpty) return BusinessProfile.defaults();

  return profiles.firstWhere(
    (final p) => p.id == activeId,
    orElse: () => profiles.first,
  );
});

// --- Notifiers ---

class BusinessProfileListNotifier extends Notifier<List<BusinessProfile>> {
  @override
  List<BusinessProfile> build() {
    _init();
    return []; // Start empty, async _init will populate
  }

  Future<void> _init() async {
    final repository = ref.read(businessProfileRepositoryProvider);
    final profiles = await repository.getAllProfiles();

    if (profiles.isNotEmpty) {
      state = profiles;
    } else {
      // Check for migration or first run
      await _handleMigrationOrFirstRun();
    }
  }

  Future<void> _handleMigrationOrFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = ref.read(businessProfileRepositoryProvider);

    // 1. Check for legacy SharedPreferences multi-profile format
    final List<String>? profilesJson = prefs.getStringList(
      'business_profiles_list',
    );

    if (profilesJson != null && profilesJson.isNotEmpty) {
      final profiles = profilesJson
          .map((final e) => BusinessProfile.fromJson(jsonDecode(e)))
          .toList();

      for (final profile in profiles) {
        await repository.saveProfile(profile);
      }
      state = profiles;
      // Clear legacy storage
      await prefs.remove('business_profiles_list');
    } else {
      // 2. Check for legacy single profile (even older)
      final String? legacyJson = prefs.getString('business_profile');
      if (legacyJson != null) {
        final legacyProfile = BusinessProfile.fromJson(jsonDecode(legacyJson));
        if (legacyProfile.id == 'default' || legacyProfile.id.isEmpty) {
          legacyProfile.id = const Uuid().v4();
        }
        // Move invoices if they were in old flat format
        await _migrateLegacyInvoices(legacyProfile.id);

        await repository.saveProfile(legacyProfile);
        state = [legacyProfile];
        await prefs.remove('business_profile');
      } else {
        // 3. First run ever
        final String newId = const Uuid().v4();
        final defaultProfile = BusinessProfile.defaults().copyWith(id: newId);
        await repository.saveProfile(defaultProfile);
        state = [defaultProfile];
      }
    }
  }

  Future<void> _migrateLegacyInvoices(final String newProfileId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final oldPath = '${directory.path}/InvoBharat/invoices';
      final newPath =
          '${directory.path}/InvoBharat/profiles/$newProfileId/invoices';

      final oldDir = Directory(oldPath);
      if (await oldDir.exists()) {
        final newDir = Directory(newPath);
        if (!await newDir.exists()) {
          await newDir.create(recursive: true);
        }

        final files = oldDir.listSync();
        for (var file in files) {
          if (file is File && file.path.endsWith('.json')) {
            final filename = file.uri.pathSegments.last;
            await file.rename('${newDir.path}/$filename');
          }
        }
        debugPrint("Migrated invoices to profile $newProfileId");
      }
    } catch (e) {
      debugPrint("Migration Error: $e");
    }
  }

  Future<void> addProfile(final BusinessProfile profile) async {
    final repository = ref.read(businessProfileRepositoryProvider);
    await repository.saveProfile(profile);
    state = [...state, profile];
  }

  Future<void> updateProfile(final BusinessProfile updatedProfile) async {
    final repository = ref.read(businessProfileRepositoryProvider);
    await repository.saveProfile(updatedProfile);
    state = [
      for (final profile in state)
        if (profile.id == updatedProfile.id) updatedProfile else profile,
    ];
  }

  Future<void> deleteProfile(final String id) async {
    if (state.length <= 1) return;
    final repository = ref.read(businessProfileRepositoryProvider);
    await repository.deleteProfile(id);
    state = state.where((final p) => p.id != id).toList();
  }
}

class ActiveProfileIdNotifier extends Notifier<String> {
  @override
  String build() {
    _loadActiveId();
    return ""; // Will update on load
  }

  Future<void> _loadActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('active_profile_id');

    if (storedId != null) {
      state = storedId;
    } else {
      // Wait for list to load effectively
      // We can just rely on the provider reading the list to default to first
      // But let's check list provider:
      final profiles = ref.read(businessProfileListProvider);
      if (profiles.isNotEmpty) {
        state = profiles.first.id;
        await selectProfile(state);
      }
    }
  }

  Future<void> selectProfile(final String id) async {
    state = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_profile_id', id);

    // Refresh dependent providers
    // We can't directly read other providers here easily without a Ref in the method or passing it in.
    // However, since `clientRepositoryProvider` watches `businessProfileProvider`,
    // and `businessProfileProvider` watches `activeProfileIdProvider`,
    // the repository will automatically rebuild with the new profileId.
    // The `clientListNotifier` needs to be told to reload though, OR it should watch the repository properly.
    // But `ClientListNotifier` does `ref.read(clientRepositoryProvider)` in `_loadClients`.
    // Let's make `ClientListNotifier` watch the repository or profile change.
    // Actually, simply watching the profile in the provider definition is enough for the Repo,
    // but the ListNotifier state needs to restart.
  }
}

// Helper access for updating currently active profile
final businessProfileNotifierProvider = Provider((final ref) {
  return BusinessProfileNotifierProxy(ref);
});

class BusinessProfileNotifierProxy {
  final Ref ref;
  BusinessProfileNotifierProxy(this.ref);

  Future<void> updateProfile(final BusinessProfile p) async {
    await ref.read(businessProfileListProvider.notifier).updateProfile(p);
  }

  Future<void> updateColor(final int color) async {
    final current = ref.read(businessProfileProvider);
    await updateProfile(current.copyWith(colorValue: color));
  }

  Future<void> incrementInvoiceSequence() async {
    final current = ref.read(businessProfileProvider);
    final newSeq = current.invoiceSequence + 1;
    final newProfile = current.copyWith(invoiceSequence: newSeq);
    await updateProfile(newProfile);
  }
}
