// Telemetry event logging and consent.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';

abstract class TelemetryService {
  void trackEvent(String name, {Map<String, Object?>? properties});
  void trackScreen(String name, {Map<String, Object?>? properties});
}

class DebugTelemetryService implements TelemetryService {
  @override
  void trackEvent(String name, {Map<String, Object?>? properties}) {
    debugPrint('Telemetry event: $name ${properties ?? {}}');
  }

  @override
  void trackScreen(String name, {Map<String, Object?>? properties}) {
    debugPrint('Telemetry screen: $name ${properties ?? {}}');
  }
}

class OptInTelemetryService implements TelemetryService {
  OptInTelemetryService(this._ref, this._delegate);

  final Ref _ref;
  final TelemetryService _delegate;

  bool get _enabled => _ref.read(settingsControllerProvider).telemetryEnabled;

  @override
  void trackEvent(String name, {Map<String, Object?>? properties}) {
    if (!_enabled) {
      return;
    }
    _delegate.trackEvent(name, properties: properties);
  }

  @override
  void trackScreen(String name, {Map<String, Object?>? properties}) {
    if (!_enabled) {
      return;
    }
    _delegate.trackScreen(name, properties: properties);
  }
}

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return OptInTelemetryService(ref, DebugTelemetryService());
});
