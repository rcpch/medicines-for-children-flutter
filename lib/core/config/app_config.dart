import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.sharedScheduleApiBaseUrl,
    required this.sharedScheduleApiKey,
  });

  factory AppConfig.fromEnvironment(AppEnvironment environment) {
    final env = dotenv.env;

    String read(String key) {
      final value = env[key];
      return value == null ? '' : value.trim();
    }

    return AppConfig(
      environment: environment,
      sharedScheduleApiBaseUrl: read('SHARED_SCHEDULE_API_BASE_URL'),
      sharedScheduleApiKey: read('SHARED_SCHEDULE_API_KEY'),
    );
  }

  final AppEnvironment environment;
  final String sharedScheduleApiBaseUrl;
  final String sharedScheduleApiKey;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfig provider must be overridden at bootstrap');
});
