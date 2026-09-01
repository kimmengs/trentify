import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class LuxuryFilterSheet extends StatefulWidget {
  final FilterResult initial;

  const LuxuryFilterSheet({
    super.key,
    required this.initial,
  });

  static Future<FilterResult?> show(
    BuildContext context, {
    FilterResult? initial,
  }) {
    AppHaptics.light();
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LuxuryFilterSheet(
        initial: initial ?? FilterResult.initial(),
      ),
    );
  }

  @override
  State<LuxuryFilterSheet> createState() => _LuxuryFilterSheetState();
}

class _LuxuryFilterSheetState extends State<LuxuryFilterSheet> {
  late FilterResult _state;

  final List<String> _allCategories = [
    'Clothing',
    'Shoe',
    'Bag',
    'Luxury',
    'Accessories',
  ];

  final List<String> _allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  final Map<String, Color> _colorDots = const {
    'Black': Color(0xFF111214),
    'White': Color(0xFFF8FAFC),
    'Navy': Color(0xFF1E293B),
    'Brown': Color(0xFF7C543A),
    'Indigo': Color(0xFF5D50C6),
    'Emerald': Color(0xFF10B981),
    'Amber': Color(0xFFF59E0B),
    'Rose': Color(0xFFEC4899),
  };

  final List<RangeValues> _pricePresets = const [
    RangeValues(1, 100),
    RangeValues(100, 250),
    RangeValues(250, 500),
    RangeValues(500, 1000),
  ];

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_state.categories.isNotEmpty) count += _state.categories.length;
    if (_state.priceRange.start > 1 || _state.priceRange.end < 1000) count += 1;
    if (_state.ratingAtLeast != null) count += 1;
    if (_state.sizes.isNotEmpty) count += _state.sizes.length;
    if (_state.colorName != null) count += 1;
    return count;
  }

  void _resetFilters() {
    AppHaptics.selection();
    setState(() {
      _state = FilterResult.cleared();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final bgCard = isDark ? const Color(0xFF161B22) : Colors.white;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.86,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF090D14).withValues(alpha: 0.96)
                : const Color(0xFFF8FAFC).withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(CupertinoIcons.slider_horizontal_3, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Filter Collections',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (_activeFilterCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$_activeFilterCount',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'Refine by category, price, size and rating',
                              style: TextStyle(fontSize: 11, color: textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.xmark, size: 18, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: borderColor),

              // Scrollable Filter Sections
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  children: [
                    // 1. Categories
                    _buildSectionHeader('Category', textPrimary, textSecondary),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allCategories.map((cat) {
                        final isSel = _state.categories.contains(cat);
                        return PressableScale(
                          onTap: () {
                            AppHaptics.selection();
                            final newSet = Set<String>.from(_state.categories);
                            if (isSel) {
                              newSet.remove(cat);
                            } else {
                              newSet.add(cat);
                            }
                            setState(() => _state = _state.copyWith(categories: newSet));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor : bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel ? primaryColor : borderColor,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? Colors.white : textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 2. Price Range & Presets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Price Range', textPrimary, textSecondary),
                        Text(
                          '\$${_state.priceRange.start.toInt()} - \$${_state.priceRange.end.toInt()}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    RangeSlider(
                      values: _state.priceRange,
                      min: 1,
                      max: 1000,
                      divisions: 100,
                      activeColor: primaryColor,
                      inactiveColor: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                      labels: RangeLabels(
                        '\$${_state.priceRange.start.toInt()}',
                        '\$${_state.priceRange.end.toInt()}',
                      ),
                      onChanged: (vals) {
                        setState(() => _state = _state.copyWith(priceRange: vals));
                      },
                    ),

                    const SizedBox(height: 8),

                    // Price Presets
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _pricePresets.map((preset) {
                        final isSel = (_state.priceRange.start.round() == preset.start.round()) &&
                            (_state.priceRange.end.round() == preset.end.round());
                        final label = preset.end >= 1000 ? '\$500+ Luxury' : '\$${preset.start.toInt()} - \$${preset.end.toInt()}';

                        return PressableScale(
                          onTap: () {
                            AppHaptics.selection();
                            setState(() => _state = _state.copyWith(priceRange: preset));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12) : bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? primaryColor : borderColor,
                                width: isSel ? 1.3 : 1.0,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? primaryColor : textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 3. Minimum Customer Rating
                    _buildSectionHeader('Minimum Rating', textPrimary, textSecondary),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildRatingPill(null, 'All', primaryColor, bgCard, borderColor, textPrimary, textSecondary, isDark),
                        const SizedBox(width: 8),
                        _buildRatingPill(3, '3★ & Up', primaryColor, bgCard, borderColor, textPrimary, textSecondary, isDark),
                        const SizedBox(width: 8),
                        _buildRatingPill(4, '4★ & Up', primaryColor, bgCard, borderColor, textPrimary, textSecondary, isDark),
                        const SizedBox(width: 8),
                        _buildRatingPill(5, '5★ Only', primaryColor, bgCard, borderColor, textPrimary, textSecondary, isDark),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 4. Size Selection
                    _buildSectionHeader('Size', textPrimary, textSecondary),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allSizes.map((s) {
                        final isSel = _state.sizes.contains(s);
                        return PressableScale(
                          onTap: () {
                            AppHaptics.selection();
                            final newSet = Set<String>.from(_state.sizes);
                            if (isSel) {
                              newSet.remove(s);
                            } else {
                              newSet.add(s);
                            }
                            setState(() => _state = _state.copyWith(sizes: newSet));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 50,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor : bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? primaryColor : borderColor,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? Colors.white : textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 5. Color Palette
                    _buildSectionHeader('Color Tone', textPrimary, textSecondary),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _colorDots.entries.map((entry) {
                        final isSel = _state.colorName == entry.key;
                        return PressableScale(
                          onTap: () {
                            AppHaptics.selection();
                            setState(() {
                              _state = _state.copyWith(colorName: isSel ? null : entry.key);
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel
                                        ? primaryColor
                                        : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15)),
                                    width: isSel ? 3 : 1.2,
                                  ),
                                  boxShadow: [
                                    if (isSel)
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: isSel
                                    ? Icon(
                                        CupertinoIcons.checkmark,
                                        size: 16,
                                        color: entry.value == const Color(0xFFF8FAFC) ? Colors.black : Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                  color: isSel ? primaryColor : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  border: Border(top: BorderSide(color: borderColor, width: 1)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Reset Button
                      Expanded(
                        flex: 1,
                        child: PressableScale(
                          onTap: _resetFilters,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2633) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: Center(
                              child: Text(
                                'Reset All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Apply Button
                      Expanded(
                        flex: 2,
                        child: PressableScale(
                          onTap: () {
                            AppHaptics.medium();
                            Navigator.pop(context, _state);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textPrimary, Color textSecondary) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
    );
  }

  Widget _buildRatingPill(
    int? rating,
    String label,
    Color primaryColor,
    Color bgCard,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final isSel = _state.ratingAtLeast == rating;
    return Expanded(
      child: PressableScale(
        onTap: () {
          AppHaptics.selection();
          setState(() => _state = _state.copyWith(ratingAtLeast: rating));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 38,
          decoration: BoxDecoration(
            color: isSel ? primaryColor : bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? primaryColor : borderColor,
            ),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating != null) ...[
                Icon(
                  CupertinoIcons.star_fill,
                  size: 11,
                  color: isSel ? Colors.white : const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  color: isSel ? Colors.white : textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
