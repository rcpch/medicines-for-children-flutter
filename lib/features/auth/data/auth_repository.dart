import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthStatus> statusStream();
  Future<AuthUser?> currentUser();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
  Future<void> sendPasswordReset({required String email});
  Future<void> completeOnboarding({required String displayName});
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AuthStatus> statusStream() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        return AuthStatus.unauthenticated;
      }
      if (user.displayName == null || user.displayName!.isEmpty) {
        return AuthStatus.onboarding;
      }
      return AuthStatus.authenticated;
    }).distinct();
  }

  @override
  Future<AuthUser?> currentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> completeOnboarding({required String displayName}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user to complete onboarding');
    }
    await user.updateDisplayName(displayName);
    await user.reload();
  }
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository()
      : _controller = StreamController<AuthStatus>.broadcast(sync: true),
        _user = const AuthUser(
          uid: 'mock-dev-user',
          email: 'dev@example.com',
          displayName: 'Dev User',
        ),
        _status = AuthStatus.authenticated;

  final StreamController<AuthStatus> _controller;
  AuthStatus _status;
  AuthUser? _user;

  void _emit(AuthStatus status) {
    _status = status;
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  @override
  Stream<AuthStatus> statusStream() async* {
    yield _status;
    yield* _controller.stream.distinct();
  }

  @override
  Future<AuthUser?> currentUser() async => _user;

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = AuthUser(uid: 'mock-uid', email: email, displayName: 'Mock User');
    _emit(AuthStatus.authenticated);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    _user = AuthUser(uid: 'mock-new-user', email: email, displayName: null);
    _emit(AuthStatus.onboarding);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _emit(AuthStatus.unauthenticated);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {}

  @override
  Future<void> completeOnboarding({required String displayName}) async {
    if (_user == null) {
      throw StateError('No user signed in');
    }
    _user = _user!.copyWith(displayName: displayName);
    _emit(AuthStatus.authenticated);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.enableFirebase) {
    return FirebaseAuthRepository(FirebaseAuth.instance);
  }
  final mock = MockAuthRepository();
  ref.onDispose(() {
    mock.dispose();
  });
  return mock;
});