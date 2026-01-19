// Shared schedule data access layer.
import 'package:dio/dio.dart';

class SharedScheduleAuthResult {
  const SharedScheduleAuthResult({
    required this.sharedScheduleId,
    required this.success,
    required this.message,
    required this.status,
    this.authToken,
  });

  factory SharedScheduleAuthResult.fromJson(Map<String, dynamic> json) {
    return SharedScheduleAuthResult(
      sharedScheduleId: (json['sharedScheduleId'] ?? '').toString(),
      authToken: json['authToken']?.toString(),
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  final String sharedScheduleId;
  final String? authToken;
  final bool success;
  final String message;
  final String status;

  bool get hasUsableAuthToken => authToken != null && authToken != '0' && authToken!.isNotEmpty;
}

class SharedScheduleMedicineSummary {
  const SharedScheduleMedicineSummary({
    required this.id,
    required this.name,
    required this.knownAs,
  });

  factory SharedScheduleMedicineSummary.fromJson(Map<String, dynamic> json) {
    return SharedScheduleMedicineSummary(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      knownAs: (json['known_as'] ?? '').toString(),
    );
  }

  final String id;
  final String name;
  final String knownAs;

  String get displayName => knownAs.isEmpty ? name : '$name ($knownAs)';
}

class SharedScheduledItem {
  const SharedScheduledItem({
    required this.id,
    required this.medicineId,
    required this.times,
  });

  factory SharedScheduledItem.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['times'];
    final times = rawTimes is List
        ? rawTimes.map((value) => value.toString()).toList(growable: false)
        : const <String>[];

    return SharedScheduledItem(
      id: (json['id'] ?? '').toString(),
      medicineId: (json['medicine'] ?? '').toString(),
      times: times,
    );
  }

  final String id;
  final String medicineId;
  final List<String> times;
}

class SharedScheduleDay {
  const SharedScheduleDay({
    required this.date,
    required this.isToday,
    required this.scheduledItemsForDay,
  });

  factory SharedScheduleDay.fromJson(Map<String, dynamic> json) {
    final rawItems = json['scheduledItemsForDay'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(SharedScheduledItem.fromJson)
            .toList(growable: false)
        : const <SharedScheduledItem>[];

    final rawDate = json['date'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;

    return SharedScheduleDay(
      date: parsedDate ?? DateTime(1970, 1, 1),
      isToday: json['isToday'] == true,
      scheduledItemsForDay: items,
    );
  }

  final DateTime date;
  final bool isToday;
  final List<SharedScheduledItem> scheduledItemsForDay;
}

class SharedScheduleChildSummary {
  const SharedScheduleChildSummary({
    required this.firstName,
    required this.lastName,
    required this.condition,
    required this.notes,
    required this.allergies,
  });

  factory SharedScheduleChildSummary.fromJson(Map<String, dynamic> json) {
    final allergiesValue = json['allergies'];
    final allergies = allergiesValue is List
        ? allergiesValue.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList()
        : _parseAllergies(allergiesValue?.toString() ?? '');

    return SharedScheduleChildSummary(
      firstName: _readString(json, ['firstName', 'firstname', 'givenName']),
      lastName: _readString(json, ['lastName', 'surname', 'familyName']),
      condition: _readString(json, ['condition']),
      notes: _readString(json, ['notes', 'importantNotes']),
      allergies: allergies,
    );
  }

  final String firstName;
  final String lastName;
  final String condition;
  final String notes;
  final List<String> allergies;

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Child' : name;
  }
}

class SharedScheduleViewModel {
  const SharedScheduleViewModel({
    required this.apiId,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
    required this.days,
    required this.medicinesById,
    required this.parentId,
    required this.carerFirstName,
    required this.child,
    required this.pdfUrl,
    required this.scheduleUrl,
  });

  factory SharedScheduleViewModel.fromJson(Map<String, dynamic> json) {
    final rawMedicines = json['medicines'];
    final medicines = rawMedicines is List
        ? rawMedicines
            .whereType<Map<String, dynamic>>()
            .map(SharedScheduleMedicineSummary.fromJson)
            .toList(growable: false)
        : const <SharedScheduleMedicineSummary>[];

    final rawDays = json['days'];
    final days = rawDays is List
        ? rawDays
            .whereType<Map<String, dynamic>>()
            .map(SharedScheduleDay.fromJson)
            .toList(growable: false)
        : const <SharedScheduleDay>[];

    final rawFrom = json['dateFrom'];
    final rawTo = json['dateTo'];

    final dateFrom = rawFrom is String ? DateTime.tryParse(rawFrom) : null;
    final dateTo = rawTo is String ? DateTime.tryParse(rawTo) : null;
    final rawChild = json['child'];
    final child = rawChild is Map<String, dynamic>
        ? SharedScheduleChildSummary.fromJson(rawChild)
        : const SharedScheduleChildSummary(
            firstName: '',
            lastName: '',
            condition: '',
            notes: '',
            allergies: <String>[],
          );

    return SharedScheduleViewModel(
      apiId: (json['apiId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      dateFrom: dateFrom ?? DateTime(1970, 1, 1),
      dateTo: dateTo ?? DateTime(1970, 1, 1),
      days: days,
      medicinesById: {for (final med in medicines) med.id: med},
      parentId: (json['parentId'] ?? '').toString(),
      carerFirstName: (json['carerFirstName'] ?? '').toString(),
      child: child,
      pdfUrl: _readString(json, ['pdfUrl', 'pdfURL']),
      scheduleUrl: _readString(json, ['scheduleUrl', 'scheduleURL', 'url']),
    );
  }

  final String apiId;
  final String status;
  final DateTime dateFrom;
  final DateTime dateTo;
  final List<SharedScheduleDay> days;
  final Map<String, SharedScheduleMedicineSummary> medicinesById;
  final String parentId;
  final String carerFirstName;
  final SharedScheduleChildSummary child;
  final String pdfUrl;
  final String scheduleUrl;

  SharedScheduleDay? get today => days.cast<SharedScheduleDay?>().firstWhere(
        (day) => day?.isToday == true,
        orElse: () => null,
      );
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) {
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '';
}

List<String> _parseAllergies(String raw) {
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

abstract class SharedScheduleRepository {
  Future<SharedScheduleAuthResult> exchangeLinkToken(String linkToken);
  Future<SharedScheduleViewModel> fetchSharedSchedule({
    required String apiId,
    required String authToken,
  });
  Future<String> exportSharedSchedulePdf({
    required String apiId,
    required String authToken,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  });
  Future<void> confirmSchedule({
    required String apiId,
    required String authToken,
    required bool approved,
    String? reason,
  });
  Future<void> recordAdministration({
    required String apiId,
    required String authToken,
    required String parentId,
    required String adminBy,
    required DateTime dateTime,
    required bool isAsNeeded,
    required bool skipped,
    String? scheduledItemId,
    String? medicineId,
    String? notes,
  });
}

class HttpSharedScheduleRepository implements SharedScheduleRepository {
  HttpSharedScheduleRepository(this._dio);

  final Dio _dio;

  @override
  Future<SharedScheduleAuthResult> exchangeLinkToken(String linkToken) async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/$linkToken');
    final json = response.data;
    if (json == null) {
      throw StateError('Empty auth response');
    }
    return SharedScheduleAuthResult.fromJson(json);
  }

  @override
  Future<SharedScheduleViewModel> fetchSharedSchedule({
    required String apiId,
    required String authToken,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/sharedSchedule/$apiId',
      options: Options(
        headers: <String, dynamic>{
          'Authorization': 'token $authToken',
        },
      ),
    );

    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('No schedule data returned');
    }

    final first = data.first;
    if (first is! Map<String, dynamic>) {
      throw StateError('Unexpected schedule response shape');
    }

    return SharedScheduleViewModel.fromJson(first);
  }

  @override
  Future<String> exportSharedSchedulePdf({
    required String apiId,
    required String authToken,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/exportSharedSchedulePdf/$apiId',
      data: <String, dynamic>{
        'dateFrom': dateFrom.toIso8601String(),
        'dateTo': dateTo.toIso8601String(),
        'primaryCarerEmail': primaryCarerEmail,
      },
      options: Options(
        headers: <String, dynamic>{'Authorization': 'token $authToken'},
      ),
    );

    final json = response.data;
    if (json == null) {
      throw StateError('Empty PDF export response');
    }
    final pdfUrl = _readString(json, ['pdfUrl', 'pdfURL', 'url']);
    if (pdfUrl.isEmpty) {
      throw StateError('PDF export returned empty url');
    }
    return pdfUrl;
  }

  @override
  Future<void> confirmSchedule({
    required String apiId,
    required String authToken,
    required bool approved,
    String? reason,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/confirm/$apiId',
      data: <String, dynamic>{
        'approved': approved,
        'reason': reason ?? '',
      },
      options: Options(
        headers: <String, dynamic>{'Authorization': 'token $authToken'},
      ),
    );
  }

  @override
  Future<void> recordAdministration({
    required String apiId,
    required String authToken,
    required String parentId,
    required String adminBy,
    required DateTime dateTime,
    required bool isAsNeeded,
    required bool skipped,
    String? scheduledItemId,
    String? medicineId,
    String? notes,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/administration/$apiId',
      data: <String, dynamic>{
        'admin_by': adminBy,
        'dateTimeId': dateTime.toIso8601String(),
        'notes': notes ?? '',
        'isAsNeeded': isAsNeeded,
        'scheduledItemId': scheduledItemId,
        'medicineId': medicineId,
        'skipped': skipped,
        'parentId': parentId,
      },
      options: Options(
        headers: <String, dynamic>{'Authorization': 'token $authToken'},
      ),
    );
  }
}
