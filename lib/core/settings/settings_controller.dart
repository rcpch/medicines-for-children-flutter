import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _telemetryEnabledKey = 'telemetry_enabled';

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs)
      : super(
          AppSettings(
            telemetryEnabled: _prefs.getBool(_telemetryEnabledKey) ?? true,
          ),
        );

  final SharedPreferences _prefs;

  Future<void> setTelemetryEnabled(bool enabled) async {
    state = state.copyWith(telemetryEnabled: enabled);
    await _prefs.setBool(_telemetryEnabledKey, enabled);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});
