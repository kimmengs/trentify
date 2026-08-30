import 'package:flutter/material.dart';

enum BadgeVariant {
  primary,
  success,
  warning,
  error,
  neutral,
  vip,
  glass,
}

/// A standardized luxury pill / badge widget used across Trentify.
class AppBadgePill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final BadgeVariant variant;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AppBadgePill({
    super.key,
    required this.label,
    this.icon,
    this.variant = BadgeVariant.primary,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadows;

    switch (variant) {
      case BadgeVariant.primary:
        bg = primaryColor.withValues(alpha: isDark ? 0.22 : 0.12);
        fg = primaryColor;
        border = Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 0.8,
        );
        break;
      case BadgeVariant.success:
        bg = const Color(0xFF10B981).withValues(alpha: isDark ? 0.22 : 0.15);
        fg = const Color(0xFF10B981);
        border = Border.all(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.35 : 0.2),
          width: 0.8,
        );
        break;
      case BadgeVariant.warning:
        bg = const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.15);
        fg = const Color(0xFFF59E0B);
        border = Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.2),
          width: 0.8,
        );
        break;
      case BadgeVariant.error:
        bg = const Color(0xFFEF4444).withValues(alpha: isDark ? 0.22 : 0.15);
        fg = const Color(0xFFEF4444);
        border = Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.35 : 0.2),
          width: 0.8,
        );
        break;
      case BadgeVariant.neutral:
        bg = isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0);
        fg = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
        border = Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
          width: 0.8,
        );
        break;
      case BadgeVariant.vip:
        bg = primaryColor;
        fg = Colors.white;
        shadows = [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case BadgeVariant.glass:
        bg = isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.05);
        fg = isDark ? Colors.white : const Color(0xFF0F172A);
        border = Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.20) : const Color(0xFFCBD5E1),
          width: 0.8,
        );
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
        boxShadow: shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
