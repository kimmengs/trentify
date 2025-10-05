import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/app_router.dart';
import 'router/app_routes.dart';

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

  // You can still set a default status bar style; we’ll rely on theme brightness for most pages.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Provide ThemeController so the whole app can react to theme changes.
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(prefs),
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
      initialLocation: showOnboarding ? AppRoutes.onboarding : AppRoutes.signIn,
    );

    // Watch theme state
    final theme = context.watch<ThemeController>();

    if (isCupertino) {
      // Map ThemeController.mode -> a target brightness for Cupertino
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
        theme: buildCupertinoTheme(
          brightness: targetBrightness,
          primary: theme.seed, // keep brand color consistent with Material
        ),
      );
    }

    // Material (Android/others)
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: theme.materialMode, // system / light / dark from controller
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
