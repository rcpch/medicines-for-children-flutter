// Biometric auth checks and prompts.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService(this._auth);

  final LocalAuthentication _auth;

  Future<bool> isSupported() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        return false;
      }
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock your profile with biometrics.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: false,
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(LocalAuthentication());
});
