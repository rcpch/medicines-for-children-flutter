import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_schedule_calculator.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_store.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._store)
      : _plugin = FlutterLocalNotificationsPlugin(),
        _calculator = const NotificationScheduleCalculator();

  final NotificationStore _store;
  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationScheduleCalculator _calculator;
  bool _initialised = false;

  Future<void> ensureInitialized() async {
    if (_initialised) {
      return;
    }
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );
    await _plugin.initialize(initSettings);
    _initialised = true;
  }

  Future<void> scheduleForSchedule({
    required MedicineSchedule schedule,
    required Medicine medicine,
  }) async {
    await ensureInitialized();
    final ids = <int>[];
    for (final time in schedule.times) {
      final candidate = _calculator.nextInstance(
        startDate: schedule.startDate,
        timeString: time,
        now: DateTime.now(),
      );
      if (candidate == null) {
        continue;
      }
      final scheduled = tz.TZDateTime.from(candidate, tz.local);
      final id = _calculator.notificationId(schedule.id, time);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_reminders',
          'Medicine reminders',
          channelDescription: 'Reminders for scheduled medicines',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );
      await _plugin.zonedSchedule(
        id,
        '${medicine.name} reminder',
        '${medicine.dose} ${medicine.doseUnit} · ${medicine.route}',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      ids.add(id);
    }
    if (ids.isNotEmpty) {
      await _store.writeForSchedule(
        schedule.id,
        NotificationMetadata(notificationIds: ids, endDate: schedule.endDate),
      );
    }
  }

  Future<void> cancelForSchedule(String scheduleId) async {
    await ensureInitialized();
    final metadata = await _store.readForSchedule(scheduleId);
    if (metadata == null) {
      return;
    }
    for (final id in metadata.notificationIds) {
      await _plugin.cancel(id);
    }
    await _store.removeSchedule(scheduleId);
  }

  Future<void> pruneExpired() async {
    await ensureInitialized();
    final all = _store.readAll();
    final now = DateTime.now();
    for (final entry in all.entries) {
      if (entry.value.endDate.isBefore(now)) {
        for (final id in entry.value.notificationIds) {
          await _plugin.cancel(id);
        }
        await _store.removeSchedule(entry.key);
      }
    }
  }

  Future<void> cancelAll() async {
    await ensureInitialized();
    final all = _store.readAll();
    for (final entry in all.entries) {
      for (final id in entry.value.notificationIds) {
        await _plugin.cancel(id);
      }
    }
    await _store.clearAll();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final store = ref.watch(notificationStoreProvider);
  return NotificationService(store);
});
