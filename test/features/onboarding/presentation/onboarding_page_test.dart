import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/config/app_theme.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/security/biometric_auth_service.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/core/theme/rcpch_colours.dart';
import 'package:medicines_for_children_flutter/features/onboarding/presentation/onboarding_page.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestBiometricAuthService extends BiometricAuthService {
  _TestBiometricAuthService() : super(LocalAuthentication());

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> authenticate() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding Continue button is a prominent pink filled button', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          telemetryServiceProvider.overrideWithValue(DebugTelemetryService()),
          biometricAuthServiceProvider.overrideWithValue(
            _TestBiometricAuthService(),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const OnboardingPage()),
      ),
    );

    await tester.pumpAndSettle();

    final continueButtons = find.widgetWithText(FilledButton, 'Continue');
    expect(continueButtons, findsWidgets);

    for (final buttonWidget in tester.widgetList<FilledButton>(
      continueButtons,
    )) {
      final background = buttonWidget.style?.backgroundColor?.resolve({});
      expect(background, rcpchPink);
    }
  });
}
