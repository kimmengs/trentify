import 'dart:ui';
import 'package:flutter/material.dart';

/// An ultra-clean iOS Liquid Glass container with customizable blur strength,
/// specular rim borders, ambient elevation, and adaptive dark/light theming.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? borderColor;
  final double borderWidth;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 24,
    this.blurSigma = 24,
    this.borderColor,
    this.borderWidth = 1.2,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultGradient = gradientColors ??
        (isDark
            ? [
                const Color(0xFF1E2632).withValues(alpha: 0.80),
                const Color(0xFF131922).withValues(alpha: 0.88),
              ]
            : [
                Colors.white.withValues(alpha: 0.92),
                const Color(0xFFF8FAFC).withValues(alpha: 0.85),
              ]);

    final defaultBorder = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.85));

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: defaultGradient,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: defaultBorder,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
