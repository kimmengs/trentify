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
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/product_provider.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/router/app_router.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/theme/app_theme.dart';
import 'package:trentify/theme/cupertino_theme.dart';
import 'package:trentify/theme/theme_controller.dart';

final ValueNotifier<String> chapterNotifier =
    ValueNotifier<String>('✨ WEBUY UAT • LUXURY EXPERIENCE');

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
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider.instance,
        ),
        ChangeNotifierProvider<SellerProvider>(
          create: (_) => SellerProvider(),
        ),
        Provider<ProductRepository>(create: (_) => InMemoryProductRepository()),
      ],
      child: ShowcaseApp(router: router),
    ),
  );
}

class ShowcaseApp extends StatefulWidget {
  final GoRouter router;
  const ShowcaseApp({super.key, required this.router});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  @override
  void initState() {
    super.initState();
    _startTimeline();
  }

  Future<void> _startTimeline() async {
    // Populate sample cart items for checkout & bag
    CartProvider.instance.addToCart(
      productId: '1',
      title: 'Haute Couture Classic Blazer',
      price: 289.0,
      imageUrl:
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=800&auto=format&fit=crop',
      size: 'M',
      colorName: 'Obsidian Black',
      color: const Color(0xFF111214),
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    // SCENE 1: AUTH & VIP ONBOARDING (0s - 5s)
    chapterNotifier.value = '🔐 VIP AUTHENTICATION • 1-TAP ACCESS';
    widget.router.go(AppRoutes.signIn);
    await Future.delayed(const Duration(milliseconds: 5000));

    // SCENE 2: BUYER HOME FEED & LIQUID GLASS (5s - 10s)
    chapterNotifier.value = '🛍️ BUYER HUB • LIQUID GLASS FEED';
    widget.router.go(AppRoutes.home);
    await Future.delayed(const Duration(milliseconds: 5000));

    // SCENE 3: PRODUCT DETAIL (10s - 15s)
    chapterNotifier.value = '💎 HAUTE COUTURE • PRODUCT SHOWCASE';
    widget.router.push('/product/detail/1');
    await Future.delayed(const Duration(milliseconds: 5000));

    // SCENE 4: LIVE INQUIRY CHAT WITH SELLER (15s - 20s)
    chapterNotifier.value = '💬 DIRECT CONCIERGE • CHAT WITH SELLER';
    final productData = DemoDb.productDetailById('1');
    if (productData != null) {
      widget.router.push(
        AppRoutes.productChat,
        extra: {
          'product': productData,
          'selectedSize': 'M',
          'selectedColor': 'Obsidian Black',
        },
      );
    }
    await Future.delayed(const Duration(milliseconds: 5000));

    // SCENE 5: WISHLIST (20s - 25s)
    chapterNotifier.value = '❤️ CURATED WISHLIST • DUAL LAYOUT';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 1});
    await Future.delayed(const Duration(milliseconds: 5000));

    // SCENE 6: SHOPPING BAG (25s - 30s)
    chapterNotifier.value = '👜 SHOPPING BAG • VIP SHIPPING TRACKER';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 2});
    await Future.delayed(const Duration(milliseconds: 5000));

    // SCENE 7: 3-STEP LUXURY CHECKOUT (30s - 36s)
    chapterNotifier.value = '💳 3-STEP CHECKOUT • DHL PRIORITY';
    widget.router.push(
      AppRoutes.checkout,
      extra: [
        CartItem(
          id: 'item_1',
          productId: '1',
          title: 'Haute Couture Classic Blazer',
          price: 289.0,
          imageUrl:
              'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=800&auto=format&fit=crop',
          size: 'M',
          colorName: 'Obsidian Black',
          color: const Color(0xFF111214),
          qty: 1,
        ),
      ],
    );
    await Future.delayed(const Duration(milliseconds: 5500));

    // SCENE 8: MY ORDERS & LIVE COURIER TRACKING (36s - 42s)
    chapterNotifier.value = '📦 ORDER MANAGEMENT • LIVE DHL TRACKING';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 3});
    await Future.delayed(const Duration(milliseconds: 5500));

    // SCENE 9: SELLER CENTER & REVENUE ANALYTICS (42s - 48s)
    chapterNotifier.value = '🏪 SELLER CENTER • REVENUE & ESCROW';
    widget.router.push(AppRoutes.seller);
    await Future.delayed(const Duration(milliseconds: 6000));

    // SCENE 10: VIP PROFILE & MEMBERSHIP (48s - 54s)
    chapterNotifier.value = '👤 VIP ELITE PROFILE & MEMBERSHIP';
    widget.router.push(AppRoutes.editProfile);
    await Future.delayed(const Duration(milliseconds: 5000));

    // SCENE 11: THEME STUDIO & DARK NOIR (54s - 68s)
    chapterNotifier.value = '🎨 THEME STUDIO • DARK OBSIDIAN NOIR';
    widget.router.push(AppRoutes.theme);
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      final themeCtl = context.read<ThemeController>();
      themeCtl.setMode(AppThemeMode.dark);
    }
    await Future.delayed(const Duration(milliseconds: 3000));

    chapterNotifier.value = '💎 LUXURY PALETTE • EMERALD VELVET';
    if (mounted) {
      final themeCtl = context.read<ThemeController>();
      themeCtl.setSeed(const Color(0xFF10B981));
    }
    await Future.delayed(const Duration(milliseconds: 3000));

    chapterNotifier.value = '🌸 LUXURY PALETTE • ROSE GOLD COUTURE';
    if (mounted) {
      final themeCtl = context.read<ThemeController>();
      themeCtl.setSeed(const Color(0xFFEC4899));
    }
    await Future.delayed(const Duration(milliseconds: 3000));

    chapterNotifier.value = '🔷 LUXURY PALETTE • IMPERIAL SAPPHIRE';
    if (mounted) {
      final themeCtl = context.read<ThemeController>();
      themeCtl.setSeed(const Color(0xFF4F77FE));
    }
    await Future.delayed(const Duration(milliseconds: 3000));

    // SCENE 12: FINALE ON HOME IN DARK OBSIDIAN (68s - 75s)
    chapterNotifier.value = '✨ WEBUY UAT • MAISON LUXURY MARKETPLACE';
    widget.router.go(AppRoutes.home);
    await Future.delayed(const Duration(milliseconds: 6000));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final localeCtl = context.watch<LocaleController>();
    final isDark = theme.mode == AppThemeMode.dark ||
        (theme.mode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return MaterialApp.router(
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,
      title: 'WeBuy UAT',
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
              // Luxury Chapter Header Pill
              Positioned(
                top: 54,
                left: 20,
                right: 20,
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
                                color: Colors.black.withValues(alpha: 0.2),
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
                              letterSpacing: 0.6,
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
