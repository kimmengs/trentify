import 'dart:ui';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trentify/model/demodb.dart';

import 'package:trentify/screens/home/category/filter_sheet.dart';
import 'package:trentify/screens/home/category/show_platform_sort_sheet.dart';
import 'package:trentify/screens/home/home_ios.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';

class CategoryPage extends StatelessWidget {
  final String category;
  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Shared content (your grid + floating glass bar)
    Widget body() => Stack(
      children: [
        SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        ProductCardWidget(product: DemoDb.topPicks[i]),
                    childCount: DemoDb.topPicks.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.66,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Sort & Filter bar (glass style)
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black87
                        : Colors.white.withOpacity(0.7),
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
                      _BottomButtonPlatform(
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
                      _BottomButtonPlatform(
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
          ),
        ),
      ],
    );

    if (isCupertino) {
      // iOS/macOS look
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(category),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(CupertinoIcons.back),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(CupertinoIcons.search),
              SizedBox(width: 12),
              Icon(CupertinoIcons.ellipsis_vertical),
            ],
          ),
        ),
        child: body(),
      );
    }

    // Android/Material look
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              /* TODO: search */
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              /* TODO: menu */
            },
          ),
        ],
      ),
      body: body(),
    );
  }
}

class _BottomButtonPlatform extends StatelessWidget {
  final bool isCupertino;
  final bool isDark;
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final String label;
  final VoidCallback onPressed;

  const _BottomButtonPlatform({
    required this.isCupertino,
    required this.isDark,
    required this.cupertinoIcon,
    required this.materialIcon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isCupertino) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              cupertinoIcon,
              size: 18,
              color: isDark ? Colors.white : CupertinoColors.black,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? Colors.white : CupertinoColors.black,
              ),
            ),
          ],
        ),
      );
    }

    // Material button for Android
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(materialIcon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      style: TextButton.styleFrom(
        foregroundColor: isDark ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: const StadiumBorder(),
      ),
    );
  }
}
