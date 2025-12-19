import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_store.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._store) : _plugin = FlutterLocalNotificationsPlugin();

  final NotificationStore _store;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialised = false;

  Future<void> ensureInitialized() async {
    if (_initialised) {
      return;
    }
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
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
      final scheduled = _nextInstance(schedule.startDate, time);
      if (scheduled == null) {
        continue;
      }
      final id = _notificationId(schedule.id, time);
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

  tz.TZDateTime? _nextInstance(DateTime startDate, String timeString) {
    final parsed = _parseTime(timeString);
    if (parsed == null) {
      return null;
    }
    final start = DateTime(startDate.year, startDate.month, startDate.day, parsed.hour, parsed.minute);
    final now = DateTime.now();
    final candidate = start.isAfter(now) ? start : DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
    return tz.TZDateTime.from(candidate, tz.local);
  }

  DateTime? _parseTime(String value) {
    final sanitized = value.trim().toUpperCase();
    final formats = ['HH:mm', 'H:mm', 'h:mma', 'hh:mma'];
    for (final format in formats) {
      try {
        return DateFormat(format).parseStrict(sanitized);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  int _notificationId(String scheduleId, String time) {
    final raw = '$scheduleId-$time';
    return raw.hashCode.abs() % 2147483647;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final store = ref.watch(notificationStoreProvider);
  return NotificationService(store);
});
