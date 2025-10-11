import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  const TagWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
