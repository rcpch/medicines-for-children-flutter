import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('stores and retrieves active child id per profile', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dataSource = ActiveChildLocalDataSource(prefs);

    expect(dataSource.readActiveChildId('profile-1'), isNull);

    await dataSource.writeActiveChildId('profile-1', 'child-1');
    await dataSource.writeActiveChildId('profile-2', 'child-2');

    expect(dataSource.readActiveChildId('profile-1'), 'child-1');
    expect(dataSource.readActiveChildId('profile-2'), 'child-2');

    await dataSource.writeActiveChildId('profile-1', null);
    expect(dataSource.readActiveChildId('profile-1'), isNull);
  });
}
