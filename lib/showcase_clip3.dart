import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
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
    ValueNotifier<String>('🔐 BUYER ROLE • MY ORDERS & TRACKING');

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
      child: Clip3App(router: router),
    ),
  );
}

class Clip3App extends StatefulWidget {
  final GoRouter router;
  const Clip3App({super.key, required this.router});

  @override
  State<Clip3App> createState() => _Clip3AppState();
}

class _Clip3AppState extends State<Clip3App> {
  @override
  void initState() {
    super.initState();
    _startTimeline();
  }

  Future<void> _startTimeline() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // STEP 1: VIP LOGIN (0s - 4s)
    chapterNotifier.value = '🔐 1. BUYER LOGIN • ACCOUNT ACCESS';
    widget.router.go(AppRoutes.signIn);
    await Future.delayed(const Duration(milliseconds: 4000));

    // STEP 2: HOME TO MY ORDERS (4s - 9s)
    chapterNotifier.value = '📦 2. NAVIGATE TO MY ORDERS HUB';
    widget.router.go(AppRoutes.home, extra: {'tabIndex': 3});
    await Future.delayed(const Duration(milliseconds: 5000));

    // STEP 3: SWITCH SEGMENTED TABS (9s - 15s)
    chapterNotifier.value = '🔄 3. STATUS TABS • ACTIVE & COMPLETED';
    await Future.delayed(const Duration(milliseconds: 6000));

    // STEP 4: TRACK ORDER & LIVE COURIER STATUS (15s - 24s)
    chapterNotifier.value = '📍 4. LIVE DHL TRACKING • REAL-TIME PROGRESS';
    await Future.delayed(const Duration(milliseconds: 8000));

    // STEP 5: ORDER SUMMARY & VERIFIED DELIVERY (24s - 30s)
    chapterNotifier.value = '✨ 5. TRACKING CLEARED • DISPATCH VERIFIED';
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
      title: 'Clip 3 - Orders & Tracking Flow',
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
