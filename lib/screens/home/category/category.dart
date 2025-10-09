import 'dart:ui';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trentify/model/demodb.dart';

import 'package:trentify/screens/home/widget/product_card_widget.dart';
import 'package:trentify/widgets/sort_filter/sort_filter_widget.dart';

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
          child: buildSortFilterBar(
            context: context,
            isCupertino: isCupertino,
            isDark: isDark,
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
