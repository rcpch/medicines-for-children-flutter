// Staging entrypoint with staging config.
import 'package:medicines_for_children_flutter/bootstrap.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';

Future<void> main() {
  return bootstrap(
    environment: AppEnvironment.staging,
    envFilePath: 'env/.env.staging',
  );
}
