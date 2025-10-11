import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/screens/home/category/category.dart';
import 'package:trentify/screens/home/home_ios.dart';
import 'package:trentify/screens/home/notification/notification.dart';
import 'package:trentify/screens/home/product_detail.dart';
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

      GoRoute(
        name: 'product-detail',
        path: '/product/detail/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id']!;
          final data = DemoDb.productDetailById(id);
          if (data == null) {
            return const CupertinoPage(
              child: Scaffold(body: Center(child: Text('Not found'))),
            );
          }
          return CupertinoPage(
            child: ProductDetailPage(
              data: data,
              initial: FilterResult.initial(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notification,
        pageBuilder: (ctx, state) =>
            const CupertinoPage(child: NotificationPage()),
      ),
    ],
  );
}
