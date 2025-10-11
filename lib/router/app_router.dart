import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:trentify/model/address.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/model/payment_method.dart';
import 'package:trentify/model/promo.dart';
import 'package:trentify/screens/add_to_cart/add_to_cart.dart';
import 'package:trentify/screens/add_to_cart/address_picker/address_picker.dart';
import 'package:trentify/screens/add_to_cart/checkout/checkout.dart';
import 'package:trentify/screens/add_to_cart/payment_picker/payment_picker.dart';
import 'package:trentify/screens/add_to_cart/promo/promo_picker.dart';
import 'package:trentify/screens/home/category/category.dart';
import 'package:trentify/screens/home/home_ios.dart';
import 'package:trentify/screens/home/notification/notification.dart';
import 'package:trentify/screens/home/product_detail.dart';
import 'package:trentify/screens/more/address/address.dart';
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
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (ctx, state) {
          final items =
              state.extra as List<CartItem>?; // ✅ safely extract param
          return CupertinoPage(child: CheckoutPage(items: items ?? const []));
        },
      ),
      GoRoute(
        path: AppRoutes.addressPicker,
        pageBuilder: (ctx, state) {
          final payload = (state.extra as Map?) ?? {};
          final addrs = (payload['addresses'] as List<Address>?) ?? const [];
          final selectedId = payload['selectedId'] as String?;
          return CupertinoPage(
            child: AddressPickerPage(
              addresses: addrs,
              initialSelectedId: selectedId,
            ),
          );
        },
      ),
      // routes.dart
      GoRoute(
        path: AppRoutes.addressForm, // e.g. '/address/form'
        pageBuilder: (ctx, state) {
          final initial =
              state.extra as Address?; // pass this for edit, null for create
          return CupertinoPage(child: AddressFormPage(initial: initial));
        },
      ),
      GoRoute(
        path: AppRoutes.paymentPicker,
        pageBuilder: (ctx, state) {
          final map = (state.extra as Map?) ?? {};
          final methods = (map['methods'] as List<PaymentMethod>?) ?? const [];
          final selectedId = map['selectedId'] as String?;
          return CupertinoPage(
            child: PaymentPickerPage(
              methods: methods,
              initialSelectedId: selectedId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.promoPicker, // e.g. '/checkout/promos'
        pageBuilder: (ctx, state) {
          final map = (state.extra as Map?) ?? {};
          final promos = (map['promos'] as List<Promo>?) ?? const [];
          final selectedId = map['selectedId'] as String?;
          final subtotal =
              (map['subtotal'] as num?)?.toDouble() ??
              0.0; // to validate min spend
          return CupertinoPage(
            child: PromoPickerPage(
              promos: promos,
              initialSelectedId: selectedId,
              subtotal: subtotal,
            ),
          );
        },
      ),
    ],
  );
}
