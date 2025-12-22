import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/offline/background_sync_service.dart';

void main() {
  test('triggerSync calls sync handler', () async {
    var syncCount = 0;
    final service = BackgroundSyncService(
      onSync: () async {
        syncCount += 1;
      },
      interval: const Duration(seconds: 5),
    );

    service.start();
    await service.triggerSync();
    expect(syncCount, 1);
    service.stop();
  });

  test('start schedules periodic sync and stop cancels it', () {
    fakeAsync((async) {
      var syncCount = 0;
      final service = BackgroundSyncService(
        onSync: () async {
          syncCount += 1;
        },
        interval: const Duration(seconds: 2),
      );

      service.start();
      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();
      expect(syncCount, 1);

      async.elapse(const Duration(seconds: 4));
      async.flushMicrotasks();
      expect(syncCount, 3);

      service.stop();
      async.elapse(const Duration(seconds: 4));
      async.flushMicrotasks();
      expect(syncCount, 3);
    });
  });
}
