import 'package:flutter/material.dart';
import 'package:trentify/main.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/screens/home/widget/category_pill_widget.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';
import 'package:trentify/widgets/sort_filter/sort_filter_widget.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  final List<String> _tabs = const [
    'Discover',
    'Women',
    'Men',
    'Shoe',
    'Bag',
    'Luxury',
    'Kids',
  ];
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF111315),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111315),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.all_inclusive), // placeholder for logo
          ),
        ),
        title: const Text(
          'Wishlist (25)',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const SizedBox(width: 4),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 56,
                  child: CategoryPillsWidget(
                    tabs: _tabs,
                    value: _selectedTab,
                    onTap: (i) => setState(() => _selectedTab = i),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 290,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return ProductCardWidget(product: DemoDb.topPicks[index]);
                  }, childCount: DemoDb.topPicks.length),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 140),
              ), // space for floating bar + nav
            ],
          ),

          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: buildSortFilterBar(
              context: context,
              isCupertino: isCupertino,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}
