import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/offline/share_action_queue.dart';
import 'package:medicines_for_children_flutter/core/offline/shared_schedule_action_queue.dart';

class BackgroundSyncService {
  BackgroundSyncService({
    required Future<void> Function() onSync,
    Duration interval = const Duration(minutes: 5),
  })  : _onSync = onSync,
        _interval = interval;

  final Future<void> Function() _onSync;
  final Duration _interval;
  Timer? _timer;
  bool _active = false;
  bool _syncInFlight = false;

  void start() {
    if (_active) {
      return;
    }
    _active = true;
    _timer = Timer.periodic(_interval, (_) {
      unawaited(_runSync());
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _active = false;
  }

  Future<void> triggerSync() async {
    if (!_active) {
      return;
    }
    await _runSync();
  }

  Future<void> _runSync() async {
    if (_syncInFlight) {
      return;
    }
    _syncInFlight = true;
    try {
      await _onSync();
    } catch (_) {
      // Swallow sync errors; queue processors already handle retries.
    } finally {
      _syncInFlight = false;
    }
  }
}

final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final shareQueue = ref.watch(shareActionQueueServiceProvider);
  final sharedScheduleQueue = ref.watch(sharedScheduleActionQueueServiceProvider);
  final service = BackgroundSyncService(
    onSync: () async {
      await shareQueue.processQueue();
      await sharedScheduleQueue.processQueue();
    },
  );
  ref.onDispose(service.stop);
  return service;
});
