import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _telemetryEnabledKey = 'telemetry_enabled';
const _telemetryConsentShownKey = 'telemetry_consent_shown';

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs)
      : super(
          AppSettings(
            telemetryEnabled: _prefs.getBool(_telemetryEnabledKey) ?? true,
            telemetryConsentShown: _prefs.getBool(_telemetryConsentShownKey) ?? false,
          ),
        );

  final SharedPreferences _prefs;

  Future<void> setTelemetryEnabled(bool enabled) async {
    state = state.copyWith(telemetryEnabled: enabled);
    await _prefs.setBool(_telemetryEnabledKey, enabled);
  }

  Future<void> setTelemetryConsent({required bool enabled}) async {
    state = state.copyWith(
      telemetryEnabled: enabled,
      telemetryConsentShown: true,
    );
    await _prefs.setBool(_telemetryEnabledKey, enabled);
    await _prefs.setBool(_telemetryConsentShownKey, true);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});
