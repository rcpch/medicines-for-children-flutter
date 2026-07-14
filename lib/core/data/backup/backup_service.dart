// Backup/restore orchestration for local data.
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/onboarding/domain/onboarding_profile.dart';

// Handles encrypted backup and restore of profile data.
class BackupService {
  BackupService({required this.authRepository, required this.profileData});

  static const _formatVersion = 1;
  static const _saltBytes = 16;
  static const _nonceBytes = 12;
  static const _iterations = 100000;

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;

  // Builds an encrypted backup payload from the current profile data.
  Future<Uint8List> createBackup({required String passphrase}) async {
    final user = await authRepository.currentUser();
    if (user == null) {
      throw StateError('No active profile to back up');
    }

    final profiles = await authRepository.listProfiles();
    final profile = profiles.cast<LocalProfile?>().firstWhere(
      (p) => p?.id == user.uid,
      orElse: () => null,
    );
    if (profile == null) {
      throw StateError('Active profile metadata not found');
    }

    final primaryCarer = profileData.readPrimaryCarer(profile.id);
    if (primaryCarer == null) {
      throw StateError('No profile data to back up');
    }

    final onboarding = profileData.readOnboardingProfile(profile.id);
    final payload = {
      'profile': {'name': profile.name, 'displayName': profile.displayName},
      'primaryCarer': primaryCarer.toJson(),
      if (onboarding != null) 'onboardingProfile': onboarding.toMap(),
    };

    final encrypted = await _encryptPayload(jsonEncode(payload), passphrase);
    final encoded = jsonEncode(encrypted);
    return Uint8List.fromList(utf8.encode(encoded));
  }

  // Restores a profile from backup bytes using the provided passphrase.
  Future<LocalProfile> restoreBackup({
    required Uint8List bytes,
    required String passphrase,
    String? newProfileName,
    String? newPasscode,
  }) async {
    final raw = utf8.decode(bytes);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid backup format');
    }
    final payloadJson = await _decryptPayload(decoded, passphrase);
    final payload = jsonDecode(payloadJson);
    if (payload is! Map<String, dynamic>) {
      throw StateError('Invalid backup payload');
    }

    final profileDataMap =
        payload['profile'] as Map<String, dynamic>? ?? const {};
    final profileName = (newProfileName?.trim().isNotEmpty ?? false)
        ? newProfileName!.trim()
        : (profileDataMap['name'] ?? 'Imported profile').toString();
    final displayName = (profileDataMap['displayName'] ?? '').toString();

    final primaryCarerRaw = payload['primaryCarer'];
    if (primaryCarerRaw is! Map<String, dynamic>) {
      throw StateError('Backup missing primary carer data');
    }
    final primaryCarer = PrimaryCarer.fromJson(primaryCarerRaw);

    final onboardingRaw = payload['onboardingProfile'];
    final onboardingProfile = onboardingRaw is Map<String, dynamic>
        ? OnboardingProfile.fromMap(onboardingRaw)
        : null;

    final profile = await authRepository.createProfile(
      name: profileName,
      passcode: newPasscode?.trim().isEmpty ?? true
          ? null
          : newPasscode!.trim(),
    );

    await profileData.writePrimaryCarer(profile.id, primaryCarer);
    if (onboardingProfile != null) {
      await profileData.writeOnboardingProfile(profile.id, onboardingProfile);
    }
    if (displayName.isNotEmpty) {
      await authRepository.completeOnboarding(displayName: displayName);
    }

    return profile;
  }

  // Encrypts the JSON payload using a key derived from the passphrase.
  Future<Map<String, dynamic>> _encryptPayload(
    String plaintext,
    String passphrase,
  ) async {
    final random = Random.secure();
    final salt = List<int>.generate(_saltBytes, (_) => random.nextInt(256));
    final nonce = List<int>.generate(_nonceBytes, (_) => random.nextInt(256));

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );

    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );

    return {
      'formatVersion': _formatVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'kdf': {'salt': base64Encode(salt), 'iterations': _iterations},
      'cipher': {
        'nonce': base64Encode(secretBox.nonce),
        'cipherText': base64Encode(secretBox.cipherText),
        'mac': base64Encode(secretBox.mac.bytes),
      },
    };
  }

  // Decrypts the stored payload using passphrase-derived key material.
  Future<String> _decryptPayload(
    Map<String, dynamic> encrypted,
    String passphrase,
  ) async {
    final formatVersion = (encrypted['formatVersion'] as num?)?.toInt() ?? 0;
    if (formatVersion != _formatVersion) {
      throw StateError('Unsupported backup format');
    }

    final kdf = encrypted['kdf'];
    final cipher = encrypted['cipher'];
    if (kdf is! Map<String, dynamic> || cipher is! Map<String, dynamic>) {
      throw StateError('Invalid backup metadata');
    }

    final salt = base64Decode((kdf['salt'] ?? '').toString());
    final iterations = (kdf['iterations'] as num?)?.toInt() ?? 0;
    if (salt.isEmpty || iterations == 0) {
      throw StateError('Invalid backup key parameters');
    }

    final nonce = base64Decode((cipher['nonce'] ?? '').toString());
    final cipherText = base64Decode((cipher['cipherText'] ?? '').toString());
    final macBytes = base64Decode((cipher['mac'] ?? '').toString());
    if (nonce.isEmpty || cipherText.isEmpty || macBytes.isEmpty) {
      throw StateError('Backup cipher data is incomplete');
    }

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );

    final algorithm = AesGcm.with256bits();
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
    final clear = await algorithm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clear);
  }
}

// Provides the backup service with injected data sources.
final backupServiceProvider = Provider<BackupService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return BackupService(
    authRepository: authRepository,
    profileData: profileData,
  );
});
