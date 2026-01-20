// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
// Backup file IO for web platform.

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

import 'backup_file_io.dart';

/// Creates the backup file IO implementation for web.
BackupFileIO createBackupFileIO() => _WebBackupFileIO();

class _WebBackupFileIO implements BackupFileIO {
  @override
  /// Saves backup bytes via a browser download.
  Future<void> saveBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  @override
  /// Opens a browser file picker and returns the selected file bytes.
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
