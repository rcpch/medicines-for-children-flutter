// Passcode record model.
import 'dart:convert';

// Stores hashed passcode metadata for a profile.
class PasscodeRecord {
  const PasscodeRecord({
    required this.saltBase64,
    required this.iterations,
    required this.hashBase64,
  });

  // Builds a passcode record from a JSON map.
  factory PasscodeRecord.fromJson(Map<String, dynamic> json) {
    return PasscodeRecord(
      saltBase64: (json['saltBase64'] ?? '').toString(),
      iterations: (json['iterations'] as num?)?.toInt() ?? 0,
      hashBase64: (json['hashBase64'] ?? '').toString(),
    );
  }

  // Parses a raw JSON string into a passcode record.
  static PasscodeRecord? fromRawJson(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return PasscodeRecord.fromJson(decoded);
  }

  // Serializes the record to a raw JSON string.
  String toRawJson() => jsonEncode(toJson());

  // Converts the record to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'saltBase64': saltBase64,
      'iterations': iterations,
      'hashBase64': hashBase64,
    };
  }

  final String saltBase64;
  final int iterations;
  final String hashBase64;
}
