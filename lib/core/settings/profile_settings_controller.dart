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

class ProfileSettingsController extends Notifier<ProfileSettings> {
  ProfileSettingsController(this._profileId);

  final String _profileId;
  late SharedPreferences _prefs;

  @override
  ProfileSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return ProfileSettings(
      biometricsEnabled: _prefs.getBool(_keyFor(_profileId)) ?? false,
    );
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    state = state.copyWith(biometricsEnabled: enabled);
    await _prefs.setBool(_keyFor(_profileId), enabled);
  }

  static String _keyFor(String profileId) {
    return 'profile.settings.biometrics.$profileId';
  }
}

final profileSettingsControllerProvider =
    NotifierProvider.family<ProfileSettingsController, ProfileSettings, String>(
      ProfileSettingsController.new,
    );
