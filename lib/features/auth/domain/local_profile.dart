import 'dart:convert';

class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.name,
    required this.displayName,
    required this.createdAt,
    required this.hasPasscode,
  });

  factory LocalProfile.fromJson(Map<String, dynamic> json) {
    return LocalProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      hasPasscode: json['hasPasscode'] == true,
    );
  }

  static List<LocalProfile> listFromRawJson(String raw) {
    if (raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map((value) => value.cast<String, dynamic>())
        .map(LocalProfile.fromJson)
        .toList(growable: false);
  }

  static String listToRawJson(List<LocalProfile> profiles) {
    return jsonEncode(profiles.map((profile) => profile.toJson()).toList(growable: false));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'hasPasscode': hasPasscode,
    };
  }

  LocalProfile copyWith({
    String? name,
    String? displayName,
    bool? hasPasscode,
  }) {
    return LocalProfile(
      id: id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      hasPasscode: hasPasscode ?? this.hasPasscode,
    );
  }

  final String id;
  final String name;
  final String displayName;
  final DateTime createdAt;
  final bool hasPasscode;
}

