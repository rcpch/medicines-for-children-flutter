// Local storage for auth profiles.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/passcode_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists local profiles and passcodes in shared preferences.
class LocalProfilesLocalDataSource {
  LocalProfilesLocalDataSource(this._preferences);

  static const _profilesKey = 'profiles.list.v1';
  static const _activeProfileKey = 'profiles.active.v1';
  static const _passcodePrefix = 'profiles.passcode.v1.';

  final SharedPreferences _preferences;

  /// Loads all stored profiles.
  List<LocalProfile> listProfiles() {
    final raw = _preferences.getString(_profilesKey) ?? '';
    return LocalProfile.listFromRawJson(raw);
  }

  /// Persists the provided profile list.
  Future<void> writeProfiles(List<LocalProfile> profiles) async {
    await _preferences.setString(
      _profilesKey,
      LocalProfile.listToRawJson(profiles),
    );
  }

  /// Reads the active profile id, if any.
  String? readActiveProfileId() {
    final value = _preferences.getString(_activeProfileKey);
    return value == null || value.isEmpty ? null : value;
  }

  /// Writes or clears the active profile id.
  Future<void> writeActiveProfileId(String? profileId) async {
    if (profileId == null || profileId.isEmpty) {
      await _preferences.remove(_activeProfileKey);
    } else {
      await _preferences.setString(_activeProfileKey, profileId);
    }
  }

  /// Reads the passcode record for a profile.
  PasscodeRecord? readPasscodeRecord(String profileId) {
    return PasscodeRecord.fromRawJson(
      _preferences.getString('$_passcodePrefix$profileId'),
    );
  }

  /// Writes or clears the passcode record for a profile.
  Future<void> writePasscodeRecord(
    String profileId,
    PasscodeRecord? record,
  ) async {
    final key = '$_passcodePrefix$profileId';
    if (record == null) {
      await _preferences.remove(key);
      return;
    }
    await _preferences.setString(key, record.toRawJson());
  }
}

/// Provides the local profiles data source.
final localProfilesLocalDataSourceProvider =
    Provider<LocalProfilesLocalDataSource>((ref) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return LocalProfilesLocalDataSource(preferences);
    });
