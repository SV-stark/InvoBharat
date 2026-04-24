import 'dart:convert';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/data/business_profile_repository.dart';
import 'package:invobharat/data/sql_business_profile_repository.dart';
import 'package:invobharat/providers/database_provider.dart';

part 'business_profile_provider.g.dart';

@riverpod
BusinessProfileRepository businessProfileRepository(final Ref ref) {
  final db = ref.watch(databaseProvider);
  return SqlBusinessProfileRepository(db);
}

@riverpod
class BusinessProfileList extends _$BusinessProfileList {
  @override
  List<BusinessProfile> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final repository = ref.read(businessProfileRepositoryProvider);
    final profiles = await repository.getAllProfiles();

    if (profiles.isNotEmpty) {
      state = profiles;
    } else {
      await _handleMigrationOrFirstRun();
    }
  }

  Future<void> _handleMigrationOrFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = ref.read(businessProfileRepositoryProvider);

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
      await prefs.remove('business_profiles_list');
    } else {
      final String? legacyJson = prefs.getString('business_profile');
      if (legacyJson != null) {
        var legacyProfile = BusinessProfile.fromJson(jsonDecode(legacyJson));
        if (legacyProfile.id == 'default' || legacyProfile.id.isEmpty) {
          legacyProfile = legacyProfile.copyWith(id: const Uuid().v4());
        }
        await _migrateLegacyInvoices(legacyProfile.id);
        await repository.saveProfile(legacyProfile);
        state = [legacyProfile];
        await prefs.remove('business_profile');
      } else {
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
      final newPath = '${directory.path}/InvoBharat/profiles/$newProfileId/invoices';

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
      }
    } catch (_) {}
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

  Future<void> updateColor(final int color) async {
    final activeId = ref.read(activeProfileIdProvider);
    final current = state.firstWhere((final p) => p.id == activeId);
    await updateProfile(current.copyWith(colorValue: color));
  }

  Future<void> incrementInvoiceSequence() async {
    final activeId = ref.read(activeProfileIdProvider);
    final current = state.firstWhere((final p) => p.id == activeId);
    final newSeq = current.invoiceSequence + 1;
    final newProfile = current.copyWith(invoiceSequence: newSeq);
    await updateProfile(newProfile);
  }
}

@riverpod
class ActiveProfileId extends _$ActiveProfileId {
  @override
  String build() {
    _loadActiveId();
    return "";
  }

  Future<void> _loadActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('active_profile_id');

    if (storedId != null) {
      state = storedId;
    } else {
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
  }
}

@riverpod
BusinessProfile businessProfile(final Ref ref) {
  final profiles = ref.watch(businessProfileListProvider);
  final activeId = ref.watch(activeProfileIdProvider);

  if (profiles.isEmpty) return BusinessProfile.defaults();

  return profiles.firstWhere(
    (final p) => p.id == activeId,
    orElse: () => profiles.first,
  );
}
