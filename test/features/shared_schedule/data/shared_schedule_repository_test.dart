import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/data/shared_schedule_repository.dart';

void main() {
  test('SharedScheduleViewModel parses schedule and pdf urls', () {
    final model = SharedScheduleViewModel.fromJson({
      'apiId': 'share-1',
      'status': 'active',
      'dateFrom': '2024-01-01',
      'dateTo': '2024-01-10',
      'days': [],
      'medicines': [],
      'parentId': 'parent-1',
      'carerFirstName': 'Alex',
      'pdfUrl': 'https://example.com/schedule.pdf',
      'scheduleUrl': 'https://example.com/schedule',
    });

    expect(model.pdfUrl, 'https://example.com/schedule.pdf');
    expect(model.scheduleUrl, 'https://example.com/schedule');
  });
}
