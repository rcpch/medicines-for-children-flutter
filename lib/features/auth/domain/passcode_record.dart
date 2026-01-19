// Passcode record model.
import 'dart:convert';

class PasscodeRecord {
  const PasscodeRecord({
    required this.saltBase64,
    required this.iterations,
    required this.hashBase64,
  });

  factory PasscodeRecord.fromJson(Map<String, dynamic> json) {
    return PasscodeRecord(
      saltBase64: (json['saltBase64'] ?? '').toString(),
      iterations: (json['iterations'] as num?)?.toInt() ?? 0,
      hashBase64: (json['hashBase64'] ?? '').toString(),
    );
  }

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

  String toRawJson() => jsonEncode(toJson());

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

