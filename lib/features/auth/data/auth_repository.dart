// Auth data access and persistence.
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/auth/data/local_profiles_local_data_source.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/passcode_record.dart';

/// Defines authentication and profile persistence operations.
abstract class AuthRepository {
  /// Emits auth status changes over time.
  Stream<AuthStatus> statusStream();
  /// Returns the current authenticated user, if any.
  Future<AuthUser?> currentUser();

  /// Lists all locally stored profiles.
  Future<List<LocalProfile>> listProfiles();
  /// Creates a new profile and optionally sets a passcode.
  Future<LocalProfile> createProfile({required String name, String? passcode});
  /// Sets the active profile by id.
  Future<void> selectProfile(String profileId);
  /// Unlocks the active profile with a passcode.
  Future<void> unlockWithPasscode(String passcode);
  /// Marks the active profile as unlocked by biometrics.
  Future<void> unlockWithBiometrics();
  /// Verifies a passcode against the active profile.
  Future<bool> verifyPasscode(String passcode);
  /// Changes or sets the active profile passcode.
  Future<void> changePasscode({
    String? currentPasscode,
    required String newPasscode,
  });
  /// Signs out and clears the active profile.
  Future<void> signOut();

  /// Completes onboarding by storing a display name.
  Future<void> completeOnboarding({required String displayName});
}

/// Local implementation of auth backed by shared preferences.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._profiles);

  static const _passcodeSaltBytes = 16;
  static const _passcodeIterations = 100000;
  static const _passcodeDerivedKeyBytes = 32;

  final LocalProfilesLocalDataSource _profiles;
  final StreamController<AuthStatus> _statusController =
      StreamController<AuthStatus>.broadcast(sync: true);

  String? _activeProfileId;
  bool _unlocked = false;
  bool _initialised = false;

  /// Loads initial profile state when needed.
  Future<void> _ensureInit() async {
    if (_initialised) {
      return;
    }
    _activeProfileId = _profiles.readActiveProfileId();
    final activeProfile = _readActiveProfile();
    _unlocked = activeProfile != null && !activeProfile.hasPasscode;
    _initialised = true;
  }

  /// Returns the currently active local profile, if any.
  LocalProfile? _readActiveProfile() {
    final id = _activeProfileId;
    if (id == null || id.isEmpty) {
      return null;
    }
    return _profiles.listProfiles().cast<LocalProfile?>().firstWhere(
      (profile) => profile?.id == id,
      orElse: () => null,
    );
  }

  /// Resolves auth status from the active profile state.
  AuthStatus _resolveStatus(LocalProfile? activeProfile) {
    if (activeProfile == null) {
      return AuthStatus.unauthenticated;
    }
    if (activeProfile.hasPasscode && !_unlocked) {
      return AuthStatus.unauthenticated;
    }
    if (activeProfile.displayName.trim().isEmpty) {
      return AuthStatus.onboarding;
    }
    return AuthStatus.authenticated;
  }

  /// Emits the latest auth status to subscribers.
  void _emitStatus() {
    final status = _resolveStatus(_readActiveProfile());
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  @override
  /// Streams auth status updates and initial status.
  Stream<AuthStatus> statusStream() async* {
    await _ensureInit();
    yield _resolveStatus(_readActiveProfile());
    yield* _statusController.stream.distinct();
  }

  @override
  /// Returns the current user when the active profile is unlocked.
  Future<AuthUser?> currentUser() async {
    await _ensureInit();
    final profile = _readActiveProfile();
    if (profile == null) {
      return null;
    }
    if (profile.hasPasscode && !_unlocked) {
      return null;
    }
    return AuthUser(
      uid: profile.id,
      email: '',
      displayName: profile.displayName.isEmpty ? null : profile.displayName,
    );
  }

  @override
  /// Lists all locally stored profiles.
  Future<List<LocalProfile>> listProfiles() async {
    await _ensureInit();
    return _profiles.listProfiles();
  }

  @override
  /// Creates a new profile and makes it active.
  Future<LocalProfile> createProfile({
    required String name,
    String? passcode,
  }) async {
    await _ensureInit();
    final newProfile = LocalProfile(
      id: _generateId(),
      name: name.trim(),
      displayName: '',
      createdAt: DateTime.now(),
      hasPasscode: passcode != null && passcode.isNotEmpty,
    );

    final updated = [..._profiles.listProfiles(), newProfile];
    await _profiles.writeProfiles(updated);

    if (newProfile.hasPasscode) {
      final record = await _derivePasscodeRecord(passcode!);
      await _profiles.writePasscodeRecord(newProfile.id, record);
    }

    _activeProfileId = newProfile.id;
    _unlocked = true;
    await _profiles.writeActiveProfileId(newProfile.id);
    _emitStatus();
    return newProfile;
  }

  @override
  /// Sets the active profile by id and updates status.
  Future<void> selectProfile(String profileId) async {
    await _ensureInit();
    final profiles = _profiles.listProfiles();
    final selected = profiles.cast<LocalProfile?>().firstWhere(
      (profile) => profile?.id == profileId,
      orElse: () => null,
    );
    if (selected == null) {
      throw StateError('Profile not found');
    }
    _activeProfileId = selected.id;
    _unlocked = !selected.hasPasscode;
    await _profiles.writeActiveProfileId(selected.id);
    _emitStatus();
  }

  @override
  /// Unlocks the active profile using a passcode.
  Future<void> unlockWithPasscode(String passcode) async {
    await _ensureInit();
    final profile = _readActiveProfile();
    if (profile == null) {
      throw StateError('No active profile selected');
    }
    if (!profile.hasPasscode) {
      _unlocked = true;
      _emitStatus();
      return;
    }
    final record = _profiles.readPasscodeRecord(profile.id);
    if (record == null) {
      throw StateError('Passcode missing for selected profile');
    }
    final ok = await _verifyPasscode(passcode, record);
    if (!ok) {
      throw StateError('Invalid passcode');
    }
    _unlocked = true;
    _emitStatus();
  }

  @override
  /// Unlocks the active profile using biometrics.
  Future<void> unlockWithBiometrics() async {
    await _ensureInit();
    final profile = _readActiveProfile();
    if (profile == null) {
      throw StateError('No active profile selected');
    }
    if (profile.hasPasscode) {
      _unlocked = true;
      _emitStatus();
    }
  }

  @override
  /// Verifies a passcode against the active profile record.
  Future<bool> verifyPasscode(String passcode) async {
    await _ensureInit();
    final profile = _readActiveProfile();
    if (profile == null) {
      throw StateError('No active profile selected');
    }
    if (!profile.hasPasscode) {
      return false;
    }
    final record = _profiles.readPasscodeRecord(profile.id);
    if (record == null) {
      return false;
    }
    return _verifyPasscode(passcode, record);
  }

  @override
  /// Changes or sets the passcode for the active profile.
  Future<void> changePasscode({
    String? currentPasscode,
    required String newPasscode,
  }) async {
    await _ensureInit();
    final profile = _readActiveProfile();
    if (profile == null) {
      throw StateError('No active profile selected');
    }
    if (profile.hasPasscode) {
      if (currentPasscode == null || currentPasscode.isEmpty) {
        throw StateError('Current passcode is required');
      }
      final record = _profiles.readPasscodeRecord(profile.id);
      if (record == null) {
        throw StateError('Passcode missing for selected profile');
      }
      final ok = await _verifyPasscode(currentPasscode, record);
      if (!ok) {
        throw StateError('Invalid passcode');
      }
    }

    final next = await _derivePasscodeRecord(newPasscode);
    await _profiles.writePasscodeRecord(profile.id, next);
    if (!profile.hasPasscode) {
      await _updateProfilePasscodeStatus(profile.id, true);
    }
    _unlocked = true;
    _emitStatus();
  }

  @override
  /// Clears the active profile selection and status.
  Future<void> signOut() async {
    await _ensureInit();
    _activeProfileId = null;
    _unlocked = false;
    await _profiles.writeActiveProfileId(null);
    _emitStatus();
  }

  @override
  /// Sets the display name for the active profile.
  Future<void> completeOnboarding({required String displayName}) async {
    await _ensureInit();
    final profileId = _activeProfileId;
    if (profileId == null || profileId.isEmpty) {
      throw StateError('No active profile to update');
    }

    final profiles = _profiles.listProfiles();
    final index = profiles.indexWhere((profile) => profile.id == profileId);
    if (index == -1) {
      throw StateError('Active profile not found');
    }

    final updated = [...profiles];
    updated[index] = profiles[index].copyWith(displayName: displayName.trim());
    await _profiles.writeProfiles(updated);
    _emitStatus();
  }

  /// Updates the passcode flag stored on the profile.
  Future<void> _updateProfilePasscodeStatus(
    String profileId,
    bool hasPasscode,
  ) async {
    final profiles = _profiles.listProfiles();
    final index = profiles.indexWhere((item) => item.id == profileId);
    if (index == -1) {
      return;
    }
    final updated = [...profiles];
    updated[index] = profiles[index].copyWith(hasPasscode: hasPasscode);
    await _profiles.writeProfiles(updated);
  }

  /// Generates a new random profile id.
  String _generateId() {
    final random = _secureRandom();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Returns a secure random generator when available.
  Random _secureRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  /// Derives and stores a passcode hash record.
  Future<PasscodeRecord> _derivePasscodeRecord(String passcode) async {
    final random = _secureRandom();
    final salt = List<int>.generate(
      _passcodeSaltBytes,
      (_) => random.nextInt(256),
    );
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _passcodeIterations,
      bits: _passcodeDerivedKeyBytes * 8,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passcode)),
      nonce: salt,
    );
    final hash = await secretKey.extractBytes();
    return PasscodeRecord(
      saltBase64: base64Encode(salt),
      iterations: _passcodeIterations,
      hashBase64: base64Encode(hash),
    );
  }

  /// Verifies a passcode against the stored hash.
  Future<bool> _verifyPasscode(String passcode, PasscodeRecord record) async {
    final salt = base64Decode(record.saltBase64);
    final expected = base64Decode(record.hashBase64);
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: record.iterations,
      bits: expected.length * 8,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passcode)),
      nonce: salt,
    );
    final actual = await secretKey.extractBytes();
    if (actual.length != expected.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual[i] ^ expected[i];
    }
    return diff == 0;
  }

  /// Releases auth repository resources.
  Future<void> dispose() async {
    await _statusController.close();
  }
}

/// Provides the active auth repository implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final profiles = ref.watch(localProfilesLocalDataSourceProvider);
  final repo = LocalAuthRepository(profiles);
  ref.onDispose(() {
    repo.dispose();
  });
  return repo;
});
