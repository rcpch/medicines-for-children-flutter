// Telemetry event logging and consent.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';

/// Interface for recording telemetry events and screens.
abstract class TelemetryService {
  void trackEvent(String name, {Map<String, Object?>? properties});
  void trackScreen(String name, {Map<String, Object?>? properties});
}

/// Telemetry service that logs events to debug output.
class DebugTelemetryService implements TelemetryService {
  @override
  /// Logs an event to the debug console when enabled.
  void trackEvent(String name, {Map<String, Object?>? properties}) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('Telemetry event: $name ${properties ?? {}}');
  }

  @override
  /// Logs a screen view to the debug console when enabled.
  void trackScreen(String name, {Map<String, Object?>? properties}) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('Telemetry screen: $name ${properties ?? {}}');
  }
}

/// Telemetry wrapper that enforces user consent before logging.
class OptInTelemetryService implements TelemetryService {
  OptInTelemetryService(this._ref, this._delegate);

  final Ref _ref;
  final TelemetryService _delegate;

  /// Returns true when the user has enabled telemetry.
  bool get _enabled => _ref.read(settingsControllerProvider).telemetryEnabled;

  @override
  /// Records an event only when telemetry is enabled.
  void trackEvent(String name, {Map<String, Object?>? properties}) {
    if (!_enabled) {
      return;
    }
    _delegate.trackEvent(name, properties: properties);
  }

  @override
  /// Records a screen only when telemetry is enabled.
  void trackScreen(String name, {Map<String, Object?>? properties}) {
    if (!_enabled) {
      return;
    }
    _delegate.trackScreen(name, properties: properties);
  }
}

/// Provides the telemetry service with consent gating.
final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return OptInTelemetryService(ref, DebugTelemetryService());
});
