import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_schedule_calculator.dart';

void main() {
  group('NotificationScheduleCalculator', () {
    const calculator = NotificationScheduleCalculator();

    test('parses supported time formats', () {
      final parsed24 = calculator.parseTime('08:15');
      final parsedShort = calculator.parseTime('8:05');
      final parsedAm = calculator.parseTime('8:30am');
      final parsedPm = calculator.parseTime('08:45PM');

      expect(parsed24, isNotNull);
      expect(parsed24!.hour, 8);
      expect(parsed24.minute, 15);

      expect(parsedShort, isNotNull);
      expect(parsedShort!.hour, 8);
      expect(parsedShort.minute, 5);

      expect(parsedAm, isNotNull);
      expect(parsedAm!.hour, 8);
      expect(parsedAm.minute, 30);

      expect(parsedPm, isNotNull);
      expect(parsedPm!.hour, 20);
      expect(parsedPm.minute, 45);
    });

    test('returns null for unsupported time formats', () {
      expect(calculator.parseTime('tomorrow'), isNull);
      expect(calculator.parseTime('25:90'), isNull);
    });

    test('nextInstance uses start date when in the future', () {
      final now = DateTime(2025, 1, 10, 9, 0);
      final startDate = DateTime(2025, 1, 12);

      final next = calculator.nextInstance(
        startDate: startDate,
        timeString: '10:30',
        now: now,
      );

      expect(next, DateTime(2025, 1, 12, 10, 30));
    });

    test('nextInstance uses today when start date is in the past', () {
      final now = DateTime(2025, 1, 10, 15, 0);
      final startDate = DateTime(2025, 1, 1);

      final next = calculator.nextInstance(
        startDate: startDate,
        timeString: '08:00',
        now: now,
      );

      expect(next, DateTime(2025, 1, 10, 8, 0));
    });

    test('notificationId is stable and positive', () {
      final id1 = calculator.notificationId('schedule-1', '08:00');
      final id2 = calculator.notificationId('schedule-1', '08:00');
      final id3 = calculator.notificationId('schedule-2', '08:00');

      expect(id1, id2);
      expect(id1, isNonNegative);
      expect(id3, isNonNegative);
      expect(id1 == id3, isFalse);
    });
  });
}
