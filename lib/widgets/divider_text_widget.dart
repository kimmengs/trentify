import 'package:flutter/cupertino.dart';
import 'package:trentify/widgets/line_widget.dart';

class DividerTextWidget extends StatelessWidget {
  const DividerTextWidget(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: LineWidget()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: CupertinoColors.inactiveGray,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: LineWidget()),
      ],
    );
  }
}
