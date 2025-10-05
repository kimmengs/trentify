import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'theme_controller.dart';
import 'app_theme.dart';

class ThemedBackground extends StatelessWidget {
  const ThemedBackground({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<BrandTokens>();
    if (tokens == null) return child ?? const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final wallpaper = isDark
        ? (tokens.wallpaperDarkAsset ?? tokens.wallpaperAsset)
        : tokens.wallpaperAsset;

    final motionAllowed = context.watch<ThemeController>().motionEnabled;
    final userPrefersReducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ??
        (SchedulerBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations);

    final showMotion =
        motionAllowed && tokens.prefersMotion && !userPrefersReducedMotion;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) Static wallpaper (optional)
        if (wallpaper != null)
          Opacity(
            opacity: tokens.wallpaperOpacity ?? 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(wallpaper),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        // 2) Animated overlay (optional)
        if (showMotion && tokens.lottieAsset != null)
          IgnorePointer(
            child: Lottie.asset(
              tokens.lottieAsset!,
              fit: BoxFit.cover,
              repeat: true,
              frameRate: FrameRate.max,
            ),
          ),
        // If using Rive:
        // if (showMotion && tokens.riveAsset != null)
        //   const IgnorePointer(child: RiveAnimation.asset('assets/anim/bg_flare.riv', fit: BoxFit.cover)),

        // 3) Subtle gradient overlay for contrast (optional)
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        if (child != null) child!,
      ],
    );
  }
}
