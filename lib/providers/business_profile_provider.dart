import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../models/business_profile.dart';

// --- Providers ---

final businessProfileListProvider =
    NotifierProvider<BusinessProfileListNotifier, List<BusinessProfile>>(
        BusinessProfileListNotifier.new);

final activeProfileIdProvider =
    NotifierProvider<ActiveProfileIdNotifier, String>(
        ActiveProfileIdNotifier.new);

final businessProfileProvider = Provider<BusinessProfile>((ref) {
  final profiles = ref.watch(businessProfileListProvider);
  final activeId = ref.watch(activeProfileIdProvider);

  if (profiles.isEmpty) return BusinessProfile.defaults();

  return profiles.firstWhere((p) => p.id == activeId,
      orElse: () => profiles.first);
});

// --- Notifiers ---

class BusinessProfileListNotifier extends Notifier<List<BusinessProfile>> {
  @override
  List<BusinessProfile> build() {
    _loadProfiles();
    return [BusinessProfile.defaults()];
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();

    // Check for new multi-profile format
    final List<String>? profilesJson =
        prefs.getStringList('business_profiles_list');

    if (profilesJson != null && profilesJson.isNotEmpty) {
      final profiles = profilesJson
          .map((e) => BusinessProfile.fromJson(jsonDecode(e)))
          .toList();
      state = profiles;
    } else {
      // Check for legacy single profile
      // If legacy profile exists, migrate it.
      final String? legacyJson = prefs.getString('business_profile');
      if (legacyJson != null) {
        // MIGRATION LOGIC
        final legacyProfile = BusinessProfile.fromJson(jsonDecode(legacyJson));

        // Ensure it has an ID
        if (legacyProfile.id == 'default' || legacyProfile.id.isEmpty) {
          legacyProfile.id = const Uuid().v4();
        }

        // Move invoices
        await _migrateLegacyInvoices(legacyProfile.id);

        state = [legacyProfile];
        await _saveProfiles();

        // Clean up legacy
        // await prefs.remove('business_profile'); // Optional: keep for safety?
      } else {
        // First run ever
        final String newId = const Uuid().v4();
        final defaultProfile = BusinessProfile.defaults().copyWith(id: newId);
        state = [defaultProfile];
        await _saveProfiles();
      }
    }
  }

  Future<void> _migrateLegacyInvoices(String newProfileId) async {
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

  Future<void> addProfile(BusinessProfile profile) async {
    state = [...state, profile];
    await _saveProfiles();
  }

  Future<void> updateProfile(BusinessProfile updatedProfile) async {
    state = [
      for (final profile in state)
        if (profile.id == updatedProfile.id) updatedProfile else profile
    ];
    await _saveProfiles();
  }

  Future<void> deleteProfile(String id) async {
    if (state.length <= 1) return; // Cannot delete last profile
    state = state.where((p) => p.id != id).toList();
    await _saveProfiles();
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> profilesJson =
        state.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('business_profiles_list', profilesJson);
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

  Future<void> selectProfile(String id) async {
    state = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_profile_id', id);
  }
}

// Helper access for updating currently active profile
final businessProfileNotifierProvider = Provider((ref) {
  return BusinessProfileNotifierProxy(ref);
});

class BusinessProfileNotifierProxy {
  final Ref ref;
  BusinessProfileNotifierProxy(this.ref);

  Future<void> updateProfile(BusinessProfile p) async {
    await ref.read(businessProfileListProvider.notifier).updateProfile(p);
  }

  Future<void> updateColor(int color) async {
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
