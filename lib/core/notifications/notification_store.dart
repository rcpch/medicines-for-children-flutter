import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationMetadata {
  NotificationMetadata({
    required this.notificationIds,
    required this.endDate,
  });

  final List<int> notificationIds;
  final DateTime endDate;

  Map<String, dynamic> toJson() => {
        'notificationIds': notificationIds,
        'endDate': endDate.toIso8601String(),
      };

  static NotificationMetadata? fromJson(Map<String, dynamic> json) {
    final ids = (json['notificationIds'] as List?)?.map((item) => item as int).toList();
    final endDateRaw = json['endDate'] as String?;
    if (ids == null || endDateRaw == null) {
      return null;
    }
    final endDate = DateTime.tryParse(endDateRaw);
    if (endDate == null) {
      return null;
    }
    return NotificationMetadata(notificationIds: ids, endDate: endDate);
  }
}

class NotificationStore {
  NotificationStore(this._preferences);

  static const _key = 'notifications.v1';

  final SharedPreferences _preferences;

  Future<NotificationMetadata?> readForSchedule(String scheduleId) async {
    final all = _readAll();
    final value = all[scheduleId];
    if (value is! Map<String, dynamic>) {
      return null;
    }
    return NotificationMetadata.fromJson(value);
  }

  Future<void> writeForSchedule(String scheduleId, NotificationMetadata metadata) async {
    final all = _readAll();
    all[scheduleId] = metadata.toJson();
    await _writeAll(all);
  }

  Future<void> removeSchedule(String scheduleId) async {
    final all = _readAll();
    all.remove(scheduleId);
    await _writeAll(all);
  }

  Map<String, NotificationMetadata> readAll() {
    final raw = _readAll();
    final Map<String, NotificationMetadata> result = {};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        continue;
      }
      final metadata = NotificationMetadata.fromJson(value);
      if (metadata != null) {
        result[entry.key] = metadata;
      }
    }
    return result;
  }

  Map<String, dynamic> _readAll() {
    final raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }
    return decoded;
  }

  Future<void> _writeAll(Map<String, dynamic> value) async {
    await _preferences.setString(_key, jsonEncode(value));
  }
}

final notificationStoreProvider = Provider<NotificationStore>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return NotificationStore(preferences);
});
