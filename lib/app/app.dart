import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/config/app_theme.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/core/offline/share_action_queue.dart';
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
  ProviderSubscription<AuthState>? _authSubscription;
  bool _reportedSlowFrame = false;
  bool _checkedForUpdates = false;
  bool _processedQueue = false;

  @override
  void initState() {
    super.initState();
    _router = ref.read(appRouterProvider);
    WidgetsBinding.instance.addObserver(this);
    _configureErrorHandling();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybePromptForUpdate();
      await _processQueuedActions();
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

  Future<void> _processQueuedActions() async {
    if (_processedQueue) {
      return;
    }
    _processedQueue = true;
    await ref.read(shareActionQueueServiceProvider).processQueue();
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
    _authSubscription?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    final authState = ref.read(authControllerProvider);
    if (authState.status == AuthStatus.authenticated) {
      ref.read(primaryCarerControllerProvider.notifier).refresh();
      _processedQueue = false;
      unawaited(_processQueuedActions());
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp.router(
      title: 'Medicines for Children (${config.environment.name})',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      highContrastTheme: AppTheme.highContrast,
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
}
