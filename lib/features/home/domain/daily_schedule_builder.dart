// Builds daily schedule view models.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';

// Provides the daily schedule builder helper.
final dailyScheduleBuilderProvider = Provider<DailyScheduleBuilder>((ref) {
  return DailyScheduleBuilder();
});

// View model for a scheduled medicine entry.
class DailyScheduleEntry {
  const DailyScheduleEntry({
    required this.id,
    required this.scheduleId,
    required this.medicine,
    required this.scheduledDateTime,
    required this.timeLabel,
    required this.status,
    this.notes,
  });

  final String id;
  final String scheduleId;
  final Medicine medicine;
  final DateTime scheduledDateTime;
  final String timeLabel;
  final AdministrationStatus status;
  final String? notes;

  // True when the scheduled time is in the past.
  bool get isInPast => scheduledDateTime.isBefore(DateTime.now());
  // True when the scheduled time is upcoming.
  bool get isUpcoming => !isInPast;
}

// View model for an as-needed administration entry.
class AsNeededAdministrationEntry {
  const AsNeededAdministrationEntry({
    required this.medicine,
    required this.administration,
  });

  final Medicine medicine;
  final Administration administration;
}

// Buckets used to group entries by time of day.
enum TimeOfDayBucket { morning, afternoon, evening, night }

// Grouping of schedule entries for a time-of-day bucket.
class TimeOfDaySection {
  const TimeOfDaySection({required this.bucket, required this.entries});

  final TimeOfDayBucket bucket;
  final List<DailyScheduleEntry> entries;

  // Human-readable label for the bucket.
  String get label {
    switch (bucket) {
      case TimeOfDayBucket.morning:
        return 'Morning';
      case TimeOfDayBucket.afternoon:
        return 'Afternoon';
      case TimeOfDayBucket.evening:
        return 'Evening';
      case TimeOfDayBucket.night:
        return 'Night';
    }
  }
}

// Builds daily schedule entries and grouped sections for the UI.
class DailyScheduleBuilder {
  // Builds scheduled entries for a child on a given date.
  List<DailyScheduleEntry> buildScheduledEntries(Child child, DateTime date) {
    final Map<String, Medicine> medicineById = {
      for (final medicine in child.medicines) medicine.id: medicine,
    };

    final List<DailyScheduleEntry> entries = [];
    final int weekdayIndex = (date.weekday - 1) % 7;
    final DateTime dateOnly = _asDateOnly(date);

    for (final schedule in child.schedules) {
      if (!_isDateInRange(schedule, dateOnly)) {
        continue;
      }
      if (schedule.weekdaysActive.isNotEmpty &&
          (weekdayIndex >= schedule.weekdaysActive.length ||
              !schedule.weekdaysActive[weekdayIndex])) {
        continue;
      }
      final medicine = medicineById[schedule.medicineId];
      if (medicine == null) {
        continue;
      }

      for (final time in schedule.times) {
        final scheduledDateTime = _merge(dateOnly, time);
        if (scheduledDateTime == null) {
          continue;
        }
        final matchingAdministration = _findAdministration(
          schedule,
          scheduledDateTime,
        );
        final status =
            matchingAdministration?.status ?? AdministrationStatus.scheduled;
        entries.add(
          DailyScheduleEntry(
            id: '${schedule.id}-$time',
            scheduleId: schedule.id,
            medicine: medicine,
            scheduledDateTime: scheduledDateTime,
            timeLabel: DateFormat.jm().format(scheduledDateTime),
            status: status,
            notes: matchingAdministration?.notes,
          ),
        );
      }
    }

    entries.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
    return entries;
  }

  // Groups entries into time-of-day sections.
  List<TimeOfDaySection> buildTimeOfDaySections(
    List<DailyScheduleEntry> entries,
  ) {
    final Map<TimeOfDayBucket, List<DailyScheduleEntry>> bucketed = {
      for (final bucket in TimeOfDayBucket.values)
        bucket: <DailyScheduleEntry>[],
    };

    for (final entry in entries) {
      bucketed[_bucketFor(entry.scheduledDateTime)]!.add(entry);
    }

    return TimeOfDayBucket.values
        .map(
          (bucket) =>
              TimeOfDaySection(bucket: bucket, entries: bucketed[bucket]!),
        )
        .toList();
  }

  // Builds as-needed administration entries for a given date.
  List<AsNeededAdministrationEntry> buildAsNeededEntries(
    Child child,
    DateTime date,
  ) {
    final Map<String, Medicine> medicineById = {
      for (final medicine in child.medicines) medicine.id: medicine,
    };
    final DateTime startOfDay = _asDateOnly(date);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    final List<AsNeededAdministrationEntry> entries = [];

    for (final schedule in child.asNeededSchedules) {
      final medicine = medicineById[schedule.medicineId];
      if (medicine == null) {
        continue;
      }
      for (final administration in schedule.administrations) {
        if (!administration.dateTime.isBefore(startOfDay) &&
            administration.dateTime.isBefore(endOfDay)) {
          entries.add(
            AsNeededAdministrationEntry(
              medicine: medicine,
              administration: administration,
            ),
          );
        }
      }
    }

    entries.sort(
      (a, b) => b.administration.dateTime.compareTo(a.administration.dateTime),
    );
    return entries;
  }

  // Returns true when the date is within the schedule's range.
  bool _isDateInRange(MedicineSchedule schedule, DateTime dateOnly) {
    final DateTime start = _asDateOnly(schedule.startDate);
    final DateTime end = _asDateOnly(schedule.endDate);
    return !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
  }

  // Merges a date with a time string into a DateTime.
  DateTime? _merge(DateTime date, String timeString) {
    final sanitized = timeString.trim().toUpperCase();
    final List<String> patterns = ['HH:mm', 'H:mm', 'h:mma', 'hh:mma'];
    for (final pattern in patterns) {
      try {
        final parsed = DateFormat(pattern).parseStrict(sanitized);
        return DateTime(
          date.year,
          date.month,
          date.day,
          parsed.hour,
          parsed.minute,
        );
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // Finds the administration matching a scheduled time.
  Administration? _findAdministration(
    MedicineSchedule schedule,
    DateTime scheduledDateTime,
  ) {
    for (final administration in schedule.administrations) {
      if (_isSameMinute(administration.dateTime, scheduledDateTime)) {
        return administration;
      }
    }
    return null;
  }

  // Returns true when two DateTimes match to the minute.
  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  // Strips a DateTime down to a date-only value.
  DateTime _asDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // Maps a time to its time-of-day bucket.
  TimeOfDayBucket _bucketFor(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 6 && hour < 12) {
      return TimeOfDayBucket.morning;
    }
    if (hour >= 12 && hour < 17) {
      return TimeOfDayBucket.afternoon;
    }
    if (hour >= 17 && hour < 23) {
      return TimeOfDayBucket.evening;
    }
    return TimeOfDayBucket.night;
  }
}
