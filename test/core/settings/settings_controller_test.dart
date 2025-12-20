import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('settings controller persists telemetry preference', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setTelemetryEnabled(false);

    final state = container.read(settingsControllerProvider);
    expect(state.telemetryEnabled, isFalse);
    expect(prefs.getBool('telemetry_enabled'), isFalse);
  });

  test('settings controller records telemetry consent', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setTelemetryConsent(enabled: true);

    final state = container.read(settingsControllerProvider);
    expect(state.telemetryEnabled, isTrue);
    expect(state.telemetryConsentShown, isTrue);
    expect(prefs.getBool('telemetry_enabled'), isTrue);
    expect(prefs.getBool('telemetry_consent_shown'), isTrue);
  });
}
