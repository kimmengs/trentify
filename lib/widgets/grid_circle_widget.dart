import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridCirclesWidget<T> extends StatelessWidget {
  final List<T> values;

  // single-select
  final T? selectedValue;
  final ValueChanged<T>? onChanged;

  // multi-select
  final Set<T>? selectedValues;
  final ValueChanged<Set<T>>? onChangedMulti;

  // style
  final Color textPrimary;
  final Color border;
  final Color selectedFill;

  const GridCirclesWidget._({
    required this.values,
    this.selectedValue,
    this.onChanged,
    this.selectedValues,
    this.onChangedMulti,
    required this.textPrimary,
    required this.border,
    required this.selectedFill,
  }) : assert(
         // exactly one mode must be active
         (selectedValue != null &&
                 onChanged != null &&
                 selectedValues == null &&
                 onChangedMulti == null) ||
             (selectedValue == null &&
                 onChanged == null &&
                 selectedValues != null &&
                 onChangedMulti != null),
         'Use either .single(...) or .multi(...) constructor.',
       );

  /// Single-select
  factory GridCirclesWidget.single({
    required List<T> values,
    required T? selectedValue,
    required ValueChanged<T> onChanged,
    required Color textPrimary,
    required Color border,
    required Color selectedFill,
  }) => GridCirclesWidget._(
    values: values,
    selectedValue: selectedValue,
    onChanged: onChanged,
    textPrimary: textPrimary,
    border: border,
    selectedFill: selectedFill,
  );

  /// Multi-select
  factory GridCirclesWidget.multi({
    required List<T> values,
    required Set<T> selectedValues,
    required ValueChanged<Set<T>> onChangedMulti,
    required Color textPrimary,
    required Color border,
    required Color selectedFill,
  }) => GridCirclesWidget._(
    values: values,
    selectedValues: selectedValues,
    onChangedMulti: onChangedMulti,
    textPrimary: textPrimary,
    border: border,
    selectedFill: selectedFill,
  );

  @override
  Widget build(BuildContext context) {
    final isSingle = selectedValue != null;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: values.map((v) {
        final bool selected = isSingle
            ? v == selectedValue
            : (selectedValues?.contains(v) ?? false);

        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (isSingle) {
              onChanged?.call(v);
            } else {
              final next = {...(selectedValues ?? <T>{})};
              next.contains(v) ? next.remove(v) : next.add(v);
              onChangedMulti?.call(next);
            }
          },
          child: Container(
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
        );
      }).toList(),
    );
  }
}
