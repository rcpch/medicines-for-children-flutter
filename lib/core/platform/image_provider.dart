import 'package:flutter/widgets.dart';

import 'image_provider_stub.dart'
    if (dart.library.io) 'image_provider_io.dart';

ImageProvider? createImageProvider(String path) {
  return resolveImageProvider(path);
}
