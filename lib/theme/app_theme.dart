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
  String? packId, // 👈 allow packId to be passed
}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    extensions: [
      BrandTokens(
        brand: seed,
        cornerRadius: 16,
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
