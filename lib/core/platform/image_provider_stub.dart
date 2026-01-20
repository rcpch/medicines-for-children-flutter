// Stub image provider for unsupported platforms.
import 'package:flutter/widgets.dart';

/// Returns null for platforms without image provider support.
ImageProvider? resolveImageProvider(String path) {
  return null;
}
