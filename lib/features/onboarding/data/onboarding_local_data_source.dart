import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingProfileKey = 'onboarding.profile';

class OnboardingLocalDataSource {
  OnboardingLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  Future<void> saveProfile(OnboardingProfile profile) async {
    await _preferences.setString(_onboardingProfileKey, profile.toJson());
  }

  OnboardingProfile? readProfile() {
    final raw = _preferences.getString(_onboardingProfileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return OnboardingProfile.fromJson(raw);
  }

  Future<void> clearProfile() async {
    await _preferences.remove(_onboardingProfileKey);
  }
}

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return OnboardingLocalDataSource(preferences);
});
