import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/screens/home/category/show_platform_sort_sheet.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/pressable_scale.dart';
import 'package:trentify/widgets/sort_filter/luxury_filter_sheet.dart';
import 'package:trentify/widgets/sort_filter/luxury_sort_sheet.dart';

Widget buildSortFilterBar({
  required BuildContext context,
  required bool isCupertino,
  required bool isDark,
  SortOption currentSort = SortOption.mostSuitable,
  FilterResult? currentFilter,
  ValueChanged<SortOption>? onSortChanged,
  ValueChanged<FilterResult>? onFilterChanged,
}) {
  return LuxurySortFilterBar(
    isDark: isDark,
    currentSort: currentSort,
    currentFilter: currentFilter ?? FilterResult.initial(),
    onSortChanged: onSortChanged,
    onFilterChanged: onFilterChanged,
  );
}

class LuxurySortFilterBar extends StatelessWidget {
  final bool isDark;
  final SortOption currentSort;
  final FilterResult currentFilter;
  final ValueChanged<SortOption>? onSortChanged;
  final ValueChanged<FilterResult>? onFilterChanged;

  const LuxurySortFilterBar({
    super.key,
    required this.isDark,
    this.currentSort = SortOption.mostSuitable,
    required this.currentFilter,
    this.onSortChanged,
    this.onFilterChanged,
  });

  int get _activeFilterCount {
    int count = 0;
    if (currentFilter.categories.isNotEmpty) count += currentFilter.categories.length;
    if (currentFilter.priceRange.start > 1 || currentFilter.priceRange.end < 1000) count += 1;
    if (currentFilter.ratingAtLeast != null) count += 1;
    if (currentFilter.sizes.isNotEmpty) count += currentFilter.sizes.length;
    if (currentFilter.colorName != null) count += 1;
    return count;
  }

  bool get _isSortCustomized => currentSort != SortOption.mostSuitable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final hasActiveModifications = _isSortCustomized || _activeFilterCount > 0;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            if (hasActiveModifications)
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0E131F).withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- SORT BUTTON ---
                  PressableScale(
                    onTap: () async {
                      AppHaptics.selection();
                      final picked = await LuxurySortSheet.show(context, initial: currentSort);
                      if (picked != null) {
                        onSortChanged?.call(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isSortCustomized
                            ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.arrow_up_arrow_down,
                            size: 15,
                            color: _isSortCustomized ? primaryColor : textPrimary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Sort',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _isSortCustomized ? FontWeight.w800 : FontWeight.w700,
                              color: _isSortCustomized ? primaryColor : textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (_isSortCustomized) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(
                    width: 1,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                  ),

                  // --- FILTER BUTTON ---
                  PressableScale(
                    onTap: () async {
                      AppHaptics.selection();
                      final picked = await LuxuryFilterSheet.show(context, initial: currentFilter);
                      if (picked != null) {
                        onFilterChanged?.call(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeFilterCount > 0
                            ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.slider_horizontal_3,
                            size: 15,
                            color: _activeFilterCount > 0 ? primaryColor : textPrimary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _activeFilterCount > 0 ? FontWeight.w800 : FontWeight.w700,
                              color: _activeFilterCount > 0 ? primaryColor : textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (_activeFilterCount > 0) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withValues(alpha: 0.85),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_activeFilterCount',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // --- 1-TAP CLEAR / RESET ACTION (Visible when modified) ---
                  if (hasActiveModifications) ...[
                    Container(
                      width: 1,
                      height: 22,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                    PressableScale(
                      onTap: () {
                        AppHaptics.medium();
                        onSortChanged?.call(SortOption.mostSuitable);
                        onFilterChanged?.call(FilterResult.initial());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        child: Icon(
                          CupertinoIcons.clear,
                          size: 13,
                          color: textMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
