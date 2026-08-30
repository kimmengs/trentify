import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernBottomBarItem {
  final IconData icon;
  final String label;
  final String? badge;
  const ModernBottomBarItem(this.icon, this.label, {this.badge});
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
    final primaryColor = Theme.of(context).primaryColor;
    final inset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14,
          2,
          14,
          max(inset * 0.85, 12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              // Deep ambient drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              // Soft colored glow from active item
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1C2430).withValues(alpha: 0.82),
                            const Color(0xFF0F172A).withValues(alpha: 0.88),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.90),
                            const Color(0xFFF8FAFC).withValues(alpha: 0.82),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  // Liquid Specular Highlight Border
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      _LiquidNavButton(
                        item: items[i],
                        selected: i == currentIndex,
                        primaryColor: primaryColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap(i);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidNavButton extends StatelessWidget {
  final ModernBottomBarItem item;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _LiquidNavButton({
    required this.item,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactive = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            primaryColor.withValues(alpha: 0.28),
                            primaryColor.withValues(alpha: 0.12),
                          ]
                        : [
                            primaryColor.withValues(alpha: 0.18),
                            primaryColor.withValues(alpha: 0.08),
                          ],
                  )
                : null,
            borderRadius: BorderRadius.circular(22),
            border: selected
                ? Border.all(
                    color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: selected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      item.icon,
                      size: 22,
                      color: selected ? primaryColor : inactive,
                    ),
                  ),
                  if (item.badge != null)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          item.badge!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: -0.1,
                  color: selected ? primaryColor : inactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
