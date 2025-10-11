import 'package:flutter/material.dart';

class ExpandableTextWidget extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  const ExpandableTextWidget({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final max = expanded ? null : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: max,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: style,
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            expanded ? 'read less' : 'read more…',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
