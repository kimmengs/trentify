import 'package:flutter/material.dart';
import 'package:trentify/screens/home/widget/round_icon_button_widget.dart';

class QtyStepperWidget extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const QtyStepperWidget({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: ShapeDecoration(
        color: cs.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          RoundIconButtonWidget(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          RoundIconButtonWidget(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}
