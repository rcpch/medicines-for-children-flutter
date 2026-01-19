// Default entrypoint selecting config and bootstrapping the app.
import 'package:medicines_for_children_flutter/bootstrap.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';

void main() {
  bootstrap(environment: AppEnvironment.dev, envFilePath: 'env/.env.dev');
}
