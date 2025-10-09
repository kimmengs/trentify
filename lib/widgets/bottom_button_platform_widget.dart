import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomButtonPlatformWidget extends StatelessWidget {
  final bool isCupertino;
  final bool isDark;
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final String label;
  final VoidCallback onPressed;

  const BottomButtonPlatformWidget({
    required this.isCupertino,
    required this.isDark,
    required this.cupertinoIcon,
    required this.materialIcon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isCupertino) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              cupertinoIcon,
              size: 18,
              color: isDark ? Colors.white : CupertinoColors.black,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? Colors.white : CupertinoColors.black,
              ),
            ),
          ],
        ),
      );
    }

    // Material button for Android
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(materialIcon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      style: TextButton.styleFrom(
        foregroundColor: isDark ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: const StadiumBorder(),
      ),
    );
  }
}
