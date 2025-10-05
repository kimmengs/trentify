import 'package:flutter/cupertino.dart';

class ActionsGridWidget extends StatelessWidget {
  const ActionsGridWidget({required this.actions});
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // Responsive wrap (keeps nice spacing & equal widths)
    final width = MediaQuery.of(context).size.width;
    // 16 + 16 horizontal padding already applied in parent
    const spacing = 18.0;
    // target 4 per row on phones; fall back to 3 if really narrow
    final perRow = width > 360 ? 4 : 3;
    final cellW = (width - 16 - 16 - spacing * (perRow - 1)) / perRow;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: actions
          .map((w) => SizedBox(width: cellW.clamp(70, 120), child: w))
          .toList(),
    );
  }
}
