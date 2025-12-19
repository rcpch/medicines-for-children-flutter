import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/data/credentials_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/stored_credentials.dart';

void main() {
  group('AuthController', () {
    late ProviderContainer container;
    late MockAuthRepository mockRepository;
    late FakeCredentialsRepository fakeCredentialsRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      fakeCredentialsRepository = FakeCredentialsRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          credentialsRepositoryProvider.overrideWithValue(fakeCredentialsRepository),
        ],
      );
      addTearDown(container.dispose);
    });

    test('auto authenticates with mock user when firebase is disabled', () async {
      final controller = container.read(authControllerProvider.notifier);
      final nextState = await controller.stream.firstWhere((state) => state.status == AuthStatus.authenticated);
      expect(nextState.status, AuthStatus.authenticated);
      expect(nextState.user, isNotNull);
      expect(nextState.user!.email, 'dev@example.com');
    });

    test('signIn transitions to authenticated and stores user', () async {
      final controller = container.read(authControllerProvider.notifier);

      final unauthFuture = controller.stream.firstWhere((state) => state.status == AuthStatus.unauthenticated);
      await controller.signOut();
      await unauthFuture;
      final authenticatedFuture = controller.stream.firstWhere((state) => state.status == AuthStatus.authenticated);
      await controller.signIn(email: 'mock@example.com', password: 'password123');
      final nextState = await authenticatedFuture;
      expect(nextState.user, isNotNull);
      expect(nextState.status, AuthStatus.authenticated);
    });

    test('signOut transitions back to unauthenticated', () async {
      final controller = container.read(authControllerProvider.notifier);

      final authenticatedState = await controller.stream.firstWhere((state) => state.status == AuthStatus.authenticated);

      final unauthFuture = controller.stream.firstWhere(
        (state) =>
            state.status == AuthStatus.unauthenticated &&
            state.user == null &&
            !identical(state, authenticatedState),
      );

      await controller.signOut();
      final nextState = await unauthFuture;
      expect(nextState.user, isNull);
      expect(nextState.status, AuthStatus.unauthenticated);
    });

    test('signUp transitions user into onboarding state', () async {
      final controller = container.read(authControllerProvider.notifier);

      final onboardingFuture = controller.stream.firstWhere((state) => state.status == AuthStatus.onboarding);

      await controller.signUp(email: 'new@example.com', password: 'password123');

      final onboardingState = await onboardingFuture;
      expect(onboardingState.status, AuthStatus.onboarding);
      expect(onboardingState.user?.displayName, isNull);
    });

    test('completeOnboarding promotes user to authenticated with display name', () async {
      final controller = container.read(authControllerProvider.notifier);

      await controller.signUp(email: 'new@example.com', password: 'password123');
      await controller.completeOnboarding(displayName: 'New Carer');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.displayName, 'New Carer');
    });
  });
}

class FakeCredentialsRepository implements CredentialsRepository {
  StoredCredentials? _stored;
  bool _rememberMe = false;
  bool _biometricEnabled = false;

  @override
  Future<void> clearCredentials() async {
    _stored = null;
  }

  @override
  bool getBiometricEnabled() => _biometricEnabled;

  @override
  bool getRememberMeEnabled() => _rememberMe;

  @override
  Future<StoredCredentials?> readCredentials() async => _stored;

  @override
  Future<void> saveCredentials(StoredCredentials credentials) async {
    _stored = credentials;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
  }

  @override
  Future<void> setRememberMeEnabled(bool enabled) async {
    _rememberMe = enabled;
    if (!enabled) {
      _biometricEnabled = false;
      await clearCredentials();
    }
  }
}
