// App route definitions and navigation setup.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/presentation/login_page.dart';
import 'package:medicines_for_children_flutter/features/auth/presentation/signup_page.dart';
import 'package:medicines_for_children_flutter/features/about/presentation/about_page.dart';
import 'package:medicines_for_children_flutter/features/child_profile/presentation/add_child_page.dart';
import 'package:medicines_for_children_flutter/features/child_profile/presentation/child_profile_page.dart';
import 'package:medicines_for_children_flutter/features/home/presentation/home_page.dart';
import 'package:medicines_for_children_flutter/features/medicines/presentation/medicine_detail_page.dart';
import 'package:medicines_for_children_flutter/features/medicines/presentation/medicine_form_page.dart';
import 'package:medicines_for_children_flutter/features/medicines/presentation/medicines_page.dart';
import 'package:medicines_for_children_flutter/features/medicines/presentation/medicine_qr_scan_page.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';
import 'package:medicines_for_children_flutter/features/onboarding/presentation/onboarding_page.dart';
import 'package:medicines_for_children_flutter/features/schedules/presentation/as_needed_record_page.dart';
import 'package:medicines_for_children_flutter/features/schedules/presentation/schedule_form_page.dart';
import 'package:medicines_for_children_flutter/features/schedules/presentation/schedules_page.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/settings_page.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/presentation/shared_schedule_link_page.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/presentation/shared_schedule_page.dart';
import 'package:medicines_for_children_flutter/features/share_centre/presentation/share_centre_detail_page.dart';
import 'package:medicines_for_children_flutter/features/share_centre/presentation/share_centre_form_page.dart';
import 'package:medicines_for_children_flutter/features/share_centre/presentation/share_centre_page.dart';
import 'package:medicines_for_children_flutter/features/splash/presentation/splash_page.dart';
import 'package:medicines_for_children_flutter/features/user_guide/presentation/user_guide_page.dart';
import 'package:medicines_for_children_flutter/features/user_guide/presentation/user_guide_detail_page.dart';
import 'package:medicines_for_children_flutter/app/router/primary_shell.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_observer.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';

enum AppRoute {
  splash('/'),
  login('/login'),
  signup('/signup'),
  onboarding('/onboarding'),
  about('/about'),
  home('/home'),
  schedules('schedule'),
  addSchedule('add'),
  editSchedule(':scheduleId/edit'),
  recordAsNeeded('as-needed'),
  medicines('/medicines'),
  addMedicine('add'),
  scanMedicine('scan'),
  medicineDetail(':medicineId'),
  editMedicine('edit'),
  childProfile('/child-profile'),
  addChild('add-child'),
  shareCentre('share-centre'),
  shareCentreCreate('create'),
  shareCentreDetail(':shareId'),
  settings('settings'),
  userGuide('/guide'),
  userGuideDetail('guide/:sectionId'),
  sharedScheduleLink('/auth/:token'),
  sharedSchedule('/shared-schedule/:apiId');

  const AppRoute(this.path);

  final String path;
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.splash.path,
    refreshListenable: routerNotifier,
    redirect: routerNotifier.handleRedirect,
    observers: [
      TelemetryNavigatorObserver(ref.watch(telemetryServiceProvider)),
    ],
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoute.about.path,
        name: AppRoute.about.name,
        builder: (context, state) => const AboutPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            PrimaryShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: AppRoute.schedules.path,
                    name: AppRoute.schedules.name,
                    builder: (context, state) => const SchedulesPage(),
                    routes: [
                      GoRoute(
                        path: AppRoute.addSchedule.path,
                        name: AppRoute.addSchedule.name,
                        builder: (context, state) => const ScheduleFormPage(),
                      ),
                      GoRoute(
                        path: AppRoute.editSchedule.path,
                        name: AppRoute.editSchedule.name,
                        builder: (context, state) => ScheduleFormPage(
                          scheduleId: state.pathParameters['scheduleId'],
                        ),
                      ),
                      GoRoute(
                        path: AppRoute.recordAsNeeded.path,
                        name: AppRoute.recordAsNeeded.name,
                        builder: (context, state) => const AsNeededRecordPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.medicines.path,
                name: AppRoute.medicines.name,
                builder: (context, state) => const MedicinesPage(),
                routes: [
                  GoRoute(
                    path: AppRoute.addMedicine.path,
                    name: AppRoute.addMedicine.name,
                    builder: (context, state) => MedicineFormPage(
                      draft: state.extra is MedicineDraft
                          ? state.extra as MedicineDraft
                          : null,
                    ),
                  ),
                  GoRoute(
                    path: AppRoute.scanMedicine.path,
                    name: AppRoute.scanMedicine.name,
                    builder: (context, state) => const MedicineQrScanPage(),
                  ),
                  GoRoute(
                    path: AppRoute.medicineDetail.path,
                    name: AppRoute.medicineDetail.name,
                    builder: (context, state) => MedicineDetailPage(
                      medicineId: state.pathParameters['medicineId'] ?? '',
                    ),
                    routes: [
                      GoRoute(
                        path: AppRoute.editMedicine.path,
                        name: AppRoute.editMedicine.name,
                        builder: (context, state) => MedicineFormPage(
                          medicineId: state.pathParameters['medicineId'] ?? '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.childProfile.path,
                name: AppRoute.childProfile.name,
                builder: (context, state) => const ChildProfilePage(),
                routes: [
                  GoRoute(
                    path: AppRoute.addChild.path,
                    name: AppRoute.addChild.name,
                    builder: (context, state) => const AddChildPage(),
                  ),
                  GoRoute(
                    path: AppRoute.shareCentre.path,
                    name: AppRoute.shareCentre.name,
                    builder: (context, state) => const ShareCentrePage(),
                    routes: [
                      GoRoute(
                        path: AppRoute.shareCentreCreate.path,
                        name: AppRoute.shareCentreCreate.name,
                        builder: (context, state) =>
                            const ShareCentreCreatePage(),
                      ),
                      GoRoute(
                        path: AppRoute.shareCentreDetail.path,
                        name: AppRoute.shareCentreDetail.name,
                        builder: (context, state) => ShareCentreDetailPage(
                          shareId: state.pathParameters['shareId'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: AppRoute.settings.path,
                    name: AppRoute.settings.name,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.userGuide.path,
                name: AppRoute.userGuide.name,
                builder: (context, state) => const UserGuidePage(),
                routes: [
                  GoRoute(
                    path: ':sectionId',
                    name: AppRoute.userGuideDetail.name,
                    builder: (context, state) => UserGuideDetailPage(
                      sectionId: state.pathParameters['sectionId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.signup.path,
        name: AppRoute.signup.name,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoute.sharedScheduleLink.path,
        name: AppRoute.sharedScheduleLink.name,
        builder: (context, state) => SharedScheduleLinkPage(
          linkToken: state.pathParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.sharedSchedule.path,
        name: AppRoute.sharedSchedule.name,
        builder: (context, state) =>
            SharedSchedulePage(apiId: state.pathParameters['apiId'] ?? ''),
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _splashTimer = Timer(_minimumSplashDuration, () {
      _hasShownMinimumSplash = true;
      notifyListeners();
    });

    _subscription = _ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  ProviderSubscription<AuthState>? _subscription;
  Timer? _splashTimer;

  static const Duration _minimumSplashDuration = Duration(seconds: 3);
  bool _hasShownMinimumSplash = false;

  // Returns a route redirect based on auth state and current location.
  String? handleRedirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final status = authState.status;
    final location = state.matchedLocation;

    final isSharedScheduleLink = location.startsWith('/auth/');
    final isSharedScheduleView = location.startsWith('/shared-schedule/');
    final isSharedScheduleRoute = isSharedScheduleLink || isSharedScheduleView;

    final isOnSplash = location == AppRoute.splash.path;
    final isOnLogin = location == AppRoute.login.path;
    final isOnSignup = location == AppRoute.signup.path;
    final isOnOnboarding = location == AppRoute.onboarding.path;

    // Always show the splash screen briefly at startup so it is visible.
    if (!_hasShownMinimumSplash) {
      if (isSharedScheduleRoute) {
        return null;
      }
      return isOnSplash ? null : AppRoute.splash.path;
    }

    if (status == AuthStatus.unknown) {
      if (isSharedScheduleRoute) {
        return null;
      }
      return isOnSplash ? null : AppRoute.splash.path;
    }

    if (status == AuthStatus.unauthenticated) {
      if (isSharedScheduleRoute) {
        return null;
      }
      if (isOnLogin || isOnSignup) {
        return null;
      }
      return AppRoute.login.path;
    }

    if (status == AuthStatus.onboarding) {
      if (isSharedScheduleRoute) {
        return null;
      }
      return isOnOnboarding ? null : AppRoute.onboarding.path;
    }

    if (status == AuthStatus.authenticated) {
      if (isOnSplash || isOnLogin || isOnOnboarding || isOnSignup) {
        return AppRoute.home.path;
      }
      return null;
    }

    return null;
  }

  @override
  // Cancels auth subscriptions when router notifier is disposed.
  void dispose() {
    _subscription?.close();
    _splashTimer?.cancel();
    super.dispose();
  }
}
