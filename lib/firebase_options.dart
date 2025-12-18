// ignore_for_file: public_member_api_docs

import 'package:firebase_core/firebase_core.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions byEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.dev:
        return _dev;
      case AppEnvironment.staging:
        return _staging;
      case AppEnvironment.prod:
        return _prod;
    }
  }

  static const FirebaseOptions _dev = FirebaseOptions(
    apiKey: 'DEV_API_KEY_PLACEHOLDER',
    appId: '1:000000000000:android:devappid',
    messagingSenderId: '000000000000',
    projectId: 'your-dev-project-id',
    storageBucket: 'your-dev-bucket.appspot.com',
  );

  static const FirebaseOptions _staging = FirebaseOptions(
    apiKey: 'STAGING_API_KEY_PLACEHOLDER',
    appId: '1:000000000000:android:stagingappid',
    messagingSenderId: '000000000000',
    projectId: 'your-staging-project-id',
    storageBucket: 'your-staging-bucket.appspot.com',
  );

  static const FirebaseOptions _prod = FirebaseOptions(
    apiKey: 'PROD_API_KEY_PLACEHOLDER',
    appId: '1:000000000000:android:prodappid',
    messagingSenderId: '000000000000',
    projectId: 'your-prod-project-id',
    storageBucket: 'your-prod-bucket.appspot.com',
  );
}
