class AppSettings {
  const AppSettings({
    this.telemetryEnabled = true,
  });

  final bool telemetryEnabled;

  AppSettings copyWith({
    bool? telemetryEnabled,
  }) {
    return AppSettings(
      telemetryEnabled: telemetryEnabled ?? this.telemetryEnabled,
    );
  }
}
