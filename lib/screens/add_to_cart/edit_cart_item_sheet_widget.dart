import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/model/name_color.dart';
import 'package:trentify/screens/add_to_cart/add_to_cart.dart';
import 'package:trentify/screens/home/widget/round_icon_button_widget.dart';
import 'package:trentify/widgets/color_grid_widget.dart';
import 'package:trentify/widgets/grid_circle_widget.dart';

class EditCartItemSheet extends StatefulWidget {
  final CartItem item;
  final List<String> availableSizes;
  final List<NamedColor> availableColors;
  final FilterResult initial;

  const EditCartItemSheet({
    super.key,
    required this.item,
    required this.availableSizes,
    required this.availableColors,
    required this.initial,
  });

  @override
  State<EditCartItemSheet> createState() => _EditCartItemSheetState();
}

class _EditCartItemSheetState extends State<EditCartItemSheet> {
  late int _qty;
  late int _stock;
  late String _size;
  late String _colorName;
  late Color _color;
  late FilterResult state;

  final priceBuckets = const [
    RangeValues(1, 50),
    RangeValues(51, 100),
    RangeValues(101, 150),
    RangeValues(151, 200),
    RangeValues(201, 250),
    RangeValues(251, 300),
    RangeValues(300, 300),
  ];
  final sizes = const [
    "XXS",
    "XS",
    "S",
    "M",
    "L",
    "XL",
    "XXL",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
  ];
  final colorDots = const <String, Color>{
    "Black": Color(0xFF111214),
    "White": Color(0xFFFFFFFF),
    "Red": Color(0xFFE74B3C),
    "Pink": Color(0xFFF64D86),
    "Purple": Color(0xFF8E39C1),
    "Deep Purple": Color(0xFF6B2BB0),
  };

  @override
  void initState() {
    super.initState();
    _qty = widget.item.qty;
    _size = widget.item.size;
    _colorName = widget.item.colorName;
    _color = widget.item.color;
    state = widget.initial;
    _stock = widget.item.stock;
  }

  Color get brand => const Color(0xFF528F65);
  bool get isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  Color get surface =>
      isDark ? const Color(0xFF111315) : CupertinoColors.systemGrey6;
  Color get border =>
      isDark ? const Color(0xFF2A2D31) : const Color(0x11000000);
  Color get textPrimary =>
      isDark ? CupertinoColors.white : CupertinoColors.black;
  Color get textSecondary =>
      isDark ? CupertinoColors.systemGrey2 : CupertinoColors.systemGrey;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Edit Product Variant',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Divider(color: cs.outlineVariant),

              // Product row
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.item.imageUrl,
                      width: 104,
                      height: 124,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (widget.item.stock != null)
                          Text(
                            'Stock  :  ${widget.item.stock}',
                            style: text.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${widget.item.price.toStringAsFixed(2)}',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5C8F62),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _QtyPill(
                          value: _qty,
                          onDec: () =>
                              setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                          onInc: () => setState(() => _qty += 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _Divider(color: cs.outlineVariant),
              const SizedBox(height: 12),
              // size
              _SectionTitle("Size"),
              const SizedBox(height: 12),
              GridCirclesWidget<String>.single(
                values: sizes,
                selectedValue: _size,
                onChanged: (v) => setState(() => _size = v),
                textPrimary: textPrimary,
                border: border,
                selectedFill: brand,
              ),

              // color
              const SizedBox(height: 12),
              _Divider(color: cs.outlineVariant),
              const SizedBox(height: 12),
              _SectionTitle("Color"),
              const SizedBox(height: 12),
              ColorGridWidget(
                colors: colorDots,
                selectedName: state.colorName,
                onPick: (name) =>
                    setState(() => state = state.copyWith(colorName: name)),
                textPrimary: textPrimary,
                border: border,
              ),
              const SizedBox(height: 22),

              // actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5C8F62),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          CartItem(
                            id: widget.item.id,
                            title: widget.item.title,
                            imageUrl: widget.item.imageUrl,
                            size: _size,
                            colorName: _colorName,
                            color: _color,
                            price: widget.item.price,
                            qty: _qty,
                            selected: widget.item.selected,
                          ),
                        );
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _QtyRow extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChange;
  const _QtyRow({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _RoundBtn(
          icon: Icons.remove,
          onTap: () => onChange(value > 1 ? value - 1 : 1),
        ),
        const SizedBox(width: 16),
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 16),
        _RoundBtn(icon: Icons.add, onTap: () => onChange(value + 1)),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 44, height: 44, child: Icon(icon)),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorSwatch({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.surface,
              shape: BoxShape.circle,
              boxShadow: selected
                  ? [BoxShadow(color: color.withOpacity(.5), blurRadius: 8)]
                  : null,
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    width: double.infinity,
    color: color.withOpacity(0.35),
  );
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _QtyPill extends StatelessWidget {
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _QtyPill({
    required this.value,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest
            : Color(0xFFF4F6F5), // dark pill like the mock
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundIconButtonWidget(icon: Icons.remove, onTap: onDec),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          RoundIconButtonWidget(icon: Icons.add, onTap: onInc),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget _with(IconData icon) => Stack(
    alignment: Alignment.center,
    children: [this, Icon(icon, size: 20)],
  );
}

class _SizeDot extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedFill;
  const _SizeDot({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedFill,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: selected ? selectedFill : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? selectedFill : cs.outlineVariant,
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
