import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/data/local_profiles_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthController', () {
    late ProviderContainer container;
    late LocalAuthRepository authRepository;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      authRepository = LocalAuthRepository(LocalProfilesLocalDataSource(prefs));
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
      );
      addTearDown(() async {
        await authRepository.dispose();
        container.dispose();
      });
    });

    test('starts unauthenticated with no profiles', () async {
      final controller = container.read(authControllerProvider.notifier);
      final nextState = await controller.stream.firstWhere((state) => state.status == AuthStatus.unauthenticated);
      expect(nextState.status, AuthStatus.unauthenticated);
      expect(nextState.user, isNull);
    });

    test('createProfile transitions to onboarding', () async {
      final controller = container.read(authControllerProvider.notifier);

      final onboardingFuture = controller.stream.firstWhere((state) => state.status == AuthStatus.onboarding);
      await controller.createProfile(name: 'Test Profile');
      final nextState = await onboardingFuture;
      expect(nextState.status, AuthStatus.onboarding);
      expect(nextState.user, isNotNull);
      expect(nextState.user!.displayName, isNull);
    });

    test('completeOnboarding promotes user to authenticated', () async {
      final controller = container.read(authControllerProvider.notifier);

      await controller.createProfile(name: 'Test Profile');
      await controller.completeOnboarding(displayName: 'New Carer');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.displayName, 'New Carer');
    });

    test('selectProfile requires passcode to unlock', () async {
      final controller = container.read(authControllerProvider.notifier);

      await controller.createProfile(name: 'Protected', passcode: '123456');
      await controller.signOut();
      await controller.selectProfile(container.read(authControllerProvider).profiles.first.id);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final lockedState = container.read(authControllerProvider);
      expect(lockedState.status, AuthStatus.unauthenticated);

      await controller.unlockWithPasscode('123456');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final unlockedState = container.read(authControllerProvider);
      expect(unlockedState.status, AuthStatus.onboarding);
    });
  });
}
