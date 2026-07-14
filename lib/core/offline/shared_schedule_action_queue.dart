// Queue for shared schedule actions while offline.
// Constructor parameter names intentionally omit private field prefixes.
// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/data/shared_schedule_repository.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/application/shared_schedule_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _queueKey = 'pending_shared_schedule_actions';

// Types of shared schedule actions queued while offline.
enum SharedScheduleActionType { confirm, record }

// Serializable queued action for shared schedule operations.
class PendingSharedScheduleAction {
  PendingSharedScheduleAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.queuedAt,
  });

  // Builds a queued action from stored JSON.
  factory PendingSharedScheduleAction.fromJson(Map<String, dynamic> json) {
    return PendingSharedScheduleAction(
      id: json['id'] as String,
      type: SharedScheduleActionType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => SharedScheduleActionType.record,
      ),
      payload: (json['payload'] as Map).cast<String, dynamic>(),
      queuedAt:
          DateTime.tryParse(json['queuedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String id;
  final SharedScheduleActionType type;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;

  // Serializes the queued action to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'queuedAt': queuedAt.toIso8601String(),
    };
  }
}

// Manages queued shared schedule actions for offline recovery.
class SharedScheduleActionQueueService {
  SharedScheduleActionQueueService({
    required SharedPreferences prefs,
    required SharedScheduleRepository repository,
    required AppConfig config,
  }) : _prefs = prefs,
       _repository = repository,
       _config = config;

  final SharedPreferences _prefs;
  final SharedScheduleRepository _repository;
  final AppConfig _config;

  // Adds a new action to the persistent queue.
  Future<void> enqueue(PendingSharedScheduleAction action) async {
    final queue = await loadQueue();
    queue.add(action);
    await _saveQueue(queue);
  }

  // Loads queued actions from storage.
  Future<List<PendingSharedScheduleAction>> loadQueue() async {
    final raw = _prefs.getStringList(_queueKey) ?? const [];
    return raw
        .map(
          (entry) => PendingSharedScheduleAction.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Processes queued actions against the API when available.
  Future<void> processQueue() async {
    if (_config.sharedScheduleApiBaseUrl.trim().isEmpty) {
      return;
    }
    final queue = await loadQueue();
    if (queue.isEmpty) {
      return;
    }

    final remaining = <PendingSharedScheduleAction>[];
    for (final action in queue) {
      final success = await _processAction(action);
      if (!success) {
        remaining.add(action);
      }
    }
    await _saveQueue(remaining);
  }

  // Executes a queued action, returning success state.
  Future<bool> _processAction(PendingSharedScheduleAction action) async {
    try {
      switch (action.type) {
        case SharedScheduleActionType.confirm:
          await _repository.confirmSchedule(
            apiId: action.payload['apiId'] as String,
            authToken: action.payload['authToken'] as String,
            approved: action.payload['approved'] as bool,
            reason: action.payload['reason'] as String?,
          );
          return true;
        case SharedScheduleActionType.record:
          await _repository.recordAdministration(
            apiId: action.payload['apiId'] as String,
            authToken: action.payload['authToken'] as String,
            parentId: action.payload['parentId'] as String,
            adminBy: action.payload['adminBy'] as String,
            dateTime: DateTime.parse(action.payload['dateTime'] as String),
            isAsNeeded: action.payload['isAsNeeded'] as bool,
            skipped: action.payload['skipped'] as bool,
            scheduledItemId: action.payload['scheduledItemId'] as String?,
            medicineId: action.payload['medicineId'] as String?,
            notes: action.payload['notes'] as String?,
          );
          return true;
      }
    } catch (_) {
      return false;
    }
  }

  // Persists the queue to storage.
  Future<void> _saveQueue(List<PendingSharedScheduleAction> queue) async {
    final encoded = queue.map((action) => jsonEncode(action.toJson())).toList();
    await _prefs.setStringList(_queueKey, encoded);
  }
}

// Provides the shared schedule action queue service.
final sharedScheduleActionQueueServiceProvider =
    Provider<SharedScheduleActionQueueService>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      final repository = ref.watch(sharedScheduleRepositoryProvider);
      final config = ref.watch(appConfigProvider);
      return SharedScheduleActionQueueService(
        prefs: prefs,
        repository: repository,
        config: config,
      );
    });
