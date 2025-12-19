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

    return SharedScheduleViewModel(
      apiId: (json['apiId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      dateFrom: dateFrom ?? DateTime(1970, 1, 1),
      dateTo: dateTo ?? DateTime(1970, 1, 1),
      days: days,
      medicinesById: {for (final med in medicines) med.id: med},
      parentId: (json['parentId'] ?? '').toString(),
      carerFirstName: (json['carerFirstName'] ?? '').toString(),
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

  SharedScheduleDay? get today => days.cast<SharedScheduleDay?>().firstWhere(
        (day) => day?.isToday == true,
        orElse: () => null,
      );
}

abstract class SharedScheduleRepository {
  Future<SharedScheduleAuthResult> exchangeLinkToken(String linkToken);
  Future<SharedScheduleViewModel> fetchSharedSchedule({
    required String apiId,
    required String authToken,
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
