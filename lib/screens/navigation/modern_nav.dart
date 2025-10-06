import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class ModernBottomBarItem {
  final IconData icon;
  final String label;
  const ModernBottomBarItem(this.icon, this.label);
}

class ModernBottomBar extends StatelessWidget {
  final List<ModernBottomBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ModernBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark
        ? Colors.white.withValues(alpha: 0.08) // darker mode = lighter tint
        : Colors.white.withValues(alpha: 0.18); // light mode = faint milk
    final inset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      bottom: false,

      child: Transform.translate(
        offset: const Offset(0, 4),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            max(inset * 0.8, 12), // proportional push up (40% of safe area)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                // 3) items
                SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      for (int i = 0; i < items.length; i++)
                        _NavButton(
                          item: items[i],
                          selected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final ModernBottomBarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xFF528F65); // minty-teal like screenshot
    final inactive = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.55);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: selected
                  ? activeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: selected ? activeColor : inactive,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: selected ? activeColor : inactive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
