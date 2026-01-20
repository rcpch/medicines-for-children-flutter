// Controller for profile-specific settings.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores settings that are scoped to a single profile.
class ProfileSettings {
  const ProfileSettings({this.biometricsEnabled = false});

  final bool biometricsEnabled;

  /// Returns a copy with updated profile setting values.
  ProfileSettings copyWith({bool? biometricsEnabled}) {
    return ProfileSettings(
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}

/// Manages persisted settings for a specific profile.
class ProfileSettingsController extends Notifier<ProfileSettings> {
  ProfileSettingsController(this._profileId);

  final String _profileId;
  late SharedPreferences _prefs;

  /// Loads profile settings from shared preferences.
  @override
  ProfileSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return ProfileSettings(
      biometricsEnabled: _prefs.getBool(_keyFor(_profileId)) ?? false,
    );
  }

  /// Enables or disables biometrics for the profile.
  Future<void> setBiometricsEnabled(bool enabled) async {
    state = state.copyWith(biometricsEnabled: enabled);
    await _prefs.setBool(_keyFor(_profileId), enabled);
  }

  /// Builds the shared preferences key for the profile.
  static String _keyFor(String profileId) {
    return 'profile.settings.biometrics.$profileId';
  }
}

/// Provides a profile settings controller for a given profile id.
final profileSettingsControllerProvider =
    NotifierProvider.family<ProfileSettingsController, ProfileSettings, String>(
      ProfileSettingsController.new,
    );
