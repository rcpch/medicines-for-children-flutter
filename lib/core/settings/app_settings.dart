// App settings model and defaults.
/// Theme mode choices available in the app.
enum AppThemeMode { system, light, dark }

/// Immutable container for user-configurable app settings.
class AppSettings {
  const AppSettings({
    this.telemetryEnabled = true,
    this.telemetryConsentShown = false,
    this.notificationsEnabled = true,
    this.themeMode = AppThemeMode.system,
    this.textScale = 1.0,
  });

  final bool telemetryEnabled;
  final bool telemetryConsentShown;
  final bool notificationsEnabled;
  final AppThemeMode themeMode;
  final double textScale;

  /// Returns a copy with updated setting values.
  AppSettings copyWith({
    bool? telemetryEnabled,
    bool? telemetryConsentShown,
    bool? notificationsEnabled,
    AppThemeMode? themeMode,
    double? textScale,
  }) {
    return AppSettings(
      telemetryEnabled: telemetryEnabled ?? this.telemetryEnabled,
      telemetryConsentShown:
          telemetryConsentShown ?? this.telemetryConsentShown,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
    );
  }
}
