import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:trentify/screens/home/category/category.dart';
import 'package:trentify/screens/navigation/home_shell.dart';
import 'package:trentify/screens/onboarding_page/onboarding_page.dart';
import 'package:trentify/screens/signin/signin.dart';
import 'package:trentify/screens/signup/signup.dart';

import 'app_routes.dart';

GoRouter createRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (ctx, state) =>
            const CupertinoPage(child: OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (ctx, state) => const CupertinoPage(child: SignInPage()),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (ctx, state) => const CupertinoPage(child: SignUpPage()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (ctx, state) => const CupertinoPage(child: HomeShell()),
      ),
      GoRoute(
        name: 'category',
        path: '/category/:name',
        pageBuilder: (ctx, state) {
          final name = state.pathParameters['name']!;
          return CupertinoPage(child: CategoryPage(category: name));
        },
      ),
    ],
  );
}
