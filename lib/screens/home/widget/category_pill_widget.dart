import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final activeColor = const Color(0xFF528F65);
    final inactiveBg = CupertinoDynamicColor.resolve(
      isDark ? Colors.black : CupertinoColors.white,
      context,
    );
    final inactiveBorder = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      scrollDirection: Axis.horizontal,
      itemCount: tabs.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, i) {
        final selected = i == value;

        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? activeColor : inactiveBg,
              borderRadius: BorderRadius.circular(26),
              border: selected
                  ? null
                  : Border.all(color: inactiveBorder.withValues(alpha: 0.6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              tabs[i],
              style: TextStyle(
                height: 1,
                color: selected
                    ? CupertinoColors.white
                    : (isDark ? CupertinoColors.white : CupertinoColors.black),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
