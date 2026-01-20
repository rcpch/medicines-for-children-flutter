// Onboarding profile model.
import 'dart:convert';

// Captures primary carer details collected during onboarding.
class CarerProfile {
  const CarerProfile({
    required this.firstName,
    required this.lastName,
    required this.relationshipToChild,
    required this.phoneNumber,
    required this.email,
  });

  // Builds a carer profile from stored JSON data.
  factory CarerProfile.fromJson(Map<String, dynamic> json) {
    return CarerProfile(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      relationshipToChild: json['relationshipToChild'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  // Serializes the carer profile to JSON.
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'relationshipToChild': relationshipToChild,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  final String firstName;
  final String lastName;
  final String relationshipToChild;
  final String phoneNumber;
  final String email;
}

// Captures child details collected during onboarding.
class ChildProfile {
  const ChildProfile({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.condition,
    required this.allergies,
    required this.notes,
  });

  // Builds a child profile from stored JSON data.
  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.tryParse(json['dateOfBirth'] as String),
      condition: json['condition'] as String? ?? '',
      allergies: (json['allergies'] as List?)?.cast<String>() ?? const [],
      notes: json['notes'] as String? ?? '',
    );
  }

  // Serializes the child profile to JSON.
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'condition': condition,
      'allergies': allergies,
      'notes': notes,
    };
  }

  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String condition;
  final List<String> allergies;
  final String notes;
}

// Bundles carer and child profiles for onboarding persistence.
class OnboardingProfile {
  const OnboardingProfile({required this.carer, required this.child});

  // Builds an onboarding profile from a decoded map.
  factory OnboardingProfile.fromMap(Map<String, dynamic> json) {
    return OnboardingProfile(
      carer: CarerProfile.fromJson(
        json['carer'] as Map<String, dynamic>? ?? const {},
      ),
      child: ChildProfile.fromJson(
        json['child'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  // Parses a JSON string into an onboarding profile.
  factory OnboardingProfile.fromJson(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      return OnboardingProfile(
        carer: CarerProfile.fromJson(const {}),
        child: ChildProfile.fromJson(const {}),
      );
    }
    return OnboardingProfile.fromMap(decoded);
  }

  // Serializes the profile into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {'carer': carer.toJson(), 'child': child.toJson()};
  }

  // Serializes the profile to a JSON string.
  String toJson() => jsonEncode(toMap());

  final CarerProfile carer;
  final ChildProfile child;
}
