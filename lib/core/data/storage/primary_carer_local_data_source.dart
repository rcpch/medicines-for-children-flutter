import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrimaryCarerLocalDataSource {
  PrimaryCarerLocalDataSource(this._preferences);

  static const cacheKey = 'primary_carer.cache';

  final SharedPreferences _preferences;

  PrimaryCarer? read() {
    final raw = _preferences.getString(cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return PrimaryCarer.fromJson(decoded);
  }

  Future<void> write(PrimaryCarer primaryCarer) async {
    await _preferences.setString(cacheKey, jsonEncode(primaryCarer.toJson()));
  }

  Future<void> clear() async {
    await _preferences.remove(cacheKey);
  }
}

final primaryCarerLocalDataSourceProvider = Provider<PrimaryCarerLocalDataSource>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return PrimaryCarerLocalDataSource(preferences);
});
