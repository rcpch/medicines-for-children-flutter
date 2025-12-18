import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/features/splash/presentation/splash_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
    ],
  );
}
