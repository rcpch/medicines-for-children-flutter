// Stub backup file IO for unsupported platforms.
import 'dart:typed_data';

import 'backup_file_io.dart';

BackupFileIO createBackupFileIO() => _UnsupportedBackupFileIO();

class _UnsupportedBackupFileIO implements BackupFileIO {
  @override
  Future<void> saveBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    throw UnsupportedError('Backup file saving is not supported on this platform.');
  }

  @override
  Future<Uint8List?> pickFileBytes({
    required String label,
    required List<String> extensions,
  }) async {
    throw UnsupportedError('Backup file picking is not supported on this platform.');
  }
}

