import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/widgets/pressable_scale.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: tabs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final selected = i == value;

        return PressableScale(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 18),
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
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Text(
              tabs[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : textInactive,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
