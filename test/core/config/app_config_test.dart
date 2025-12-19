import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    setUp(() {
      dotenv.testLoad(fileInput: '''
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-bucket
FIREBASE_APP_ID=android-app
FIREBASE_MESSAGING_SENDER_ID=123
FIREBASE_IOS_APP_ID=ios-app
FIREBASE_WEB_APP_ID=web-app
SHARED_SCHEDULE_API_BASE_URL=https://api.test
SHARED_SCHEDULE_API_KEY=test-key
ENABLE_FIREBASE=true
''');
    });

    test('creates config from env', () {
      final config = AppConfig.fromEnvironment(AppEnvironment.dev);

      expect(config.environment, AppEnvironment.dev);
      expect(config.firebaseProjectId, 'test-project');
      expect(config.sharedScheduleApiBaseUrl, 'https://api.test');
      expect(config.enableFirebase, isTrue);
    });
  });
}
