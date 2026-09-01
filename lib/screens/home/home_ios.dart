import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/screens/home/widget/category_pill_widget.dart';
import 'package:trentify/screens/home/widget/horizontal_products.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';
import 'package:trentify/screens/home/widget/search_fill_widget.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';
import 'package:trentify/widgets/section_header_widget.dart';

class TrendifyHomeCupertino extends StatefulWidget {
  const TrendifyHomeCupertino({super.key});

  @override
  State<TrendifyHomeCupertino> createState() => _TrendifyHomeCupertinoState();
}

class _TrendifyHomeCupertinoState extends State<TrendifyHomeCupertino> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final tabs = [
      context.tr('tab_all'),
      context.tr('tab_women'),
      context.tr('tab_men'),
      context.tr('tab_shoes'),
      context.tr('tab_bags'),
      context.tr('tab_luxury'),
      'Kids',
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Header Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('good_day'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Alex Rivera',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Notification Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/notification');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B22) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Icon(
                              CupertinoIcons.bell,
                              size: 20,
                              color: textPrimary,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
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

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: SearchFieldWidget(
                  placeholder: context.tr('search_placeholder'),
                  readOnly: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.search);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Hero Promo Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _PromoBanner(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Category Pills
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: CategoryPillsWidget(
                  tabs: tabs,
                  value: _selectedTab,
                  onTap: (i) => setState(() => _selectedTab = i),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            if (_selectedTab == 0) ...[
              // Top Picks Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                  child: SectionHeader(
                    title: context.tr('top_picks'),
                    onAction: () => context.pushNamed('category', pathParameters: {'name': 'Top Picks'}),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HorizontalProducts(products: DemoDb.topPicks),
                ),
              ),

              // Categories Grid Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: const SectionHeader(
                    title: 'Shop by Category',
                    variant: SectionHeaderVariant.materialAction,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final c = DemoDb.categories[index];
                    return _CategoryTile(
                      title: c.title,
                      imagePathOrUrl: c.imagePath,
                    );
                  }, childCount: DemoDb.categories.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.1,
                  ),
                ),
              ),

              // New Arrival Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                  child: SectionHeader(
                    title: context.tr('new_arrivals'),
                    onAction: () => context.pushNamed('category', pathParameters: {'name': 'New Arrivals'}),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HorizontalProducts(products: DemoDb.newArrivals),
                ),
              ),

              // Hot Deals Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                  child: SectionHeader(
                    title: context.tr('hot_deals'),
                    onAction: () => context.pushNamed('category', pathParameters: {'name': 'Hot Deals'}),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HorizontalProducts(products: DemoDb.hotDeals),
                ),
              ),
            ] else ...[
              // Filtered Category Header
              Builder(
                builder: (context) {
                  final categoryKeys = ['All', 'Women', 'Men', 'Shoe', 'Bag', 'Luxury', 'Kids'];
                  final currentCategoryKey = _selectedTab < categoryKeys.length ? categoryKeys[_selectedTab] : 'All';
                  final categoryProducts = DemoDb.getProductsByCategory(currentCategoryKey);

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tabs[_selectedTab]} Collection',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${categoryProducts.length} Curated Luxury Pieces',
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                          PressableScale(
                            onTap: () {
                              context.pushNamed('category', pathParameters: {'name': currentCategoryKey});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Sort & Filter',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(CupertinoIcons.slider_horizontal_3, size: 12, color: primaryColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Filtered Category Grid
              Builder(
                builder: (context) {
                  final categoryKeys = ['All', 'Women', 'Men', 'Shoe', 'Bag', 'Luxury', 'Kids'];
                  final currentCategoryKey = _selectedTab < categoryKeys.length ? categoryKeys[_selectedTab] : 'All';
                  final categoryProducts = DemoDb.getProductsByCategory(currentCategoryKey);

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = categoryProducts[index];
                          return AnimatedEntry(
                            delay: Duration(milliseconds: 40 * (index % 8)),
                            child: ProductCardWidget(product: product),
                          );
                        },
                        childCount: categoryProducts.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.66,
                      ),
                    ),
                  );
                },
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

// ======= Promo Banner Component =======

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    const double bannerHeight = 160;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return PressableScale(
      onTap: () {
        context.pushNamed('category', pathParameters: {'name': 'Luxury'});
      },
      child: Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.75),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Pattern Decoration
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Promo Texts
            Positioned.fill(
              left: 20,
              right: 140,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIMITED OFFER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '30% OFF',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'On selected luxury summer collections today.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Model / Promotion Graphic
            Positioned(
              right: 12,
              bottom: 0,
              child: Image.asset(
                'assets/images/demo/promotion.png',
                height: bannerHeight,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Category Bento Tile =======

class _CategoryTile extends StatelessWidget {
  final String title;
  final String? imagePathOrUrl;

  const _CategoryTile({required this.title, this.imagePathOrUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return PressableScale(
      onTap: () {
        context.pushNamed('category', pathParameters: {'name': title});
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 14,
              top: 14,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: textPrimary,
                ),
              ),
            ),
            if (imagePathOrUrl != null && imagePathOrUrl!.isNotEmpty)
              Positioned(
                right: 4,
                bottom: 0,
                child: Image.asset(
                  imagePathOrUrl!,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
