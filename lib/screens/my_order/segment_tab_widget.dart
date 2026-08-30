import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SegmentedTabsWidget extends StatelessWidget {
  const SegmentedTabsWidget({
    super.key,
    required this.controller,
    required this.items,
  });

  final TabController controller;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final bg = isDark ? const Color(0xFF161B22) : const Color(0xFFE2E8F0).withValues(alpha: 0.5);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = controller.index == index;
              return Expanded(
                child: PressableScale(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.animateTo(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      items[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
