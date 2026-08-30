import 'dart:ui';
import 'package:flutter/material.dart';

class BrandTokens extends ThemeExtension<BrandTokens> {
  final Color brand;
  final double cornerRadius;
  final String? wallpaperAsset;
  final String? wallpaperDarkAsset;
  final double? wallpaperOpacity;
  final String? lottieAsset;
  final bool prefersMotion;

  const BrandTokens({
    required this.brand,
    required this.cornerRadius,
    this.wallpaperAsset,
    this.wallpaperDarkAsset,
    this.wallpaperOpacity,
    this.lottieAsset,
    this.prefersMotion = false,
  });

  @override
  BrandTokens copyWith({
    Color? brand,
    double? cornerRadius,
    String? wallpaperAsset,
    String? wallpaperDarkAsset,
    double? wallpaperOpacity,
    String? lottieAsset,
    bool? prefersMotion,
  }) {
    return BrandTokens(
      brand: brand ?? this.brand,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      wallpaperAsset: wallpaperAsset ?? this.wallpaperAsset,
      wallpaperDarkAsset: wallpaperDarkAsset ?? this.wallpaperDarkAsset,
      wallpaperOpacity: wallpaperOpacity ?? this.wallpaperOpacity,
      lottieAsset: lottieAsset ?? this.lottieAsset,
      prefersMotion: prefersMotion ?? this.prefersMotion,
    );
  }

  @override
  BrandTokens lerp(ThemeExtension<BrandTokens>? other, double t) {
    if (other is! BrandTokens) return this;
    return BrandTokens(
      brand: Color.lerp(brand, other.brand, t)!,
      cornerRadius: lerpDouble(cornerRadius, other.cornerRadius, t)!,
      wallpaperAsset: t < 0.5 ? wallpaperAsset : other.wallpaperAsset,
      wallpaperDarkAsset: t < 0.5
          ? wallpaperDarkAsset
          : other.wallpaperDarkAsset,
      wallpaperOpacity: lerpDouble(wallpaperOpacity, other.wallpaperOpacity, t),
      lottieAsset: t < 0.5 ? lottieAsset : other.lottieAsset,
      prefersMotion: prefersMotion,
    );
  }
}

ThemeData buildMaterialTheme({
  required Brightness brightness,
  required Color seed,
  String? packId,
}) {
  final isDark = brightness == Brightness.dark;
  final primaryColor = seed;
  final scaffoldBg = isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC);
  final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
  final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
  final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBg,
    dividerColor: borderColor,
    tabBarTheme: TabBarThemeData(
      indicatorColor: primaryColor,
    ),
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
      onPrimaryContainer: isDark ? Colors.white : primaryColor,
      secondary: primaryColor,
      onSecondary: Colors.white,
      surface: cardBg,
      onSurface: textPrimary,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      outline: borderColor,
      outlineVariant: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
    ),
    extensions: [
      BrandTokens(
        brand: seed,
        cornerRadius: 20,
        wallpaperAsset: packId == 'ocean'
            ? 'assets/images/wallpapers/ocean_light.jpg'
            : null,
        wallpaperDarkAsset: packId == 'ocean'
            ? 'assets/images/wallpapers/ocean_dark.jpg'
            : null,
        wallpaperOpacity: 0.25,
        lottieAsset: packId == 'particles'
            ? 'assets/anim/particles.json'
            : null,
        prefersMotion: packId == 'particles',
      ),
    ],
  );
}
