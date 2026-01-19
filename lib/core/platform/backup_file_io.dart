// Platform-agnostic backup file IO interface.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup_file_io_stub.dart'
    if (dart.library.html) 'backup_file_io_web.dart'
    if (dart.library.io) 'backup_file_io_io.dart';

abstract class BackupFileIO {
  Future<void> saveBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  });

  Future<Uint8List?> pickFileBytes({
    required String label,
    required List<String> extensions,
  });
}

final backupFileIOProvider = Provider<BackupFileIO>((ref) {
  return createBackupFileIO();
});

