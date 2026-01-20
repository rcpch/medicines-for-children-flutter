// HTTP client wrapper for backend calls.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';

/// Provides a configured Dio client for API calls.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.sharedScheduleApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  return dio;
});

/// Provides a Dio client that includes the shared schedule API key header.
final securedApiClientProvider = Provider<Dio>((ref) {
  final dio = ref.watch(dioProvider);
  final apiKey = ref.watch(appConfigProvider).sharedScheduleApiKey;
  dio.options = dio.options.copyWith(
    headers: Map<String, dynamic>.from(dio.options.headers)
      ..putIfAbsent('ApiKey', () => apiKey),
  );
  return dio;
});
