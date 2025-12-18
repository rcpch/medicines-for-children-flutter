import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.firebaseProjectId,
    required this.firebaseStorageBucket,
    required this.firebaseMessagingSenderId,
    required this.firebaseAndroidAppId,
    required this.firebaseIosAppId,
    required this.firebaseWebAppId,
    required this.sharedScheduleApiBaseUrl,
    required this.sharedScheduleApiKey,
  });

  factory AppConfig.fromEnvironment(AppEnvironment environment) {
    final env = dotenv.env;

    String read(String key) {
      final value = env[key];
      if (value == null || value.isEmpty) {
        throw StateError('Missing required environment value: $key');
      }
      return value;
    }

    return AppConfig(
      environment: environment,
      firebaseProjectId: read('FIREBASE_PROJECT_ID'),
      firebaseStorageBucket: read('FIREBASE_STORAGE_BUCKET'),
      firebaseMessagingSenderId: read('FIREBASE_MESSAGING_SENDER_ID'),
      firebaseAndroidAppId: read('FIREBASE_APP_ID'),
      firebaseIosAppId: read('FIREBASE_IOS_APP_ID'),
      firebaseWebAppId: read('FIREBASE_WEB_APP_ID'),
      sharedScheduleApiBaseUrl: read('SHARED_SCHEDULE_API_BASE_URL'),
      sharedScheduleApiKey: read('SHARED_SCHEDULE_API_KEY'),
    );
  }

  final AppEnvironment environment;
  final String firebaseProjectId;
  final String firebaseStorageBucket;
  final String firebaseMessagingSenderId;
  final String firebaseAndroidAppId;
  final String firebaseIosAppId;
  final String firebaseWebAppId;
  final String sharedScheduleApiBaseUrl;
  final String sharedScheduleApiKey;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfig provider must be overridden at bootstrap');
});
