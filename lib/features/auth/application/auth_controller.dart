// Auth state controller and session actions.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/core/security/biometric_auth_service.dart';

// Holds the current authentication state and profile list.
class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.profiles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final List<LocalProfile> profiles;
  final bool isLoading;
  final String? errorMessage;

  // Returns true when the user is authenticated.
  bool get isAuthenticated => status == AuthStatus.authenticated;

  // Returns a copy of the state with updated fields.
  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool clearUser = false,
    List<LocalProfile>? profiles,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Provides the auth controller and current auth state.
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

// Orchestrates authentication flows and session state.
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final TelemetryService _telemetry;
  late final BiometricAuthService _biometrics;

  // Initializes auth dependencies and subscribes to status changes.
  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _telemetry = ref.read(telemetryServiceProvider);
    _biometrics = ref.read(biometricAuthServiceProvider);
    final statusSub = _repository.statusStream().listen((status) {
      unawaited(_syncStatus(status));
    });
    ref.onDispose(statusSub.cancel);
    unawaited(_bootstrap());
    return const AuthState();
  }

  // Loads initial profiles and session state.
  Future<void> _bootstrap() async {
    try {
      final profiles = await _repository.listProfiles();
      final user = await _repository.currentUser();
      if (!ref.mounted) {
        return;
      }
      final status = _resolveStatusFromUser(user);
      state = state.copyWith(
        status: status,
        user: user,
        profiles: profiles,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        profiles: const [],
        isLoading: false,
        clearError: true,
      );
    }
  }

  // Resolves auth status based on the current user data.
  AuthStatus _resolveStatusFromUser(AuthUser? user) {
    if (user == null) {
      return AuthStatus.unauthenticated;
    }
    if (user.displayName == null || user.displayName!.trim().isEmpty) {
      return AuthStatus.onboarding;
    }
    return AuthStatus.authenticated;
  }

  // Syncs state from the repository when auth status changes.
  Future<void> _syncStatus(AuthStatus status) async {
    try {
      if (status == AuthStatus.authenticated ||
          status == AuthStatus.onboarding) {
        final user = await _repository.currentUser();
        final profiles = await _repository.listProfiles();
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(
          status: status,
          user: user,
          profiles: profiles,
          isLoading: false,
          clearError: true,
        );
      } else {
        final profiles = await _repository.listProfiles();
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(
          status: status,
          clearUser: true,
          profiles: profiles,
          isLoading: false,
          clearError: true,
        );
      }
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        isLoading: false,
        errorMessage: 'Unable to refresh your session. Please try again.',
      );
    }
  }

  // Reloads the profile list from storage.
  Future<void> refreshProfiles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profiles = await _repository.listProfiles();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        profiles: profiles,
        clearError: true,
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load profiles. Please try again.',
      );
    }
  }

  // Creates a new profile and updates auth state.
  Future<void> createProfile({required String name, String? passcode}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.createProfile(name: name, passcode: passcode);
      final profiles = await _repository.listProfiles();
      final user = await _repository.currentUser();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        profiles: profiles,
        user: user,
        status: _resolveStatusFromUser(user),
        clearError: true,
      );
      _telemetry.trackEvent(
        'profile_created',
        properties: {'hasPasscode': passcode != null && passcode.isNotEmpty},
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create your profile. Please try again.',
      );
    }
  }

  // Selects the active profile and updates auth state.
  Future<void> selectProfile(String profileId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.selectProfile(profileId);
      final user = await _repository.currentUser();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        user: user,
        status: _resolveStatusFromUser(user),
        clearError: true,
      );
      _telemetry.trackEvent('profile_selected');
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to select that profile. Please try again.',
      );
    }
  }

  // Unlocks the active profile with a passcode.
  Future<void> unlockWithPasscode(String passcode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.unlockWithPasscode(passcode);
      final user = await _repository.currentUser();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        user: user,
        status: _resolveStatusFromUser(user),
        clearError: true,
      );
      _telemetry.trackEvent('profile_unlocked');
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Incorrect passcode. Please try again.',
      );
    }
  }

  // Attempts biometric unlock for the active profile.
  Future<bool> unlockWithBiometrics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final canUse = await _biometrics.isSupported();
      if (!canUse) {
        if (!ref.mounted) {
          return false;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Biometrics are not available on this device.',
        );
        return false;
      }
      final ok = await _biometrics.authenticate();
      if (!ok) {
        if (!ref.mounted) {
          return false;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Biometric authentication was cancelled.',
        );
        return false;
      }
      await _repository.unlockWithBiometrics();
      final user = await _repository.currentUser();
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        user: user,
        status: _resolveStatusFromUser(user),
        clearError: true,
      );
      _telemetry.trackEvent('profile_unlocked_biometrics');
      return true;
    } catch (_) {
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to unlock with biometrics right now.',
      );
      return false;
    }
  }

  // Verifies a passcode without changing the session.
  Future<bool> verifyPasscode(String passcode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await _repository.verifyPasscode(passcode);
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(isLoading: false, clearError: true);
      return ok;
    } catch (_) {
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Incorrect passcode. Please try again.',
      );
      return false;
    }
  }

  // Changes the active profile passcode.
  Future<bool> changePasscode({
    String? currentPasscode,
    required String newPasscode,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.changePasscode(
        currentPasscode: currentPasscode,
        newPasscode: newPasscode,
      );
      final profiles = await _repository.listProfiles();
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        profiles: profiles,
        clearError: true,
      );
      _telemetry.trackEvent('passcode_changed');
      return true;
    } catch (_) {
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update the passcode. Please try again.',
      );
      return false;
    }
  }

  // Completes onboarding by saving a display name.
  Future<void> completeOnboarding({required String displayName}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.completeOnboarding(displayName: displayName);
      if (!ref.mounted) {
        return;
      }
      final user = await _repository.currentUser();
      state = state.copyWith(
        isLoading: false,
        status: _resolveStatusFromUser(user),
        user: user,
        clearError: true,
      );
      _telemetry.trackEvent('onboarding_completed');
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to save your profile. Please try again.',
      );
    }
  }

  // Signs out and clears session state.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signOut();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        status: AuthStatus.unauthenticated,
      );
      _telemetry.trackEvent('signed_out');
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign out. Please try again.',
      );
    }
  }
}
