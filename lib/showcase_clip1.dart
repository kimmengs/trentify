import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/model/cart_item.dart';
import 'package:trentify/provider/address_provider.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/provider/product_provider.dart';
import 'package:trentify/provider/wishlist_provider.dart';
import 'package:trentify/router/app_router.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/theme/app_theme.dart';
import 'package:trentify/theme/cupertino_theme.dart';
import 'package:trentify/theme/theme_controller.dart';

final ValueNotifier<String> chapterNotifier =
    ValueNotifier<String>('🔐 BUYER ROLE • 1-TAP VIP ACCESS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final router = createRouter(initialLocation: AppRoutes.signIn);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(prefs),
        ),
        ChangeNotifierProvider<LocaleController>(
          create: (_) => LocaleController(prefs),
        ),
        ChangeNotifierProvider<AddressProvider>(
          create: (_) => AddressProvider.instance,
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider.instance,
        ),
        ChangeNotifierProvider<WishlistProvider>(
          create: (_) => WishlistProvider.instance,
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider.instance,
        ),
        Provider<ProductRepository>(create: (_) => InMemoryProductRepository()),
      ],
      child: Clip1App(router: router),
    ),
  );
}

class Clip1App extends StatefulWidget {
  final GoRouter router;
  const Clip1App({super.key, required this.router});

  @override
  State<Clip1App> createState() => _Clip1AppState();
}

class _Clip1AppState extends State<Clip1App> {
  @override
  void initState() {
    super.initState();
    _startTimeline();
  }

  Future<void> _startTimeline() async {
    // Reset providers for clean demo
    CartProvider.instance.clearCart();

    await Future.delayed(const Duration(milliseconds: 1000));

    // STEP 1: VIP LOGIN & AUTHENTICATION (0s - 4s)
    chapterNotifier.value = '🔐 1. BUYER LOGIN • 1-TAP VIP ACCESS';
    widget.router.go(AppRoutes.signIn);
    await Future.delayed(const Duration(milliseconds: 4000));

    // STEP 2: HOME DISCOVERY & PRODUCT BROWSING (4s - 9s)
    chapterNotifier.value = '🛍️ 2. EXPLORE CATALOG • LUXURY FEED';
    widget.router.go(AppRoutes.home);
    await Future.delayed(const Duration(milliseconds: 5000));

    // STEP 3: PRODUCT DETAIL & VARIANT SELECTION (9s - 16s)
    chapterNotifier.value = '💎 3. PRODUCT DETAIL • SELECT SIZE & COLOR';
    widget.router.push('/product/detail/ubl-ss-001');
    await Future.delayed(const Duration(milliseconds: 4000));

    // Add item to cart programmatically
    CartProvider.instance.addToCart(
      productId: 'ubl-ss-001',
      title: 'Urban Blend Long Sleeve',
      price: 185.00,
      imageUrl:
          'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
      size: 'M',
      colorName: 'Obsidian Black',
      color: const Color(0xFF111214),
      qty: 1,
    );

    chapterNotifier.value = '✨ 4. ADD TO BAG • OBSIDIAN BLACK (M)';
    await Future.delayed(const Duration(milliseconds: 3000));

    // STEP 4: SHOPPING BAG REVIEW (16s - 22s)
    chapterNotifier.value = '👜 5. SHOPPING BAG • REVIEW SELECTION';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 2});
    await Future.delayed(const Duration(milliseconds: 5000));

    // STEP 5: 3-STEP LUXURY CHECKOUT & PAYMENT (22s - 29s)
    chapterNotifier.value = '💳 6. 3-STEP CHECKOUT • DHL PRIORITY & VISA';
    widget.router.push(
      AppRoutes.checkout,
      extra: [
        CartItem(
          id: 'item_ubl_1',
          productId: 'ubl-ss-001',
          title: 'Urban Blend Long Sleeve',
          price: 185.00,
          imageUrl:
              'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
          size: 'M',
          colorName: 'Obsidian Black',
          color: const Color(0xFF111214),
          qty: 1,
        ),
      ],
    );
    await Future.delayed(const Duration(milliseconds: 6500));

    // STEP 6: ORDER COMPLETE CONFIRMATION (29s - 35s)
    chapterNotifier.value = '🎉 7. PURCHASE COMPLETED • ORDER CONFIRMED';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 3});
    await Future.delayed(const Duration(milliseconds: 5500));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final localeCtl = context.watch<LocaleController>();
    final isDark = theme.mode == AppThemeMode.dark;

    return MaterialApp.router(
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,
      title: 'Clip 1 - Purchase Flow',
      theme: buildMaterialTheme(
        brightness: Brightness.light,
        seed: theme.seed,
      ),
      darkTheme: buildMaterialTheme(
        brightness: Brightness.dark,
        seed: theme.seed,
      ),
      themeMode: theme.materialMode,
      locale: localeCtl.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return CupertinoTheme(
          data: buildCupertinoTheme(
            brightness: isDark ? Brightness.dark : Brightness.light,
            primary: theme.seed,
          ),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              // Professional floating header badge
              Positioned(
                top: 54,
                left: 18,
                right: 18,
                child: ValueListenableBuilder<String>(
                  valueListenable: chapterNotifier,
                  builder: (context, title, _) {
                    return IgnorePointer(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? const Color(0xFF090D14)
                                    : Colors.white)
                                .withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.seed.withValues(alpha: 0.7),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.seed.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
