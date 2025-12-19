import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/data/credentials_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/stored_credentials.dart';

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool clearUser = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    _repository = _ref.read(authRepositoryProvider);
    _credentialsRepository = _ref.read(credentialsRepositoryProvider);
    _statusSub = _repository.statusStream().listen((status) {
      unawaited(_syncStatus(status));
    });
    unawaited(_bootstrap());
  }

  final Ref _ref;
  late final AuthRepository _repository;
  late final CredentialsRepository _credentialsRepository;
  StreamSubscription<AuthStatus>? _statusSub;

  Future<void> _bootstrap() async {
    try {
      final user = await _repository.currentUser();
      if (!mounted) {
        return;
      }
      final status = _resolveStatusFromUser(user);
      state = state.copyWith(status: status, user: user, isLoading: false, clearError: true);
      if (status == AuthStatus.unauthenticated) {
        unawaited(_attemptAutoSignIn());
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true, isLoading: false, clearError: true);
      unawaited(_attemptAutoSignIn());
    }
  }

  AuthStatus _resolveStatusFromUser(AuthUser? user) {
    if (user == null) {
      return AuthStatus.unauthenticated;
    }
    if (user.displayName == null || user.displayName!.trim().isEmpty) {
      return AuthStatus.onboarding;
    }
    return AuthStatus.authenticated;
  }

  Future<void> _attemptAutoSignIn() async {
    if (!_credentialsRepository.getRememberMeEnabled()) {
      return;
    }
    final storedCredentials = await _credentialsRepository.readCredentials();
    if (storedCredentials == null) {
      return;
    }
    await signIn(
      email: storedCredentials.email,
      password: storedCredentials.password,
      persistCredentials: false,
      clearStoredCredentials: false,
    );
  }

  Future<void> _syncStatus(AuthStatus status) async {
    try {
      if (status == AuthStatus.authenticated || status == AuthStatus.onboarding) {
        final user = await _repository.currentUser();
        if (!mounted) {
          return;
        }
        state = state.copyWith(
          status: status,
          user: user,
          isLoading: false,
          clearError: true,
        );
      } else {
        if (!mounted) {
          return;
        }
        state = state.copyWith(
          status: status,
          clearUser: true,
          isLoading: false,
          clearError: true,
        );
      }
    } catch (_) {
      if (!mounted) {
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

  Future<bool> signIn({
    required String email,
    required String password,
    bool persistCredentials = false,
    bool clearStoredCredentials = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signIn(email: email, password: password);
      if (!mounted) {
        return true;
      }
      state = state.copyWith(isLoading: false);
      if (persistCredentials) {
        await _credentialsRepository.saveCredentials(
          StoredCredentials(email: email, password: password),
        );
        await _credentialsRepository.setRememberMeEnabled(true);
      } else if (clearStoredCredentials) {
        await _credentialsRepository.setRememberMeEnabled(false);
      }
      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign in. Check your credentials and try again.',
      );
      return false;
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signUp(email: email, password: password);
      if (!mounted) {
        return;
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create your account. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signOut();
      if (!mounted) {
        return;
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign out. Please try again.',
      );
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.sendPasswordReset(email: email);
      if (!mounted) {
        return;
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to send reset email. Please try again later.',
      );
    }
  }

  Future<void> completeOnboarding({required String displayName}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.completeOnboarding(displayName: displayName);
      if (!mounted) {
        return;
      }
      final user = await _repository.currentUser();
      state = state.copyWith(
        isLoading: false,
        status: _resolveStatusFromUser(user),
        user: user,
        clearError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to save your profile. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }
}
