import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medicines_for_children_flutter/core/data/storage/secure_storage_provider.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/stored_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CredentialsRepository {
  Future<void> saveCredentials(StoredCredentials credentials);
  Future<StoredCredentials?> readCredentials();
  Future<void> clearCredentials();
  bool getRememberMeEnabled();
  Future<void> setRememberMeEnabled(bool enabled);
  bool getBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
}

class SecureCredentialsRepository implements CredentialsRepository {
  SecureCredentialsRepository(this._secureStorage, this._preferences);

  static const _credentialsKey = 'auth.credentials';
  static const _rememberKey = 'auth.remember';
  static const _biometricKey = 'auth.biometric';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;

  @override
  Future<void> saveCredentials(StoredCredentials credentials) async {
    await _secureStorage.write(
      key: _credentialsKey,
      value: jsonEncode(credentials.toJson()),
    );
  }

  @override
  Future<StoredCredentials?> readCredentials() async {
    final raw = await _secureStorage.read(key: _credentialsKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StoredCredentials.fromJson(decoded);
  }

  @override
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _credentialsKey);
  }

  @override
  bool getRememberMeEnabled() {
    return _preferences.getBool(_rememberKey) ?? false;
  }

  @override
  Future<void> setRememberMeEnabled(bool enabled) async {
    await _preferences.setBool(_rememberKey, enabled);
    if (!enabled) {
      await setBiometricEnabled(false);
      await clearCredentials();
    }
  }

  @override
  bool getBiometricEnabled() {
    return _preferences.getBool(_biometricKey) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _preferences.setBool(_biometricKey, enabled);
  }
}

final credentialsRepositoryProvider = Provider<CredentialsRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final preferences = ref.watch(sharedPreferencesProvider);
  return SecureCredentialsRepository(secureStorage, preferences);
});
