class AppSettings {
  const AppSettings({
    this.telemetryEnabled = true,
    this.telemetryConsentShown = false,
  });

  final bool telemetryEnabled;
  final bool telemetryConsentShown;

  AppSettings copyWith({
    bool? telemetryEnabled,
    bool? telemetryConsentShown,
  }) {
    return AppSettings(
      telemetryEnabled: telemetryEnabled ?? this.telemetryEnabled,
      telemetryConsentShown: telemetryConsentShown ?? this.telemetryConsentShown,
    );
  }
}
