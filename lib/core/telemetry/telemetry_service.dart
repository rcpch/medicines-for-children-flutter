import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return DebugTelemetryService();
});
