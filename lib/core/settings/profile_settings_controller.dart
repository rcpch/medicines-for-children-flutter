// Controller for profile-specific settings.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings {
  const ProfileSettings({this.biometricsEnabled = false});

  final bool biometricsEnabled;

  ProfileSettings copyWith({bool? biometricsEnabled}) {
    return ProfileSettings(
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}

class ProfileSettingsController extends StateNotifier<ProfileSettings> {
  ProfileSettingsController(this._prefs, this._profileId)
    : super(
        ProfileSettings(
          biometricsEnabled: _prefs.getBool(_keyFor(_profileId)) ?? false,
        ),
      );

  final SharedPreferences _prefs;
  final String _profileId;

  Future<void> setBiometricsEnabled(bool enabled) async {
    state = state.copyWith(biometricsEnabled: enabled);
    await _prefs.setBool(_keyFor(_profileId), enabled);
  }

  static String _keyFor(String profileId) {
    return 'profile.settings.biometrics.$profileId';
  }
}

final profileSettingsControllerProvider =
    StateNotifierProvider.family<
      ProfileSettingsController,
      ProfileSettings,
      String
    >((ref, profileId) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ProfileSettingsController(prefs, profileId);
    });
