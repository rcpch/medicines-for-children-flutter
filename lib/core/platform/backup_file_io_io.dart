// Backup file IO for mobile/desktop platforms.
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

import 'backup_file_io.dart';

/// Creates the backup file IO implementation for IO platforms.
BackupFileIO createBackupFileIO() => _IoBackupFileIO();

class _IoBackupFileIO implements BackupFileIO {
  @override
  /// Saves backup bytes using the native file selector.
  Future<void> saveBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    final location = await getSaveLocation(
      suggestedName: filename,
      acceptedTypeGroups: [
        XTypeGroup(label: 'Backup', extensions: ['mfc']),
      ],
    );
    if (location == null) {
      return;
    }
    final file = File(location.path);
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  /// Opens a file picker and returns the selected file bytes.
  Future<Uint8List?> pickFileBytes({
    required String label,
    required List<String> extensions,
  }) async {
    final file = await openFile(
      acceptedTypeGroups: [XTypeGroup(label: label, extensions: extensions)],
    );
    if (file == null) {
      return null;
    }
    return file.readAsBytes();
  }
}
