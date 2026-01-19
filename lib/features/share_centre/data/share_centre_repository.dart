// Share Centre data access layer.
import 'package:dio/dio.dart';

class ShareCentreSchedule {
  const ShareCentreSchedule({
    required this.apiId,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
    required this.isDigital,
    required this.isDeleted,
    required this.carerEmail,
    required this.carerName,
    required this.scheduleUrl,
    required this.pdfUrl,
    required this.notes,
  });

  factory ShareCentreSchedule.fromJson(Map<String, dynamic> json) {
    final apiId = _readString(json, ['apiId', 'api_id', 'id', 'scheduleId']);
    final status = _readString(json, ['status', 'state']);
    final dateFrom = _parseDate(json['dateFrom'] ?? json['date_from'] ?? json['dateFromObj']);
    final dateTo = _parseDate(json['dateTo'] ?? json['date_to'] ?? json['dateToObj']);
    final isDigital = _parseBool(json['digital'] ?? json['isDigital'] ?? json['is_digital']);
    final isDeleted = _parseBool(json['deleted'] ?? json['isDeleted'] ?? json['is_deleted']);
    final carerEmail = _readString(json, ['email', 'carerEmail', 'emailAddress', 'carer_email']);
    final carerName = _parseCarerName(json['carer'] ?? json['secondaryCarer'] ?? json);
    final scheduleUrl = _readString(json, ['scheduleUrl', 'scheduleURL', 'url']);
    final pdfUrl = _readString(json, ['pdfUrl', 'pdfURL']);
    final notes = _readString(json, ['notes', 'note']);

    return ShareCentreSchedule(
      apiId: apiId,
      status: status,
      dateFrom: dateFrom ?? DateTime(1970, 1, 1),
      dateTo: dateTo ?? DateTime(1970, 1, 1),
      isDigital: isDigital,
      isDeleted: isDeleted,
      carerEmail: carerEmail,
      carerName: carerName,
      scheduleUrl: scheduleUrl,
      pdfUrl: pdfUrl,
      notes: notes,
    );
  }

  final String apiId;
  final String status;
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool isDigital;
  final bool isDeleted;
  final String carerEmail;
  final String carerName;
  final String scheduleUrl;
  final String pdfUrl;
  final String notes;

  String get displayCarer {
    if (carerName.isNotEmpty) {
      return carerName;
    }
    if (carerEmail.isNotEmpty) {
      return carerEmail;
    }
    return 'Shared carer';
  }
}

abstract class ShareCentreRepository {
  Future<List<ShareCentreSchedule>> fetchSharedSchedules({required String childId});
  Future<ShareCentreSchedule> createSharedSchedule({
    required String childId,
    required String email,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool digital,
    String? notes,
  });
  Future<String> exportSchedulePdf({
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  });
  Future<ShareCentreSchedule> updateSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    bool? digital,
    String? notes,
    bool? deleted,
  });
  Future<ShareCentreSchedule> endSharedSchedule({required String apiId});
  Future<ShareCentreSchedule> deleteSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
  });
}

class HttpShareCentreRepository implements ShareCentreRepository {
  HttpShareCentreRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ShareCentreSchedule>> fetchSharedSchedules({required String childId}) async {
    final response = await _dio.post<dynamic>(
      '/mySharedSchedules',
      data: <String, dynamic>{
        'childId': childId,
      },
    );

    final data = response.data;
    final rawList = _extractScheduleList(data);

    return rawList.map(ShareCentreSchedule.fromJson).toList(growable: false);
  }

  @override
  Future<ShareCentreSchedule> createSharedSchedule({
    required String childId,
    required String email,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool digital,
    String? notes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sharedSchedule',
      data: <String, dynamic>{
        'childId': childId,
        'email': email,
        'digital': digital,
        'notes': notes ?? '',
        'dateFrom': _toDateMap(dateFrom),
        'dateTo': _toDateMap(dateTo),
      },
    );

    final json = response.data;
    if (json == null) {
      throw StateError('Empty shared schedule response');
    }
    return ShareCentreSchedule.fromJson(json);
  }

  @override
  Future<String> exportSchedulePdf({
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/exportSchedulePdf',
      data: <String, dynamic>{
        'childId': childId,
        'primaryCarerEmail': primaryCarerEmail,
        'dateFrom': dateFrom.toIso8601String(),
        'dateTo': dateTo.toIso8601String(),
      },
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
  Future<ShareCentreSchedule> updateSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    bool? digital,
    String? notes,
    bool? deleted,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/sharedSchedule/$apiId',
      data: <String, dynamic>{
        'childId': childId,
        'dateFrom': _toDateMap(dateFrom),
        'dateTo': _toDateMap(dateTo),
        if (digital != null) 'digital': digital,
        if (notes != null) 'notes': notes,
        if (deleted != null) 'deleted': deleted,
      },
    );

    final json = response.data;
    if (json == null) {
      throw StateError('Empty shared schedule update response');
    }
    return ShareCentreSchedule.fromJson(json);
  }

  @override
  Future<ShareCentreSchedule> endSharedSchedule({required String apiId}) async {
    final response = await _dio.get<Map<String, dynamic>>('/sharedSchedule/end/$apiId');
    final json = response.data;
    if (json == null) {
      throw StateError('Empty shared schedule end response');
    }
    return ShareCentreSchedule.fromJson(json);
  }

  @override
  Future<ShareCentreSchedule> deleteSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    return updateSharedSchedule(
      apiId: apiId,
      childId: childId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      deleted: true,
    );
  }
}

List<Map<String, dynamic>> _extractScheduleList(dynamic data) {
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }
  if (data is Map<String, dynamic>) {
    final nested = data['sharedSchedules'] ?? data['schedules'] ?? data['items'];
    if (nested is List) {
      return nested.whereType<Map<String, dynamic>>().toList(growable: false);
    }
  }
  return const <Map<String, dynamic>>[];
}

Map<String, int> _toDateMap(DateTime date) {
  return <String, int>{
    'day': date.day,
    'month': date.month,
    'year': date.year,
  };
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

String _parseCarerName(dynamic source) {
  if (source is Map<String, dynamic>) {
    final firstName = _readString(source, ['firstName', 'first_name', 'givenName']);
    final lastName = _readString(source, ['lastName', 'last_name', 'familyName']);
    final combined = [firstName, lastName].where((value) => value.trim().isNotEmpty).join(' ');
    return combined.trim();
  }
  if (source is String) {
    return source;
  }
  return '';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is num) {
    final intValue = value.toInt();
    if (intValue > 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(intValue);
    }
    if (intValue > 1000000000) {
      return DateTime.fromMillisecondsSinceEpoch(intValue * 1000);
    }
    return null;
  }
  if (value is Map) {
    final year = _readInt(value, ['year', 'yyyy']);
    final month = _readInt(value, ['month', 'mm']);
    final day = _readInt(value, ['day', 'dd']);
    if (year != null && month != null && day != null) {
      return DateTime(year, month, day);
    }
  }
  return null;
}

int? _readInt(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) {
      continue;
    }
    if (value is int) {
      return value;
    }
    final parsed = int.tryParse(value.toString());
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

bool _parseBool(dynamic value) {
  if (value == null) {
    return false;
  }
  if (value is bool) {
    return value;
  }
  final text = value.toString().toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}
