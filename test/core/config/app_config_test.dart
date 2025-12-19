import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    setUp(() {
      dotenv.loadFromString(envString: '''
SHARED_SCHEDULE_API_BASE_URL=https://api.test
SHARED_SCHEDULE_API_KEY=test-key
''');
    });

    test('creates config from env', () {
      final config = AppConfig.fromEnvironment(AppEnvironment.dev);

      expect(config.environment, AppEnvironment.dev);
      expect(config.sharedScheduleApiBaseUrl, 'https://api.test');
    });
  });
}
