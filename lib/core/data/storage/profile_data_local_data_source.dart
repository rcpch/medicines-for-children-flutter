// Local storage for profile data records.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Stores profile-specific data blobs in shared preferences.
class ProfileDataLocalDataSource {
  ProfileDataLocalDataSource(this._preferences);

  static const _profileDataPrefix = 'profile.data.v1.';
  static const _primaryCarerKey = 'primaryCarer';
  static const _onboardingKey = 'onboardingProfile';

  final SharedPreferences _preferences;

  // Reads the primary carer record for a profile.
  PrimaryCarer? readPrimaryCarer(String profileId) {
    final data = _readRaw(profileId);
    if (data == null) {
      return null;
    }
    final rawCarer = data[_primaryCarerKey];
    if (rawCarer is! Map<String, dynamic>) {
      return null;
    }
    return PrimaryCarer.fromJson(rawCarer);
  }

  // Writes the primary carer record for a profile.
  Future<void> writePrimaryCarer(String profileId, PrimaryCarer carer) async {
    final data = _readRaw(profileId) ?? <String, dynamic>{};
    data[_primaryCarerKey] = carer.toJson();
    await _writeRaw(profileId, data);
  }

  // Reads the onboarding profile for a profile.
  OnboardingProfile? readOnboardingProfile(String profileId) {
    final data = _readRaw(profileId);
    if (data == null) {
      return null;
    }
    final rawOnboarding = data[_onboardingKey];
    if (rawOnboarding is! Map<String, dynamic>) {
      return null;
    }
    return OnboardingProfile.fromMap(rawOnboarding);
  }

  // Writes the onboarding profile for a profile.
  Future<void> writeOnboardingProfile(
    String profileId,
    OnboardingProfile profile,
  ) async {
    final data = _readRaw(profileId) ?? <String, dynamic>{};
    data[_onboardingKey] = profile.toMap();
    await _writeRaw(profileId, data);
  }

  // Removes the onboarding profile entry for a profile.
  Future<void> clearOnboardingProfile(String profileId) async {
    final data = _readRaw(profileId);
    if (data == null) {
      return;
    }
    data.remove(_onboardingKey);
    await _writeRaw(profileId, data);
  }

  // Clears all stored data for a profile.
  Future<void> clearProfile(String profileId) async {
    await _preferences.remove('$_profileDataPrefix$profileId');
  }

  // Reads the raw JSON map for a profile from storage.
  Map<String, dynamic>? _readRaw(String profileId) {
    final raw = _preferences.getString('$_profileDataPrefix$profileId');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return decoded;
  }

  // Writes the raw JSON map for a profile to storage.
  Future<void> _writeRaw(String profileId, Map<String, dynamic> data) async {
    await _preferences.setString(
      '$_profileDataPrefix$profileId',
      jsonEncode(data),
    );
  }
}

// Provides the profile data local data source.
final profileDataLocalDataSourceProvider = Provider<ProfileDataLocalDataSource>(
  (ref) {
    final preferences = ref.watch(sharedPreferencesProvider);
    return ProfileDataLocalDataSource(preferences);
  },
);
