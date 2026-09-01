import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:trentify/screens/home/notification/notification.dart';
import 'package:trentify/screens/home/product_detail.dart';
import 'package:trentify/screens/chat/product_chat_page.dart';
import 'package:trentify/screens/more/address/address.dart';
import 'package:trentify/screens/more/edit_profile_page.dart';
import 'package:trentify/screens/more/language_page.dart';
import 'package:trentify/screens/more/theme.dart';
import 'package:trentify/screens/search/search_page.dart';
import 'package:trentify/model/seller_product.dart';
import 'package:trentify/screens/navigation/home_shell.dart';
import 'package:trentify/screens/onboarding_page/onboarding_page.dart';
import 'package:trentify/screens/seller/payouts/seller_payouts_page.dart';
import 'package:trentify/screens/seller/products/add_edit_product_page.dart';
import 'package:trentify/screens/seller/seller_shell.dart';
import 'package:trentify/screens/signin/signin.dart';
import 'package:trentify/screens/signup/signup.dart';

import 'app_routes.dart';

CustomTransitionPage<T> _slideUpPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curve),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<T> _slideRightPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.12, 0),
          end: Offset.zero,
        ).animate(curve),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<T> _fadePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

GoRouter createRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (ctx, state) => _fadePage(
          key: state.pageKey,
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (ctx, state) => _fadePage(
          key: state.pageKey,
          child: const SignInPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const SignUpPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (ctx, state) => _fadePage(
          key: state.pageKey,
          child: const HomeShell(),
        ),
      ),
      GoRoute(
        name: 'category',
        path: '/category/:name',
        pageBuilder: (ctx, state) {
          final name = state.pathParameters['name']!;
          return _slideRightPage(
            key: state.pageKey,
            child: CategoryPage(category: name),
          );
        },
      ),
      GoRoute(
        name: 'product-detail',
        path: '/product/detail/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id']!;
          final data = DemoDb.productDetailById(id);
          return _slideUpPage(
            key: state.pageKey,
            child: ProductDetailPage(
              data: data,
              initial: FilterResult.initial(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notification,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const NotificationPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (ctx, state) {
          final q = state.uri.queryParameters['q'];
          return _slideUpPage(
            key: state.pageKey,
            child: SearchPage(initialQuery: q),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const AddToCartPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productChat,
        pageBuilder: (ctx, state) {
          final payload = (state.extra as Map<String, dynamic>?) ?? {};
          final product = payload['product'] as ProductDetailData;
          final selectedSize = payload['selectedSize'] as String?;
          final selectedColor = payload['selectedColor'] as String?;
          return _slideRightPage(
            key: state.pageKey,
            child: ProductChatPage(
              product: product,
              selectedSize: selectedSize,
              selectedColor: selectedColor,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (ctx, state) {
          final items = state.extra as List<CartItem>?;
          return _slideUpPage(
            key: state.pageKey,
            child: CheckoutPage(items: items ?? const []),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addressPicker,
        pageBuilder: (ctx, state) {
          final payload = (state.extra as Map?) ?? {};
          final addrs = payload['addresses'] as List<Address>?;
          final selectedId = payload['selectedId'] as String?;
          final isPickerMode = payload['isPickerMode'] as bool? ?? (payload.containsKey('selectedId'));
          return _slideRightPage(
            key: state.pageKey,
            child: AddressPickerPage(
              addresses: addrs,
              initialSelectedId: selectedId,
              isPickerMode: isPickerMode,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addressForm,
        pageBuilder: (ctx, state) {
          final initial = state.extra as Address?;
          return _slideRightPage(
            key: state.pageKey,
            child: AddressFormPage(initial: initial),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentPicker,
        pageBuilder: (ctx, state) {
          final map = (state.extra as Map?) ?? {};
          final methods = (map['methods'] as List<PaymentMethod>?) ?? const [];
          final selectedId = map['selectedId'] as String?;
          return _slideRightPage(
            key: state.pageKey,
            child: PaymentPickerPage(
              methods: methods,
              initialSelectedId: selectedId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.promoPicker,
        pageBuilder: (ctx, state) {
          final map = (state.extra as Map?) ?? {};
          final promos = (map['promos'] as List<Promo>?) ?? const [];
          final selectedId = map['selectedId'] as String?;
          final subtotal = (map['subtotal'] as num?)?.toDouble() ?? 0.0;
          return _slideRightPage(
            key: state.pageKey,
            child: PromoPickerPage(
              promos: promos,
              initialSelectedId: selectedId,
              subtotal: subtotal,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.theme,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const ThemeSettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const LanguageSettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const EditProfilePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.seller,
        pageBuilder: (ctx, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr != null ? int.tryParse(tabStr) ?? 0 : 0;
          return _slideUpPage(
            key: state.pageKey,
            child: SellerShell(initialIndex: initialTab),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sellerNewProduct,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const AddEditProductPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.sellerEditProduct,
        pageBuilder: (ctx, state) {
          final product = state.extra as SellerProduct?;
          return _slideRightPage(
            key: state.pageKey,
            child: AddEditProductPage(initialProduct: product),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sellerPayouts,
        pageBuilder: (ctx, state) => _slideRightPage(
          key: state.pageKey,
          child: const SellerPayoutsPage(),
        ),
      ),
    ],
  );
}
