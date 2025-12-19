import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores and retrieves notification metadata', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = NotificationStore(prefs);

    final metadata = NotificationMetadata(
      notificationIds: const [1, 2, 3],
      endDate: DateTime(2025, 1, 1),
    );

    await store.writeForSchedule('sched-1', metadata);
    final readBack = await store.readForSchedule('sched-1');

    expect(readBack, isNotNull);
    expect(readBack!.notificationIds, metadata.notificationIds);
    expect(readBack.endDate, metadata.endDate);
  });
}
