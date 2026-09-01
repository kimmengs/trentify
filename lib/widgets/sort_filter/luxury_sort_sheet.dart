import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/screens/home/category/show_platform_sort_sheet.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class LuxurySortSheet extends StatelessWidget {
  final SortOption initial;

  const LuxurySortSheet({
    super.key,
    this.initial = SortOption.mostSuitable,
  });

  static Future<SortOption?> show(
    BuildContext context, {
    SortOption initial = SortOption.mostSuitable,
  }) {
    AppHaptics.light();
    return showModalBottomSheet<SortOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LuxurySortSheet(initial: initial),
    );
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

    final sortOptions = [
      _SortItemData(
        option: SortOption.mostSuitable,
        title: 'Curated For You',
        subtitle: 'Personalized luxury recommendations',
        icon: CupertinoIcons.sparkles,
        iconColor: const Color(0xFF8B5CF6),
      ),
      _SortItemData(
        option: SortOption.popularity,
        title: 'Popularity & Trending',
        subtitle: 'Most viewed and added to bag',
        icon: CupertinoIcons.flame_fill,
        iconColor: const Color(0xFFEF4444),
      ),
      _SortItemData(
        option: SortOption.topRated,
        title: 'Top Customer Rated',
        subtitle: 'Highest customer satisfaction (4.8+ ★)',
        icon: CupertinoIcons.star_fill,
        iconColor: const Color(0xFFF59E0B),
      ),
      _SortItemData(
        option: SortOption.priceLowToHigh,
        title: 'Price: Low to High',
        subtitle: 'Accessible luxury essentials first',
        icon: CupertinoIcons.arrow_down_circle_fill,
        iconColor: const Color(0xFF10B981),
      ),
      _SortItemData(
        option: SortOption.priceHighToLow,
        title: 'Price: High to Low',
        subtitle: 'Haute Couture statement pieces first',
        icon: CupertinoIcons.arrow_up_circle_fill,
        iconColor: const Color(0xFF3B82F6),
      ),
      _SortItemData(
        option: SortOption.latestArrival,
        title: 'Newest Arrivals',
        subtitle: 'Fresh seasonal drops & releases',
        icon: CupertinoIcons.clock_fill,
        iconColor: const Color(0xFF06B6D4),
      ),
      _SortItemData(
        option: SortOption.discount,
        title: 'Special Privileges & Promos',
        subtitle: 'Exclusive seasonal sales & discounts',
        icon: CupertinoIcons.ticket_fill,
        iconColor: const Color(0xFFEC4899),
      ),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF090D14).withValues(alpha: 0.96)
                : const Color(0xFFF8FAFC).withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
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
                          child: const Icon(CupertinoIcons.arrow_up_arrow_down, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sort Collections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Arrange pieces by your priority',
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

                const SizedBox(height: 14),
                Divider(height: 1, color: borderColor),
                const SizedBox(height: 12),

                // Options list
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final item = sortOptions[i];
                    final isSelected = item.option == initial;

                    return PressableScale(
                      onTap: () {
                        AppHaptics.selection();
                        Navigator.pop(context, item.option);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: isDark ? 0.18 : 0.08)
                              : bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.6)
                                : borderColor,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: item.iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(item.icon, size: 18, color: item.iconColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? primaryColor : textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(CupertinoIcons.checkmark, size: 13, color: Colors.white),
                              )
                            else
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor, width: 1.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortItemData {
  final SortOption option;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _SortItemData({
    required this.option,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}
