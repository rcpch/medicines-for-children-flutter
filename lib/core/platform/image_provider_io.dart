// Image provider implementation for IO platforms.
import 'dart:io';

import 'package:flutter/widgets.dart';

/// Resolves a file or network image provider for IO platforms.
ImageProvider? resolveImageProvider(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return NetworkImage(trimmed);
  }

  final file = File(trimmed);
  if (!file.existsSync()) {
    return null;
  }
  return FileImage(file);
}
