// Primary carer domain model.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';

part 'primary_carer.freezed.dart';
part 'primary_carer.g.dart';

// Represents a primary carer and their children.
@freezed
abstract class PrimaryCarer with _$PrimaryCarer {
  const factory PrimaryCarer({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String relationshipToChild,
    required List<Child> children,
  }) = _PrimaryCarer;

  // Builds a primary carer model from a JSON map.
  factory PrimaryCarer.fromJson(Map<String, dynamic> json) =>
      _$PrimaryCarerFromJson(json);
}
