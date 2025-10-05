import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/screens/home/home_ios.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';

class CategoryPage extends StatelessWidget {
  final String category;
  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final products = DemoDb.topPicks;

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
      child: Stack(
        children: [
          // Main content (grid of products)
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
                      (context, i) => ProductCardWidget(product: products[i]),
                      childCount: products.length,
                    ),
                    // In your SliverGrid delegate, give tiles a touch more height:
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                      color: Colors.white.withOpacity(0.7),
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
                        _BottomButton(
                          icon: CupertinoIcons.arrow_up_arrow_down,
                          label: "Sort",
                          onPressed: () {},
                        ),
                        const VerticalDivider(
                          width: 24,
                          thickness: 1,
                          color: Color(0x33000000),
                        ),
                        _BottomButton(
                          icon: CupertinoIcons.slider_horizontal_3,
                          label: "Filter",
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 18, color: CupertinoColors.black),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
