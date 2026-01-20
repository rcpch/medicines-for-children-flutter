// Local storage for onboarding data.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';

// Reads and writes onboarding profiles in local storage.
class OnboardingLocalDataSource {
  OnboardingLocalDataSource(this._profileData);

  final ProfileDataLocalDataSource _profileData;

  // Persists the onboarding profile for a given profile id.
  Future<void> saveProfile({
    required String profileId,
    required OnboardingProfile profile,
  }) async {
    await _profileData.writeOnboardingProfile(profileId, profile);
  }

  // Loads the onboarding profile for a given profile id, if any.
  OnboardingProfile? readProfile(String profileId) {
    return _profileData.readOnboardingProfile(profileId);
  }

  // Removes any onboarding profile for the given profile id.
  Future<void> clearProfile(String profileId) async {
    await _profileData.clearOnboardingProfile(profileId);
  }
}

// Provides onboarding local storage access via Riverpod.
final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((
  ref,
) {
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return OnboardingLocalDataSource(profileData);
});
