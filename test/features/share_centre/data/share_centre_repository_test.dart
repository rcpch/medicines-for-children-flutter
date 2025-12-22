import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';

void main() {
  test('ShareCentreSchedule.fromJson parses date maps and carer name', () {
    final schedule = ShareCentreSchedule.fromJson({
      'apiId': 'api-123',
      'status': 'Pending',
      'dateFromObj': {'day': 3, 'month': 2, 'year': 2025},
      'dateToObj': {'day': 10, 'month': 2, 'year': 2025},
      'digital': true,
      'carer': {'firstName': 'Alex', 'lastName': 'Kim'},
      'email': 'alex@example.com',
      'scheduleUrl': 'https://example.com/share',
    });

    expect(schedule.apiId, 'api-123');
    expect(schedule.status, 'Pending');
    expect(schedule.dateFrom, DateTime(2025, 2, 3));
    expect(schedule.dateTo, DateTime(2025, 2, 10));
    expect(schedule.isDigital, true);
    expect(schedule.displayCarer, 'Alex Kim');
    expect(schedule.scheduleUrl, 'https://example.com/share');
  });

  test('ShareCentreSchedule.fromJson parses ISO dates', () {
    final schedule = ShareCentreSchedule.fromJson({
      'api_id': 'api-456',
      'dateFrom': '2025-02-03T00:00:00.000Z',
      'dateTo': '2025-02-10T00:00:00.000Z',
      'pdfUrl': 'https://example.com/pdf',
    });

    expect(schedule.apiId, 'api-456');
    expect(schedule.pdfUrl, 'https://example.com/pdf');
    expect(schedule.dateFrom.year, 2025);
    expect(schedule.dateTo.day, 10);
  });
}
