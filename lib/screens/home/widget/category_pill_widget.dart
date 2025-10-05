import 'package:flutter/cupertino.dart';

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
    final activeColor = const Color(0xFF2E7D32);
    final inactiveBg = CupertinoDynamicColor.resolve(
      CupertinoColors.white,
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
                  : Border.all(color: inactiveBorder.withOpacity(0.6)),
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
                color: selected ? CupertinoColors.white : CupertinoColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
