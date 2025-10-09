import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridCirclesWidget<T> extends StatelessWidget {
  final List<T> values;
  final bool Function(T) isSelected;
  final void Function(T) onTap;
  final Color textPrimary;
  final Color border;
  final Color selectedFill;

  const GridCirclesWidget({
    required this.values,
    required this.isSelected,
    required this.onTap,
    required this.textPrimary,
    required this.border,
    required this.selectedFill,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: values.map((v) {
        final selected = isSelected(v);
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => onTap(v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? selectedFill : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: border),
                ),
                child: Text(
                  v.toString(),
                  style: TextStyle(
                    color: selected ? Colors.white : textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
