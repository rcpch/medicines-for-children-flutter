import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_store.dart';
import 'package:medicines_for_children_flutter/core/security/biometric_auth_service.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/settings_page.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/privacy_policy_page.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/data_deletion_page.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('settings page toggles telemetry', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(NotificationStore(prefs)),
          ),
          biometricAuthServiceProvider.overrideWithValue(FakeBiometricAuthService()),
        ],
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Share anonymous analytics'),
      200,
    );
    expect(find.text('Share anonymous analytics'), findsOneWidget);

    await tester.tap(find.text('Share anonymous analytics'));
    await tester.pumpAndSettle();

    expect(prefs.getBool('telemetry_enabled'), isFalse);
  });

  testWidgets('settings page navigates to privacy policy and data deletion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(NotificationStore(prefs)),
          ),
          biometricAuthServiceProvider.overrideWithValue(FakeBiometricAuthService()),
        ],
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Privacy policy'),
      200,
    );
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);

    Navigator.of(tester.element(find.byType(PrivacyPolicyPage))).pop();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Request data deletion'),
      200,
    );
    await tester.tap(find.text('Request data deletion'));
    await tester.pumpAndSettle();
    expect(find.byType(DataDeletionPage), findsOneWidget);
  });
}

class FakeNotificationService extends NotificationService {
  FakeNotificationService(super.store);

  @override
  Future<void> cancelAll() async {}
}

class FakeBiometricAuthService extends BiometricAuthService {
  FakeBiometricAuthService() : super(_FakeLocalAuth());

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> authenticate() async => false;
}

class _FakeLocalAuth implements LocalAuthentication {
  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    return false;
  }

  @override
  Future<bool> get canCheckBiometrics async => false;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => <BiometricType>[];

  @override
  Future<bool> isDeviceSupported() async => false;

  @override
  Future<bool> stopAuthentication() async => true;
}
