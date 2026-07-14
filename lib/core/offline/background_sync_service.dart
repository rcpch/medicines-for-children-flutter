// Background sync for offline actions.
// Constructor parameter names intentionally omit private field prefixes.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/offline/share_action_queue.dart';
import 'package:medicines_for_children_flutter/core/offline/shared_schedule_action_queue.dart';

// Schedules periodic processing of offline action queues.
class BackgroundSyncService {
  BackgroundSyncService({
    required Future<void> Function() onSync,
    Duration interval = const Duration(minutes: 5),
  }) : _onSync = onSync,
       _interval = interval;

  final Future<void> Function() _onSync;
  final Duration _interval;
  Timer? _timer;
  bool _active = false;
  bool _syncInFlight = false;

  // Starts periodic sync if not already running.
  void start() {
    if (_active) {
      return;
    }
    _active = true;
    _timer = Timer.periodic(_interval, (_) {
      unawaited(_runSync());
    });
  }

  // Stops periodic sync and clears the timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _active = false;
  }

  // Triggers a one-off sync when the service is active.
  Future<void> triggerSync() async {
    if (!_active) {
      return;
    }
    await _runSync();
  }

  // Runs the sync callback with concurrency protection.
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

// Provides the background sync service wired to action queues.
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final shareQueue = ref.watch(shareActionQueueServiceProvider);
  final sharedScheduleQueue = ref.watch(
    sharedScheduleActionQueueServiceProvider,
  );
  final service = BackgroundSyncService(
    onSync: () async {
      await shareQueue.processQueue();
      await sharedScheduleQueue.processQueue();
    },
  );
  ref.onDispose(service.stop);
  return service;
});
