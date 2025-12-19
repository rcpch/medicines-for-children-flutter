import 'dart:convert';

class CarerProfile {
  const CarerProfile({
    required this.firstName,
    required this.lastName,
    required this.relationshipToChild,
    required this.phoneNumber,
    required this.email,
  });

  factory CarerProfile.fromJson(Map<String, dynamic> json) {
    return CarerProfile(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      relationshipToChild: json['relationshipToChild'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

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

class ChildProfile {
  const ChildProfile({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.condition,
    required this.allergies,
    required this.notes,
  });

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

class OnboardingProfile {
  const OnboardingProfile({
    required this.carer,
    required this.child,
  });

  factory OnboardingProfile.fromJson(String rawJson) {
    final Map<String, dynamic> decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return OnboardingProfile(
      carer: CarerProfile.fromJson(decoded['carer'] as Map<String, dynamic>? ?? const {}),
      child: ChildProfile.fromJson(decoded['child'] as Map<String, dynamic>? ?? const {}),
    );
  }

  String toJson() {
    return jsonEncode({
      'carer': carer.toJson(),
      'child': child.toJson(),
    });
  }

  final CarerProfile carer;
  final ChildProfile child;
}
