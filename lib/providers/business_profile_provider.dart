import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile.dart';

class BusinessProfileNotifier extends Notifier<BusinessProfile> {
  @override
  BusinessProfile build() {
    _loadProfile();
    return BusinessProfile.defaults();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('business_profile');
    if (profileJson != null) {
      state = BusinessProfile.fromJson(jsonDecode(profileJson));
    }
  }

  Future<void> updateProfile(BusinessProfile newProfile) async {
    state = newProfile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('business_profile', jsonEncode(newProfile.toJson()));
  }

  Future<void> updateColor(int colorValue) async {
    final newProfile = state.copyWith(colorValue: colorValue);
    await updateProfile(newProfile);
  }
}

final businessProfileProvider =
    NotifierProvider<BusinessProfileNotifier, BusinessProfile>(
        BusinessProfileNotifier.new);
