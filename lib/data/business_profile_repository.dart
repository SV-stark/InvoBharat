import 'package:invobharat/models/business_profile.dart';

abstract class BusinessProfileRepository {
  Future<void> saveProfile(final BusinessProfile profile);
  Future<List<BusinessProfile>> getAllProfiles();
  Future<void> deleteProfile(final String id);
  Future<BusinessProfile?> getProfile(final String id);
}
