import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_store.dart';
import 'package:medicines_for_children_flutter/core/settings/app_settings.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('settings controller persists telemetry preference', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(
          FakeNotificationService(NotificationStore(prefs)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setTelemetryEnabled(false);

    final state = container.read(settingsControllerProvider);
    expect(state.telemetryEnabled, isFalse);
    expect(prefs.getBool('telemetry_enabled'), isFalse);
  });

  test('settings controller records telemetry consent', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(
          FakeNotificationService(NotificationStore(prefs)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setTelemetryConsent(enabled: true);

    final state = container.read(settingsControllerProvider);
    expect(state.telemetryEnabled, isTrue);
    expect(state.telemetryConsentShown, isTrue);
    expect(prefs.getBool('telemetry_enabled'), isTrue);
    expect(prefs.getBool('telemetry_consent_shown'), isTrue);
  });

  test('settings controller stores theme and text scale', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(
          FakeNotificationService(NotificationStore(prefs)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setThemeMode(AppThemeMode.dark);
    await controller.setTextScale(1.2);

    final state = container.read(settingsControllerProvider);
    expect(state.themeMode, AppThemeMode.dark);
    expect(state.textScale, 1.2);
    expect(prefs.getString('theme_mode'), 'dark');
    expect(prefs.getDouble('text_scale'), 1.2);
  });

  test('settings controller disables notifications', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fakeNotifications = FakeNotificationService(NotificationStore(prefs));
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(fakeNotifications),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);
    await controller.setNotificationsEnabled(false);

    final state = container.read(settingsControllerProvider);
    expect(state.notificationsEnabled, isFalse);
    expect(fakeNotifications.cancelAllCalls, 1);
    expect(prefs.getBool('notifications_enabled'), isFalse);
  });
}

class FakeNotificationService extends NotificationService {
  FakeNotificationService(super.store);

  int cancelAllCalls = 0;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls += 1;
  }
}
