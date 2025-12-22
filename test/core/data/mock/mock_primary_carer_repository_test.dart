import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/mock/mock_data_source.dart';

void main() {
  test('mock repository returns populated child data', () async {
    final repository = MockPrimaryCarerRepository();
    final carer = await repository.fetchPrimaryCarer();

    expect(carer.children, isNotEmpty);
    final child = carer.children.first;
    expect(child.medicines, isNotEmpty);
    expect(child.schedules.first.administrations, isNotEmpty);
  });
}
