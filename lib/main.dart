import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/product_provider.dart';

import 'router/app_router.dart';
import 'router/app_routes.dart';

import 'package:trentify/provider/address_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/provider/wishlist_provider.dart';

// THEME pieces
import 'theme/theme_controller.dart'; // <- provides AppThemeMode, ThemeController
import 'theme/app_theme.dart'; // <- buildMaterialTheme()
import 'theme/cupertino_theme.dart'; // <- buildCupertinoTheme()

bool get isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('seenOnboarding') ?? false;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

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
      child: App(showOnboarding: !seen),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, required this.showOnboarding});
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    final router = createRouter(
      initialLocation: showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
    );

    // Watch theme and locale state
    final theme = context.watch<ThemeController>();
    final localeCtl = context.watch<LocaleController>();

    final localizationsDelegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    if (isCupertino) {
      final systemBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final targetBrightness = switch (theme.mode) {
        AppThemeMode.system => systemBrightness,
        AppThemeMode.light => Brightness.light,
        AppThemeMode.dark => Brightness.dark,
      };

      return CupertinoApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        locale: localeCtl.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: localizationsDelegates,
        theme: buildCupertinoTheme(
          brightness: targetBrightness,
          primary: theme.seed,
        ),
        builder: (context, child) {
          final materialTheme = buildMaterialTheme(
            brightness: targetBrightness,
            seed: theme.seed,
            packId: theme.packId,
          );
          return ScaffoldMessenger(
            child: Theme(
              data: materialTheme,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      );
    }

    // Material (Android/others)
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: localeCtl.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: localizationsDelegates,
      themeMode: theme.materialMode,
      theme: buildMaterialTheme(
        brightness: Brightness.light,
        seed: theme.seed,
        packId: theme.packId,
      ),
      darkTheme: buildMaterialTheme(
        brightness: Brightness.dark,
        seed: theme.seed,
        packId: theme.packId,
      ),
    );
  }
}
