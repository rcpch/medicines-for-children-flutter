import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/config/app_theme.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';

class MedicinesApp extends ConsumerStatefulWidget {
  const MedicinesApp({super.key});

  @override
  ConsumerState<MedicinesApp> createState() => _MedicinesAppState();
}

class _MedicinesAppState extends ConsumerState<MedicinesApp> {
  late final GoRouter _router;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _router = ref.read(appRouterProvider);
    _configureErrorHandling();
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
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
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
