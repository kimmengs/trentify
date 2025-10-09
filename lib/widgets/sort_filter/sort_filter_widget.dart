import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/screens/home/category/filter_sheet.dart';
import 'package:trentify/screens/home/category/show_platform_sort_sheet.dart';
import 'package:trentify/widgets/bottom_button_platform_widget.dart';

Widget buildSortFilterBar({
  required BuildContext context,
  required bool isCupertino,
  required bool isDark,
}) {
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.black87 : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomButtonPlatformWidget(
                isCupertino: isCupertino,
                isDark: isDark,
                cupertinoIcon: CupertinoIcons.arrow_up_arrow_down,
                materialIcon: Icons.swap_vert_rounded,
                label: 'Sort',
                onPressed: () async {
                  final picked = await showPlatformSortSheet(
                    context,
                    initial: SortOption.mostSuitable,
                  );
                  debugPrint('Sort picked: $picked');
                },
              ),
              const VerticalDivider(
                width: 24,
                thickness: 1,
                color: Color(0x33000000),
              ),
              BottomButtonPlatformWidget(
                isCupertino: isCupertino,
                isDark: isDark,
                cupertinoIcon: CupertinoIcons.slider_horizontal_3,
                materialIcon: Icons.tune,
                label: 'Filter',
                onPressed: () async {
                  final picked = await showPlatformFilterSheet(
                    context,
                    initial: FilterResult.initial(),
                  );
                  if (picked != null) {
                    debugPrint('Filter picked: $picked');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
