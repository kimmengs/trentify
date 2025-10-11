import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AdaptiveButtonStyle { filled, outlined }

class AdaptiveActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AdaptiveButtonStyle style;
  final bool expanded;
  final bool loading;
  final IconData? icon;
  final Color? color; // brand color override (filled bg / outline & text)
  final double? width;
  final double? height; // ✅ new height param

  const AdaptiveActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AdaptiveButtonStyle.filled,
    this.expanded = true,
    this.loading = false,
    this.icon,
    this.color,
    this.width,
    this.height, // ✅ new
  });

  bool get _isCupertino {
    if (kIsWeb) return false; // web -> Material
    final p = defaultTargetPlatform;
    return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    final child = _isCupertino
        ? _buildCupertino(context)
        : _buildMaterial(context);

    // ✅ Wrap in a SizedBox to apply custom width/height if needed
    Widget button = child;
    if (height != null || width != null) {
      button = SizedBox(
        width: width ?? (expanded ? double.infinity : null),
        height: height,
        child: child,
      );
    } else if (expanded) {
      button = SizedBox(width: double.infinity, child: child);
    }

    return button;
  }

  // ---------- Material ----------
  Widget _buildMaterial(BuildContext context) {
    final brand = color ?? const Color(0xFF528F65);
    final content = _content(
      loadingWidget: const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    final pad = EdgeInsets.symmetric(
      vertical: height != null
          ? 0
          : 14, // ✅ remove vertical padding when height fixed
      horizontal: 20,
    );

    switch (style) {
      case AdaptiveButtonStyle.filled:
        return FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            padding: pad,
            shape: const StadiumBorder(),
            minimumSize: height != null
                ? Size.fromHeight(height!)
                : null, // ✅ apply min height
          ),
          child: content,
        );

      case AdaptiveButtonStyle.outlined:
        return OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: pad,
            shape: const StadiumBorder(),
            side: BorderSide(color: brand),
            foregroundColor: brand,
            minimumSize: height != null ? Size.fromHeight(height!) : null, // ✅
          ),
          child: content,
        );
    }
  }

  // ---------- Cupertino ----------
  Widget _buildCupertino(BuildContext context) {
    final brand = color ?? const Color(0xFF528F65);
    final content = _content(
      loadingWidget: const CupertinoActivityIndicator(radius: 9),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    final radius = BorderRadius.circular(28);
    final hPad = const EdgeInsets.symmetric(horizontal: 20);

    switch (style) {
      case AdaptiveButtonStyle.filled:
        return CupertinoButton(
          onPressed: loading ? null : onPressed,
          padding: EdgeInsets.zero,
          borderRadius: radius,
          child: Container(
            height: height ?? 52, // ✅ fixed height support
            alignment: Alignment.center,
            padding: hPad,
            decoration: BoxDecoration(color: brand, borderRadius: radius),
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              child: content,
            ),
          ),
        );

      case AdaptiveButtonStyle.outlined:
        return CupertinoButton(
          onPressed: loading ? null : onPressed,
          padding: EdgeInsets.zero,
          borderRadius: radius,
          child: Container(
            height: height ?? 52, // ✅ fixed height support
            alignment: Alignment.center,
            padding: hPad,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: radius,
              border: Border.all(color: brand, width: 1.2),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: brand, fontWeight: FontWeight.w600),
              child: IconTheme(
                data: IconThemeData(color: brand),
                child: content,
              ),
            ),
          ),
        );
    }
  }

  // ---------- Shared content ----------
  Widget _content({
    required Widget loadingWidget,
    required TextStyle textStyle,
  }) {
    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(width: 10),
          Text('Please wait...', style: textStyle),
        ],
      );
    }

    final labelText = Text(label, style: textStyle);
    if (icon == null) return labelText;

    final iconWidget = Icon(icon, size: 18);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [iconWidget, const SizedBox(width: 8), labelText],
    );
  }
}

// Small extension to tint Cupertino filled button background
extension _CupertinoFilledColor on CupertinoButton {
  Widget _withCupertinoColor(Color color) {
    return CupertinoTheme(
      data: CupertinoThemeData(primaryColor: color),
      child: this,
    );
  }
}
