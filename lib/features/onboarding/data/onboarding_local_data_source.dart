import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';

class OnboardingLocalDataSource {
  OnboardingLocalDataSource(this._profileData);

  final ProfileDataLocalDataSource _profileData;

  Future<void> saveProfile({
    required String profileId,
    required OnboardingProfile profile,
  }) async {
    await _profileData.writeOnboardingProfile(profileId, profile);
  }

  OnboardingProfile? readProfile(String profileId) {
    return _profileData.readOnboardingProfile(profileId);
  }

  Future<void> clearProfile(String profileId) async {
    await _profileData.clearOnboardingProfile(profileId);
  }
}

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return OnboardingLocalDataSource(profileData);
});
