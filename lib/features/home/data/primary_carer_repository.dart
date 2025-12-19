import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';

abstract class PrimaryCarerRepository {
  Future<PrimaryCarer> fetchPrimaryCarer();
}

class MockPrimaryCarerRepository implements PrimaryCarerRepository {
  @override
  Future<PrimaryCarer> fetchPrimaryCarer() async {
    final now = DateTime.now();
    final amoxicillin = Medicine(
      id: 'med-amo',
      name: 'Amoxicillin',
      alias: 'Amoxil',
      type: MedicineType.everyday,
      dose: '5',
      doseUnit: 'ml',
      route: 'oral',
      frequency: 'Twice daily',
      notes: 'Give after breakfast and dinner',
      photoUrl: null,
    );

    final inhaler = Medicine(
      id: 'med-salbutamol',
      name: 'Salbutamol',
      alias: 'Blue inhaler',
      type: MedicineType.asNeeded,
      dose: '2',
      doseUnit: 'puffs',
      route: 'inhaled',
      frequency: 'As needed',
      notes: 'Use spacer provided',
    );

    final schedule = MedicineSchedule(
      id: 'sched-amo-morning-evening',
      medicineId: amoxicillin.id,
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now.add(const Duration(days: 7)),
      times: const ['08:00', '19:00'],
      weekdaysActive: List<bool>.filled(7, true),
      administrations: [
        Administration(
          id: 'admin-1',
          dateTime: now.subtract(const Duration(hours: 12)),
          status: AdministrationStatus.given,
          isAsNeeded: false,
          administeredBy: 'Primary carer',
          notes: 'Taken with juice',
        ),
      ],
    );

    final asNeededSchedule = AsNeededSchedule(
      id: 'asneeded-salbutamol',
      medicineId: inhaler.id,
      administrations: [
        Administration(
          id: 'admin-2',
          dateTime: now.subtract(const Duration(days: 1, hours: 3)),
          status: AdministrationStatus.given,
          isAsNeeded: true,
          administeredBy: 'School nurse',
          notes: 'Used after PE',
        ),
      ],
    );

    final child = Child(
      id: 'child-001',
      firstName: 'Ava',
      lastName: 'Taylor',
      dateOfBirth: DateTime(now.year - 8, now.month, now.day),
      condition: 'Asthma',
      allergies: const ['Penicillin'],
      medicines: [amoxicillin, inhaler],
      schedules: [schedule],
      asNeededSchedules: [asNeededSchedule],
    );

    return PrimaryCarer(
      id: 'pc-001',
      firstName: 'Emma',
      lastName: 'Taylor',
      email: 'emma@example.com',
      relationshipToChild: 'Mum',
      children: [child],
    );
  }
}

final primaryCarerRepositoryProvider = Provider<PrimaryCarerRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.enableFirebase) {
    return MockPrimaryCarerRepository();
  }
  return FirebasePrimaryCarerRepository(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class FirebasePrimaryCarerRepository implements PrimaryCarerRepository {
  FirebasePrimaryCarerRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<PrimaryCarer> fetchPrimaryCarer() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError('Authenticated user has no email');
    }

    final userRef = _firestore.collection('user').doc(email);
    final userSnapshot = await userRef.get();
    final userData = userSnapshot.data();
    if (!userSnapshot.exists || userData == null) {
      throw StateError('No profile data found for $email');
    }

    final childrenSnapshot = await userRef.collection('children').get();
    final children = await Future.wait(
      childrenSnapshot.docs.map(
        (childDoc) => _readChild(userRef: userRef, childDoc: childDoc),
      ),
    );

    return PrimaryCarer(
      id: userSnapshot.id,
      firstName: _readString(userData, 'firstname'),
      lastName: _readString(userData, 'surname'),
      email: email,
      relationshipToChild: _readString(userData, 'relationship', defaultValue: ''),
      children: children,
    );
  }

  Future<Child> _readChild({
    required DocumentReference<Map<String, dynamic>> userRef,
    required QueryDocumentSnapshot<Map<String, dynamic>> childDoc,
  }) async {
    final childData = childDoc.data();
    final childRef = userRef.collection('children').doc(childDoc.id);

    final medicinesFuture = childRef.collection('medicines').get();
    final schedulesFuture = childRef.collection('schedule').get();
    final asNeededFuture = childRef.collection('asneeded').get();

    final medicinesSnapshot = await medicinesFuture;
    final medicines = medicinesSnapshot.docs.map(_readMedicine).toList(growable: false);

    final scheduleSnapshot = await schedulesFuture;
    final schedules = await Future.wait(
      scheduleSnapshot.docs.map(
        (scheduleDoc) => _readMedicineSchedule(childRef: childRef, scheduleDoc: scheduleDoc),
      ),
    );

    final asNeededSnapshot = await asNeededFuture;
    final asNeededSchedules = await Future.wait(
      asNeededSnapshot.docs.map(
        (asNeededDoc) => _readAsNeededSchedule(childRef: childRef, asNeededDoc: asNeededDoc),
      ),
    );

    return Child(
      id: childDoc.id,
      firstName: _readString(childData, 'firstname'),
      lastName: _readString(childData, 'surname', defaultValue: ''),
      dateOfBirth: _parseDate(childData['dob']) ?? DateTime(1970, 1, 1),
      condition: _readString(childData, 'condition', defaultValue: ''),
      allergies: _parseAllergies(childData['allergies']),
      medicines: medicines,
      schedules: schedules,
      asNeededSchedules: asNeededSchedules,
    );
  }

  Medicine _readMedicine(QueryDocumentSnapshot<Map<String, dynamic>> medicineDoc) {
    final data = medicineDoc.data();

    final name = _readString(data, 'name', defaultValue: '');
    final alias = _readString(data, 'known_as', defaultValue: name);
    final route = _readString(data, 'route', defaultValue: '');
    final frequency = _readString(data, 'frequency', defaultValue: '');
    final dose = _readString(data, 'amount', defaultValue: _readString(data, 'dosage', defaultValue: ''));
    final doseUnit = _readString(data, 'measure', defaultValue: '');
    final notes = _readNullableString(data, 'notes');
    final photo1 = _readNullableString(data, 'photo1');

    return Medicine(
      id: medicineDoc.id,
      name: name,
      alias: alias,
      type: _parseMedicineType(data['type']?.toString()),
      dose: dose,
      doseUnit: doseUnit,
      route: route,
      frequency: frequency,
      notes: notes,
      photoUrl: (photo1 == null || photo1.trim().isEmpty) ? null : photo1,
    );
  }

  Future<MedicineSchedule> _readMedicineSchedule({
    required DocumentReference<Map<String, dynamic>> childRef,
    required QueryDocumentSnapshot<Map<String, dynamic>> scheduleDoc,
  }) async {
    final data = scheduleDoc.data();

    final times = _readStringList(data['times']);
    final weekdaysActive = _readBoolList(data['days']);

    final administrationsSnapshot = await childRef
        .collection('administered')
        .doc(scheduleDoc.id)
        .collection('administrations')
        .get();

    final administrations = <Administration>[];
    for (final adminDoc in administrationsSnapshot.docs) {
      administrations.add(_readAdministration(adminDoc, isAsNeeded: false));
    }

    return MedicineSchedule(
      id: scheduleDoc.id,
      medicineId: _readString(data, 'medicine', defaultValue: ''),
      startDate: _parseDate(data['startDate']) ?? DateTime(1970, 1, 1),
      endDate: _parseDate(data['endDate']) ?? DateTime(2100, 1, 1),
      times: times,
      weekdaysActive: weekdaysActive,
      administrations: administrations,
    );
  }

  Future<AsNeededSchedule> _readAsNeededSchedule({
    required DocumentReference<Map<String, dynamic>> childRef,
    required QueryDocumentSnapshot<Map<String, dynamic>> asNeededDoc,
  }) async {
    final administrationsSnapshot = await childRef
        .collection('asneeded')
        .doc(asNeededDoc.id)
        .collection('administrations')
        .get();

    final administrations = <Administration>[];
    for (final adminDoc in administrationsSnapshot.docs) {
      administrations.add(_readAdministration(adminDoc, isAsNeeded: true));
    }

    return AsNeededSchedule(
      id: asNeededDoc.id,
      medicineId: asNeededDoc.id,
      administrations: administrations,
    );
  }

  Administration _readAdministration(
    QueryDocumentSnapshot<Map<String, dynamic>> adminDoc, {
    required bool isAsNeeded,
  }) {
    final data = adminDoc.data();

    final timestamp = data['administered_timestamp'];
    final dateTime = _parseDate(timestamp) ?? _parseAdministrationId(adminDoc.id) ?? DateTime(1970, 1, 1);

    final skipped = (data['skipped'] as bool?) ?? false;
    final status = skipped ? AdministrationStatus.skipped : AdministrationStatus.given;

    return Administration(
      id: adminDoc.id,
      dateTime: dateTime,
      status: status,
      isAsNeeded: isAsNeeded,
      administeredBy: _readNullableString(data, 'admin_by'),
      notes: _readNullableString(data, 'notes'),
    );
  }

  DateTime? _parseAdministrationId(String id) {
    final sanitized = id.trim().toUpperCase();
    final patterns = <String>[
      'yyyy-MM-dd h:mma',
      'yyyy-MM-dd hh:mma',
      'yyyy-MM-dd H:mm',
      'yyyy-MM-dd HH:mm',
    ];

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(sanitized);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  DateTime? _parseDate(dynamic rawValue) {
    if (rawValue == null) {
      return null;
    }
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }
    if (rawValue is DateTime) {
      return rawValue;
    }
    if (rawValue is String) {
      final trimmed = rawValue.trim();
      final direct = DateTime.tryParse(trimmed);
      if (direct != null) {
        return direct;
      }
      final patterns = <String>[
        'dd/MM/yyyy',
        'd/M/yyyy',
        'yyyy/MM/dd',
        'yyyy-MM-dd',
        'yyyy-MM-dd HH:mm',
        'yyyy-MM-dd H:mm',
      ];
      for (final pattern in patterns) {
        try {
          return DateFormat(pattern).parseStrict(trimmed);
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  List<String> _parseAllergies(dynamic rawValue) {
    if (rawValue == null) {
      return const [];
    }
    if (rawValue is List) {
      return rawValue
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }
    final asString = rawValue.toString();
    return asString
        .split(RegExp(r'[\n,]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _readStringList(dynamic rawValue) {
    if (rawValue is List) {
      return rawValue.map((value) => value.toString()).toList(growable: false);
    }
    return const [];
  }

  List<bool> _readBoolList(dynamic rawValue) {
    if (rawValue is List) {
      return rawValue.map((value) => value == true).toList(growable: false);
    }
    return const [];
  }

  String _readString(
    Map<String, dynamic> data,
    String key, {
    String defaultValue = '',
  }) {
    final value = data[key];
    if (value == null) {
      return defaultValue;
    }
    final normalized = value.toString();
    if (normalized.isEmpty) {
      return defaultValue;
    }
    return normalized;
  }

  String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) {
      return null;
    }
    final normalized = value.toString();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  MedicineType _parseMedicineType(String? rawValue) {
    final normalized = (rawValue ?? '').toLowerCase().trim();

    if (normalized.contains('both')) {
      return MedicineType.both;
    }

    if (normalized.contains('asneeded') ||
        normalized.contains('as needed') ||
        normalized.contains('as-needed')) {
      return MedicineType.asNeeded;
    }

    if (normalized.contains('everyday') ||
        normalized.contains('daily') ||
        normalized.contains('regular')) {
      return MedicineType.everyday;
    }

    return MedicineType.everyday;
  }
}
