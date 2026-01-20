// Notification timing calculations for schedules.
import 'package:intl/intl.dart';

/// Calculates upcoming notification times and ids.
class NotificationScheduleCalculator {
  const NotificationScheduleCalculator();

  /// Parses a time string into a DateTime on an arbitrary date.
  DateTime? parseTime(String value) {
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

  /// Returns the next DateTime occurrence for a schedule time.
  DateTime? nextInstance({
    required DateTime startDate,
    required String timeString,
    required DateTime now,
  }) {
    final parsed = parseTime(timeString);
    if (parsed == null) {
      return null;
    }
    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      parsed.hour,
      parsed.minute,
    );
    if (start.isAfter(now)) {
      return start;
    }
    return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
  }

  /// Generates a stable notification id for a schedule time.
  int notificationId(String scheduleId, String time) {
    final raw = '$scheduleId-$time';
    return raw.hashCode.abs() % 2147483647;
  }
}
