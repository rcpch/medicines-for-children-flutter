// Controller for global app settings.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _telemetryEnabledKey = 'telemetry_enabled';
const _telemetryConsentShownKey = 'telemetry_consent_shown';
const _notificationsEnabledKey = 'notifications_enabled';
const _themeModeKey = 'theme_mode';
const _textScaleKey = 'text_scale';
const _minTextScale = 0.9;
const _maxTextScale = 1.3;

// Manages persisted app-wide settings.
class SettingsController extends Notifier<AppSettings> {
  SettingsController();

  late SharedPreferences _prefs;

  // Loads settings from shared preferences.
  @override
  AppSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      telemetryEnabled: _prefs.getBool(_telemetryEnabledKey) ?? true,
      telemetryConsentShown: _prefs.getBool(_telemetryConsentShownKey) ?? false,
      notificationsEnabled: _prefs.getBool(_notificationsEnabledKey) ?? true,
      themeMode: _parseThemeMode(_prefs.getString(_themeModeKey)),
      textScale: _clampTextScale(_prefs.getDouble(_textScaleKey) ?? 1.0),
    );
  }

  // Enables or disables telemetry collection.
  Future<void> setTelemetryEnabled(bool enabled) async {
    state = state.copyWith(telemetryEnabled: enabled);
    await _prefs.setBool(_telemetryEnabledKey, enabled);
  }

  // Records telemetry consent and updates telemetry setting.
  Future<void> setTelemetryConsent({required bool enabled}) async {
    state = state.copyWith(
      telemetryEnabled: enabled,
      telemetryConsentShown: true,
    );
    await _prefs.setBool(_telemetryEnabledKey, enabled);
    await _prefs.setBool(_telemetryConsentShownKey, true);
  }

  // Enables or disables local notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _prefs.setBool(_notificationsEnabledKey, enabled);
    if (!enabled) {
      await ref.read(notificationServiceProvider).cancelAll();
    }
  }

  // Updates the preferred theme mode.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_themeModeKey, mode.name);
  }

  // Updates text scaling and clamps to allowed range.
  Future<void> setTextScale(double scale) async {
    final next = _clampTextScale(scale);
    state = state.copyWith(textScale: next);
    await _prefs.setDouble(_textScaleKey, next);
  }

  // Parses a stored theme mode string with a system default.
  static AppThemeMode _parseThemeMode(String? raw) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => AppThemeMode.system,
    );
  }

  // Clamps the text scale between min and max bounds.
  static double _clampTextScale(double scale) {
    return scale.clamp(_minTextScale, _maxTextScale);
  }
}

// Provides the settings controller and current settings state.
final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
