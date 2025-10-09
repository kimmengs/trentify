import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorGridWidget extends StatelessWidget {
  final Map<String, Color> colors;
  final String? selectedName;
  final void Function(String) onPick;
  final Color textPrimary;
  final Color border;

  const ColorGridWidget({
    required this.colors,
    required this.selectedName,
    required this.onPick,
    required this.textPrimary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final entries = colors.entries.toList();
    return Column(
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 16,
          children: entries.map((e) {
            final selected = e.key == selectedName;
            return SizedBox(
              width: 72,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => onPick(e.key),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: e.value,
                            shape: BoxShape.circle,
                            border: Border.all(color: border),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            CupertinoIcons.check_mark,
                            size: 20,
                            color: Colors.white,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textPrimary.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
