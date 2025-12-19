import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/presentation/login_page.dart';
import 'package:medicines_for_children_flutter/features/auth/presentation/signup_page.dart';
import 'package:medicines_for_children_flutter/features/home/presentation/home_page.dart';
import 'package:medicines_for_children_flutter/features/onboarding/presentation/onboarding_page.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/presentation/shared_schedule_link_page.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/presentation/shared_schedule_page.dart';
import 'package:medicines_for_children_flutter/features/splash/presentation/splash_page.dart';

enum AppRoute {
  splash('/'),
  login('/login'),
  signup('/signup'),
  onboarding('/onboarding'),
  home('/home'),
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
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
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
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomePage(),
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
        builder: (context, state) => SharedSchedulePage(
          apiId: state.pathParameters['apiId'] ?? '',
        ),
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _subscription = _ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  ProviderSubscription<AuthState>? _subscription;

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
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}
