import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/app/app.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/firebase/firebase_initializer.dart';

Future<void> bootstrap({
  required AppEnvironment environment,
  required String envFilePath,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: envFilePath, mergeWith: const {});
  final config = AppConfig.fromEnvironment(environment);

  await FirebaseInitializer(config).initialize();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const MedicinesApp(),
    ),
  );
}
