import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A safe, resilient network image widget for Trentify.
/// Includes fallback error handling, customizable border radius, and aspect ratios.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? errorWidget;
  final Widget? placeholderWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.errorWidget,
    this.placeholderWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackColor = isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9);
    final iconColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF94A3B8);

    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: fallbackColor,
              child: Center(
                child: Icon(
                  CupertinoIcons.photo,
                  size: (width != null && width! < 40) ? 14 : 20,
                  color: iconColor,
                ),
              ),
            );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholderWidget ??
            Container(
              width: width,
              height: height,
              color: fallbackColor,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
      },
    );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
