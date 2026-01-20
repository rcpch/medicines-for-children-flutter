// Navigator observer for telemetry events.
import 'package:flutter/widgets.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';

// Reports navigation events to the telemetry service.
class TelemetryNavigatorObserver extends NavigatorObserver {
  TelemetryNavigatorObserver(this._telemetry);

  final TelemetryService _telemetry;

  // Tracks a screen view for the given route.
  void _track(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) {
      return;
    }
    _telemetry.trackScreen(name);
  }

  // Sends telemetry when a new route is pushed.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  // Sends telemetry when the current route is replaced.
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _track(newRoute);
  }
}
