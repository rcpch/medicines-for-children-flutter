import 'package:firebase_core/firebase_core.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer(this.config);

  final AppConfig config;

  Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.byEnvironment(config.environment),
    );
  }
}
