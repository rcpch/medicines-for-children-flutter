// App settings model and defaults.
enum AppThemeMode { system, light, dark }

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

  AppSettings copyWith({
    bool? telemetryEnabled,
    bool? telemetryConsentShown,
    bool? notificationsEnabled,
    AppThemeMode? themeMode,
    double? textScale,
  }) {
    return AppSettings(
      telemetryEnabled: telemetryEnabled ?? this.telemetryEnabled,
      telemetryConsentShown: telemetryConsentShown ?? this.telemetryConsentShown,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
    );
  }
}
