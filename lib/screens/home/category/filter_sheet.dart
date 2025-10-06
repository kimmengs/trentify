import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

/// --------------------
/// DATA MODEL
/// --------------------
class FilterResult {
  final Set<String> categories;
  final RangeValues priceRange; // (min, max) in dollars
  final int? ratingAtLeast; // 3, 4, 5 or null
  final Set<String> sizes; // e.g. ["S","M","L","38"]
  final String? colorName; // e.g. "Black"
  const FilterResult({
    required this.categories,
    required this.priceRange,
    required this.ratingAtLeast,
    required this.sizes,
    required this.colorName,
  });

  FilterResult copyWith({
    Set<String>? categories,
    RangeValues? priceRange,
    int? ratingAtLeast,
    Set<String>? sizes,
    String? colorName,
  }) {
    return FilterResult(
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      ratingAtLeast: ratingAtLeast,
      sizes: sizes ?? this.sizes,
      colorName: colorName,
    );
  }

  static const defaultMin = 1.0;
  static const defaultMax = 300.0;

  static FilterResult initial() => const FilterResult(
    categories: {"Men"},
    priceRange: RangeValues(85, 220),
    ratingAtLeast: null,
    sizes: {"L", "38"},
    colorName: "Black",
  );

  static FilterResult cleared() => const FilterResult(
    categories: {},
    priceRange: RangeValues(defaultMin, defaultMax),
    ratingAtLeast: null,
    sizes: {},
    colorName: null,
  );
}

/// --------------------
/// ENTRY POINT (platform adaptive)
/// --------------------
Future<FilterResult?> showPlatformFilterSheet(
  BuildContext context, {
  FilterResult? initial,
}) {
  final isCupertino =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  if (isCupertino) {
    return showCupertinoModalPopup<FilterResult>(
      context: context,
      builder: (ctx) => FilterSheet(initial: initial ?? FilterResult.initial()),
    );
  } else {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FilterSheet(initial: initial ?? FilterResult.initial()),
    );
  }
}

/// --------------------
/// SHEET WIDGET
/// --------------------
class FilterSheet extends StatefulWidget {
  final FilterResult initial;
  const FilterSheet({required this.initial});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterResult state;

  // palette & choices (tweak as you like)
  final categories = const [
    "Women",
    "Men",
    "Shoe",
    "Bag",
    "Luxury",
    "Kids",
    "Sports",
    "Beauty",
    "Lifestyle",
    "Other",
  ];
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
    "Indigo": Color(0xFF3E4EB8),
    "Blue": Color(0xFF2E8AF7),
    "Light Blue": Color(0xFF34B8FE),
    "Teal": Color(0xFF1FAF9D),
    "Green": Color(0xFF4FAF6F),
    "Lime": Color(0xFFC1D437),
    "Yellow": Color(0xFFFFD54F),
    "Amber": Color(0xFFFFB300),
    "Orange": Color(0xFFFF8F00),
    "Deep Orange": Color(0xFFFF7043),
    "Brown": Color(0xFF7B5A45),
    "Blue Grey": Color(0xFF607D8B),
  };

  @override
  void initState() {
    super.initState();
    state = widget.initial;
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
    final content = SafeArea(
      top: true,
      bottom: false,
      child: Material(
        color: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: () => Navigator.pop(context),
                    child: Icon(CupertinoIcons.xmark, color: textPrimary),
                  ),
                  const Spacer(),
                  Text(
                    "Filter",
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {}, // “See All” (optional callback)
                    child: Row(
                      children: [
                        Text(
                          "",
                          style: TextStyle(
                            color: brand,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Expanded(
                child: ListView(
                  children: [
                    _SectionTitle("Categories"),
                    const SizedBox(height: 8),
                    _WrapChips<String>(
                      values: categories,
                      isSelected: (v) => state.categories.contains(v),
                      onTap: (v) {
                        final s = {...state.categories};
                        s.contains(v) ? s.remove(v) : s.add(v);
                        setState(() => state = state.copyWith(categories: s));
                      },
                      selectedColor: brand,
                      textPrimary: textPrimary,
                      border: border,
                    ),

                    const SizedBox(height: 18),

                    const _SectionTitle("Price"),
                    const SizedBox(height: 12),
                    _PriceSlider(
                      values: state.priceRange,
                      min: FilterResult.defaultMin,
                      max: FilterResult.defaultMax,
                      brand: brand,
                      isDark: isDark,
                      onChanged: (rv) => setState(
                        () => state = state.copyWith(priceRange: rv),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _WrapChips<RangeValues>(
                      values: priceBuckets,
                      labelBuilder: (rv) => rv.end == 300
                          ? "\$${rv.start.toInt()} & up"
                          : "\$${rv.start.toInt()} - \$${rv.end.toInt()}",
                      isSelected: (rv) => _rangeEq(rv, state.priceRange),
                      onTap: (rv) => setState(
                        () => state = state.copyWith(priceRange: rv),
                      ),
                      selectedColor: Colors.transparent,
                      selectedBorderColor: brand,
                      textPrimary: textPrimary,
                      border: border,
                    ),

                    const SizedBox(height: 18),

                    const _SectionTitle("Rating"),
                    const SizedBox(height: 8),
                    _WrapChips<int>(
                      values: const [3, 4, 5],
                      labelBuilder: (n) => "$n & up",
                      leadingBuilder: (n) => Icon(
                        CupertinoIcons.star_fill,
                        size: 16,
                        color: Colors.amber.shade600,
                      ),
                      isSelected: (n) => state.ratingAtLeast == n,
                      onTap: (n) => setState(
                        () => state = state.copyWith(
                          ratingAtLeast: n == state.ratingAtLeast ? null : n,
                        ),
                      ),
                      selectedColor: Colors.transparent,
                      selectedBorderColor: brand,
                      textPrimary: textPrimary,
                      border: border,
                    ),

                    const SizedBox(height: 18),

                    _SectionTitle("Size"),
                    const SizedBox(height: 8),
                    _GridCircles<String>(
                      values: sizes,
                      isSelected: (v) => state.sizes.contains(v),
                      onTap: (v) {
                        final s = {...state.sizes};
                        s.contains(v) ? s.remove(v) : s.add(v);
                        setState(() => state = state.copyWith(sizes: s));
                      },
                      textPrimary: textPrimary,
                      border: border,
                      selectedFill: brand,
                    ),

                    const SizedBox(height: 18),

                    _SectionTitle("Color"),
                    const SizedBox(height: 10),
                    _ColorGrid(
                      colors: colorDots,
                      selectedName: state.colorName,
                      onPick: (name) => setState(
                        () => state = state.copyWith(colorName: name),
                      ),
                      textPrimary: textPrimary,
                      border: border,
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),

              // Footer buttons
              Container(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        label: "Reset",
                        onTap: () =>
                            setState(() => state = FilterResult.cleared()),
                        bg: isDark
                            ? const Color(0xFF232629)
                            : const Color(0xFFECEDEE),
                        fg: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PillButton(
                        label: "Apply",
                        onTap: () => Navigator.pop(context, state),
                        bg: brand,
                        fg: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Cupertino-style modal container on iOS for correct animation
    final isCupertino =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    return isCupertino
        ? SafeArea(top: false, bottom: false, child: content)
        : content;
  }

  bool _rangeEq(RangeValues a, RangeValues b) =>
      (a.start.round() == b.start.round()) && (a.end.round() == b.end.round());
}

/// --------------------
/// UI PARTS
/// --------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const _SectionTitle(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final color = isDark ? CupertinoColors.white : CupertinoColors.black;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg, fg;
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _WrapChips<T> extends StatelessWidget {
  final List<T> values;
  final bool Function(T) isSelected;
  final void Function(T) onTap;
  final String Function(T)? labelBuilder;
  final Widget Function(T)? leadingBuilder;
  final Color selectedColor;
  final Color? selectedBorderColor;
  final Color textPrimary;
  final Color border;

  const _WrapChips({
    required this.values,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.textPrimary,
    required this.border,
    this.labelBuilder,
    this.leadingBuilder,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values.map((v) {
        final selected = isSelected(v);
        final label = labelBuilder != null ? labelBuilder!(v) : v.toString();
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => onTap(v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? (selectedBorderColor ?? Colors.transparent)
                    : border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingBuilder != null) ...[
                  leadingBuilder!(v),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : textPrimary.withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GridCircles<T> extends StatelessWidget {
  final List<T> values;
  final bool Function(T) isSelected;
  final void Function(T) onTap;
  final Color textPrimary;
  final Color border;
  final Color selectedFill;

  const _GridCircles({
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

class _ColorGrid extends StatelessWidget {
  final Map<String, Color> colors;
  final String? selectedName;
  final void Function(String) onPick;
  final Color textPrimary;
  final Color border;

  const _ColorGrid({
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

class _PriceSlider extends StatelessWidget {
  final RangeValues values;
  final double min, max;
  final bool isDark;
  final Color brand;
  final ValueChanged<RangeValues> onChanged;

  const _PriceSlider({
    required this.values,
    required this.min,
    required this.max,
    required this.isDark,
    required this.brand,
    required this.onChanged,
  });

  String _fmt(double v) => "\$${v.round()}";

  @override
  Widget build(BuildContext context) {
    // Use Material slider inside Material ancestor (already present in _FilterSheet)
    return Column(
      children: [
        const SizedBox(height: 25),
        SfRangeSliderTheme(
          data: SfRangeSliderThemeData(
            tooltipBackgroundColor: brand, // ✅ works here now
            tooltipTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: SfRangeSlider(
            min: min,
            max: max,
            values: SfRangeValues(values.start, values.end),
            onChanged: (SfRangeValues v) =>
                onChanged(RangeValues(v.start as double, v.end as double)),
            activeColor: brand,
            inactiveColor: isDark
                ? const Color(0x33272A2E)
                : const Color(0x22000000),

            // 👇 tooltip settings
            enableTooltip: true,
            shouldAlwaysShowTooltip: true,
            tooltipShape:
                const SfPaddleTooltipShape(), // ✅ required when themed
            tooltipTextFormatterCallback: (actual, value) =>
                '\$${double.parse(value).round()}',
          ),
        ),
      ],
    );
  }
}
