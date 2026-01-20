// Platform-agnostic backup file IO interface.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup_file_io_stub.dart'
    if (dart.library.html) 'backup_file_io_web.dart'
    if (dart.library.io) 'backup_file_io_io.dart';

/// Platform abstraction for saving and picking backup files.
abstract class BackupFileIO {
  /// Persists backup bytes to a user-selected location.
  Future<void> saveBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  });

  /// Prompts the user to select a backup file and returns its bytes.
  Future<Uint8List?> pickFileBytes({
    required String label,
    required List<String> extensions,
  });
}

/// Provides the platform-specific backup file IO implementation.
final backupFileIOProvider = Provider<BackupFileIO>((ref) {
  return createBackupFileIO();
});
