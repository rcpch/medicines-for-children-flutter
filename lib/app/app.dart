// App root widget wiring theme, routing, and providers.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/config/app_theme.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/core/offline/background_sync_service.dart';
import 'package:medicines_for_children_flutter/core/settings/app_settings.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/core/update/update_prompt_service.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';

class MedicinesApp extends ConsumerStatefulWidget {
  const MedicinesApp({super.key});

  @override
  ConsumerState<MedicinesApp> createState() => _MedicinesAppState();
}

class _MedicinesAppState extends ConsumerState<MedicinesApp> with WidgetsBindingObserver {
  late final GoRouter _router;
  late final BackgroundSyncService _backgroundSyncService;
  ProviderSubscription<AuthState>? _authSubscription;
  bool _reportedSlowFrame = false;
  bool _checkedForUpdates = false;

  @override
  void initState() {
    super.initState();
    _router = ref.read(appRouterProvider);
    _backgroundSyncService = ref.read(backgroundSyncServiceProvider);
    _backgroundSyncService.start();
    WidgetsBinding.instance.addObserver(this);
    _configureErrorHandling();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybePromptForUpdate();
      await _backgroundSyncService.triggerSync();
    });
    _authSubscription = ref.listenManual<AuthState>(
      authControllerProvider,
      (previous, next) {
        final controller = ref.read(primaryCarerControllerProvider.notifier);
        if (next.status == AuthStatus.authenticated &&
            previous?.status != AuthStatus.authenticated) {
          unawaited(controller.refresh());
        }
        if (next.status == AuthStatus.unauthenticated &&
            previous?.status != AuthStatus.unauthenticated) {
          unawaited(controller.clear());
        }
      },
      fireImmediately: true,
    );
  }

  Future<void> _maybePromptForUpdate() async {
    if (_checkedForUpdates) {
      return;
    }
    _checkedForUpdates = true;
    await ref.read(updatePromptServiceProvider).maybePrompt(context);
  }

  void _configureErrorHandling() {
    final telemetry = ref.read(telemetryServiceProvider);
    FlutterError.onError = (details) {
      telemetry.trackEvent('app_error', properties: {
        'exception': details.exceptionAsString(),
        'context': details.context?.toDescription(),
      });
      FlutterError.presentError(details);
    };
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      telemetry.trackEvent('app_error', properties: {
        'exception': error.toString(),
        'stack': stack.toString(),
      });
      return false;
    };

    WidgetsBinding.instance.addTimingsCallback((timings) {
      if (_reportedSlowFrame) {
        return;
      }
      for (final timing in timings) {
        final buildMs = timing.buildDuration.inMilliseconds;
        final rasterMs = timing.rasterDuration.inMilliseconds;
        if (buildMs > 16 || rasterMs > 16) {
          _reportedSlowFrame = true;
          telemetry.trackEvent('slow_frame_detected', properties: {
            'buildMs': buildMs,
            'rasterMs': rasterMs,
          });
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundSyncService.stop();
    _authSubscription?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _backgroundSyncService.start();
      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthStatus.authenticated) {
        ref.read(primaryCarerControllerProvider.notifier).refresh();
      }
      unawaited(_backgroundSyncService.triggerSync());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundSyncService.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp.router(
      title: 'Medicines for Children (${config.environment.name})',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      highContrastTheme: AppTheme.highContrast,
      themeMode: _resolveThemeMode(settings.themeMode),
      builder: (context, child) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: TextScaler.linear(settings.textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }

  ThemeMode _resolveThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
