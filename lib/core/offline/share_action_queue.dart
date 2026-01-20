// Queue for share centre actions while offline.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';
import 'package:medicines_for_children_flutter/features/share_centre/application/share_centre_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _queueKey = 'pending_share_actions';

/// Types of share centre actions queued while offline.
enum ShareActionType { create, update, end, delete }

/// Serializable queued action for share centre operations.
class PendingShareAction {
  PendingShareAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.queuedAt,
  });

  /// Builds a queued action from stored JSON.
  factory PendingShareAction.fromJson(Map<String, dynamic> json) {
    return PendingShareAction(
      id: json['id'] as String,
      type: ShareActionType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => ShareActionType.update,
      ),
      payload: (json['payload'] as Map).cast<String, dynamic>(),
      queuedAt:
          DateTime.tryParse(json['queuedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String id;
  final ShareActionType type;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;

  /// Serializes the queued action to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'queuedAt': queuedAt.toIso8601String(),
    };
  }
}

/// Manages queued share centre actions for offline recovery.
class ShareActionQueueService {
  ShareActionQueueService({
    required SharedPreferences prefs,
    required ShareCentreRepository repository,
    required AppConfig config,
  }) : _prefs = prefs,
       _repository = repository,
       _config = config;

  final SharedPreferences _prefs;
  final ShareCentreRepository _repository;
  final AppConfig _config;

  /// Adds a new action to the persistent queue.
  Future<void> enqueue(PendingShareAction action) async {
    final queue = await loadQueue();
    queue.add(action);
    await _saveQueue(queue);
  }

  /// Loads queued actions from storage.
  Future<List<PendingShareAction>> loadQueue() async {
    final raw = _prefs.getStringList(_queueKey) ?? const [];
    return raw
        .map(
          (entry) => PendingShareAction.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Processes queued actions against the API when available.
  Future<void> processQueue() async {
    if (_config.sharedScheduleApiBaseUrl.trim().isEmpty) {
      return;
    }
    final queue = await loadQueue();
    if (queue.isEmpty) {
      return;
    }

    final remaining = <PendingShareAction>[];
    for (final action in queue) {
      final success = await _processAction(action);
      if (!success) {
        remaining.add(action);
      }
    }
    await _saveQueue(remaining);
  }

  /// Executes a queued action, returning success state.
  Future<bool> _processAction(PendingShareAction action) async {
    try {
      switch (action.type) {
        case ShareActionType.create:
          await _repository.createSharedSchedule(
            childId: action.payload['childId'] as String,
            email: action.payload['email'] as String,
            dateFrom: DateTime.parse(action.payload['dateFrom'] as String),
            dateTo: DateTime.parse(action.payload['dateTo'] as String),
            digital: action.payload['digital'] as bool,
            notes: action.payload['notes'] as String?,
          );
          return true;
        case ShareActionType.update:
          await _repository.updateSharedSchedule(
            apiId: action.payload['apiId'] as String,
            childId: action.payload['childId'] as String,
            dateFrom: DateTime.parse(action.payload['dateFrom'] as String),
            dateTo: DateTime.parse(action.payload['dateTo'] as String),
            digital: action.payload['digital'] as bool?,
            notes: action.payload['notes'] as String?,
          );
          return true;
        case ShareActionType.end:
          await _repository.endSharedSchedule(
            apiId: action.payload['apiId'] as String,
          );
          return true;
        case ShareActionType.delete:
          await _repository.deleteSharedSchedule(
            apiId: action.payload['apiId'] as String,
            childId: action.payload['childId'] as String,
            dateFrom: DateTime.parse(action.payload['dateFrom'] as String),
            dateTo: DateTime.parse(action.payload['dateTo'] as String),
          );
          return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Persists the queue to storage.
  Future<void> _saveQueue(List<PendingShareAction> queue) async {
    final encoded = queue.map((action) => jsonEncode(action.toJson())).toList();
    await _prefs.setStringList(_queueKey, encoded);
  }
}

/// Provides the share centre action queue service.
final shareActionQueueServiceProvider = Provider<ShareActionQueueService>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final repository = ref.watch(shareCentreRepositoryProvider);
  final config = ref.watch(appConfigProvider);
  return ShareActionQueueService(
    prefs: prefs,
    repository: repository,
    config: config,
  );
});
