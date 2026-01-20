// Platform-agnostic image picker/provider interface.
import 'package:flutter/widgets.dart';

import 'image_provider_stub.dart' if (dart.library.io) 'image_provider_io.dart';

// Returns an ImageProvider for the given path, if supported.
ImageProvider? createImageProvider(String path) {
  return resolveImageProvider(path);
}
