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
import 'package:trentify/model/demodb.dart';
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
    ValueNotifier<String>('🔐 BUYER ROLE • VIP SHOPPER ACCESS');

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
      child: Clip2App(router: router),
    ),
  );
}

class Clip2App extends StatefulWidget {
  final GoRouter router;
  const Clip2App({super.key, required this.router});

  @override
  State<Clip2App> createState() => _Clip2AppState();
}

class _Clip2AppState extends State<Clip2App> {
  @override
  void initState() {
    super.initState();
    _startTimeline();
  }

  Future<void> _startTimeline() async {
    // Populate Wishlist with curated luxury items
    final wishlist = WishlistProvider.instance;
    wishlist.clearWishlist();
    for (final p in DemoDb.allProducts.take(5)) {
      wishlist.addProduct(p);
    }
    CartProvider.instance.clearCart();

    await Future.delayed(const Duration(milliseconds: 1000));

    // STEP 1: LOGIN (0s - 4s)
    chapterNotifier.value = '🔐 1. BUYER LOGIN • VIP SHOPPER ACCESS';
    widget.router.go(AppRoutes.signIn);
    await Future.delayed(const Duration(milliseconds: 4000));

    // STEP 2: HOME FEED (4s - 8s)
    chapterNotifier.value = '🛍️ 2. BROWSE PRODUCTS • DISCOVERY';
    widget.router.go(AppRoutes.home);
    await Future.delayed(const Duration(milliseconds: 4500));

    // STEP 3: NAVIGATE TO WISHLIST (8s - 14s)
    chapterNotifier.value = '❤️ 3. CURATED WISHLIST • DUAL LAYOUT';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 1});
    await Future.delayed(const Duration(milliseconds: 5500));

    // STEP 4: LUXURY SORT & FILTER (14s - 21s)
    chapterNotifier.value = '⚡ 4. LUXURY SORT & FILTER • REFINED PICKS';
    await Future.delayed(const Duration(milliseconds: 6500));

    // STEP 5: ADD FROM WISHLIST TO BAG (21s - 26s)
    chapterNotifier.value = '👜 5. ADD SAVED PIECE TO SHOPPING BAG';
    CartProvider.instance.addToCart(
      productId: 'bag-quilted-crossbody-01',
      title: 'Monogram Quilted Caviar Crossbody',
      price: 520.00,
      imageUrl:
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800&auto=format&fit=crop',
      size: 'One Size',
      colorName: 'Caviar Black',
      color: const Color(0xFF111214),
      qty: 1,
    );
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 2});
    await Future.delayed(const Duration(milliseconds: 5000));

    // STEP 6: PROCEED TO PAYMENT & CHECKOUT (26s - 34s)
    chapterNotifier.value = '💳 6. PROCEED TO CHECKOUT & MAKE PAYMENT';
    widget.router.push(
      AppRoutes.checkout,
      extra: [
        CartItem(
          id: 'item_wish_1',
          productId: 'bag-quilted-crossbody-01',
          title: 'Monogram Quilted Caviar Crossbody',
          price: 520.00,
          imageUrl:
              'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800&auto=format&fit=crop',
          size: 'One Size',
          colorName: 'Caviar Black',
          color: const Color(0xFF111214),
          qty: 1,
        ),
      ],
    );
    await Future.delayed(const Duration(milliseconds: 6500));

    // STEP 7: PAYMENT COMPLETE (34s - 39s)
    chapterNotifier.value = '✨ 7. PAYMENT CONFIRMED • RECEIPT READY';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 3});
    await Future.delayed(const Duration(milliseconds: 5000));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final localeCtl = context.watch<LocaleController>();
    final isDark = theme.mode == AppThemeMode.dark;

    return MaterialApp.router(
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,
      title: 'Clip 2 - Wishlist & Payment Flow',
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
