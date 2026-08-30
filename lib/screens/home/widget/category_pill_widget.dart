import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryPillsWidget extends StatelessWidget {
  final List<String> tabs;
  final int value;
  final ValueChanged<int> onTap;

  const CategoryPillsWidget({
    super.key,
    required this.tabs,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final inactiveBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final inactiveBorder = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textInactive = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      scrollDirection: Axis.horizontal,
      itemCount: tabs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final selected = i == value;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? primaryColor : inactiveBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? primaryColor : inactiveBorder,
                width: 1,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                tabs[i],
                style: TextStyle(
                  height: 1.1,
                  fontSize: 13,
                  color: selected ? Colors.white : textInactive,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
