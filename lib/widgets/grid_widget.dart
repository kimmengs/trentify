import 'package:flutter/cupertino.dart';

class GridWidget extends StatelessWidget {
  const GridWidget({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final col = 4;
    final spacing = 22.0;
    final side = (w - 16 - 16 - spacing * (col - 1)) / col;

    return Wrap(
      spacing: spacing,
      runSpacing: 26,
      children: children
          .map((child) => SizedBox(width: side, child: child))
          .toList(),
    );
  }
}
