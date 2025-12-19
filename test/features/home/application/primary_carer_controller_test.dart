import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/primary_carer_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/data/primary_carer_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrimaryCarerController', () {
    late ProviderContainer container;
    late TestPrimaryCarerRepository repository;
    late SharedPreferences preferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      repository = TestPrimaryCarerRepository(samplePrimaryCarer());
      container = ProviderContainer(
        overrides: [
          primaryCarerRepositoryProvider.overrideWithValue(repository),
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
      );
      addTearDown(container.dispose);
    });

    test('hydrates state from cached data on startup', () async {
      final sample = samplePrimaryCarer();
      await preferences.setString(
        PrimaryCarerLocalDataSource.cacheKey,
        jsonEncode(sample.toJson()),
      );

      final hydratedContainer = ProviderContainer(
        overrides: [
          primaryCarerRepositoryProvider.overrideWithValue(repository),
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
      );
      addTearDown(hydratedContainer.dispose);

      await Future<void>.delayed(Duration.zero);
      final state = hydratedContainer.read(primaryCarerControllerProvider);
      expect(state.carer, isNotNull);
      expect(state.carer!.firstName, sample.firstName);
      expect(state.isStale, isTrue);
    });

    test('refresh fetches latest data and caches it', () async {
      final controller =
          container.read(primaryCarerControllerProvider.notifier);

      await controller.refresh();
      final state = container.read(primaryCarerControllerProvider);

      expect(state.carer, isNotNull);
      expect(state.isLoading, isFalse);
      expect(state.isStale, isFalse);
        final cachedJson =
          preferences.getString(PrimaryCarerLocalDataSource.cacheKey);
      expect(cachedJson, isNotNull);
    });

    test('clear removes cache and resets state', () async {
      final controller =
          container.read(primaryCarerControllerProvider.notifier);
      await controller.refresh();

      await controller.clear();
      final state = container.read(primaryCarerControllerProvider);
      expect(state.carer, isNull);
      expect(preferences.getString(PrimaryCarerLocalDataSource.cacheKey), isNull);
    });
  });
}

PrimaryCarer samplePrimaryCarer() {
  final medicine = Medicine(
    id: 'med-1',
    name: 'Amoxicillin',
    alias: 'Amoxil',
    type: MedicineType.everyday,
    dose: '5',
    doseUnit: 'ml',
    route: 'oral',
    frequency: 'Twice daily',
    notes: 'Give after meals',
  );

  final child = Child(
    id: 'child-1',
    firstName: 'Ava',
    lastName: 'Taylor',
    dateOfBirth: DateTime(2018, 5, 12),
    condition: 'Asthma',
    allergies: const ['Penicillin'],
    medicines: [medicine],
    schedules: [
      MedicineSchedule(
        id: 'sched-1',
        medicineId: medicine.id,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        times: const ['08:00', '20:00'],
        weekdaysActive: List<bool>.filled(7, true),
        administrations: const [],
      ),
    ],
    asNeededSchedules: const [],
  );

  return PrimaryCarer(
    id: 'pc-1',
    firstName: 'Emma',
    lastName: 'Taylor',
    email: 'emma@example.com',
    relationshipToChild: 'Mum',
    children: [child],
  );
}

class TestPrimaryCarerRepository implements PrimaryCarerRepository {
  TestPrimaryCarerRepository(this._carer);

  PrimaryCarer _carer;
  bool shouldThrow = false;

  @override
  Future<PrimaryCarer> fetchPrimaryCarer() async {
    if (shouldThrow) {
      throw Exception('error');
    }
    return _carer;
  }
}
