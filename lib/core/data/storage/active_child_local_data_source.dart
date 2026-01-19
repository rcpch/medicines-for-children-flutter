// Local storage for active child selection.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveChildLocalDataSource {
  ActiveChildLocalDataSource(this._preferences);

  static const _activeChildPrefix = 'profiles.activeChild.v1.';

  final SharedPreferences _preferences;

  String? readActiveChildId(String profileId) {
    final value = _preferences.getString('$_activeChildPrefix$profileId');
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> writeActiveChildId(String profileId, String? childId) async {
    final key = '$_activeChildPrefix$profileId';
    if (childId == null || childId.isEmpty) {
      await _preferences.remove(key);
    } else {
      await _preferences.setString(key, childId);
    }
  }
}

final activeChildLocalDataSourceProvider = Provider<ActiveChildLocalDataSource>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return ActiveChildLocalDataSource(preferences);
});
