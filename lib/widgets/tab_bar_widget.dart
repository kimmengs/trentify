import 'package:flutter/cupertino.dart';

class TabsBarWidget extends StatelessWidget {
  final List<String> tabs;
  final int value;
  final ValueChanged<int> onChanged;
  const TabsBarWidget({
    required this.tabs,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<int>(
      groupValue: value,
      children: {
        for (int i = 0; i < tabs.length; i++)
          i: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              tabs[i],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      },
      onValueChanged: (i) {
        if (i != null) onChanged(i);
      },
    );
  }
}
