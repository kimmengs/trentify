import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/screens/home/category/show_platform_sort_sheet.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/pressable_scale.dart';
import 'package:trentify/widgets/sort_filter/sort_filter_widget.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  SortOption _currentSort = SortOption.mostSuitable;
  FilterResult _currentFilter = FilterResult.initial();
  int _selectedSubcategoryIndex = 0;
  bool _isGridView = true; // true = 2-col grid, false = 1-col editorial list

  List<String> get _subcategories {
    final cat = widget.category.toLowerCase();
    if (cat.contains('women')) {
      return ['All Pieces', 'Dresses', 'Knitwear', 'Trench Coats', 'Blazers', 'Skirts'];
    } else if (cat.contains('men')) {
      return ['All Pieces', 'Shirts', 'Hoodies', 'Blazers', 'Knitwear', 'Denim'];
    } else if (cat.contains('shoe')) {
      return ['All Footwear', 'Loafers', 'Boots', 'Sneakers', 'Pumps'];
    } else if (cat.contains('bag')) {
      return ['All Bags', 'Crossbody', 'Totes', 'Duffles', 'Briefcases'];
    } else if (cat.contains('luxury')) {
      return ['All Luxury', 'Timepieces', 'Cashmere', 'Jewelry', 'Gala Attire'];
    } else if (cat.contains('kid')) {
      return ['All Kids', 'Knitwear', 'Jackets'];
    }
    return ['All Pieces', 'Featured', 'New Arrivals', 'Best Sellers'];
  }

  String get _categorySlogan {
    final cat = widget.category.toLowerCase();
    if (cat.contains('women')) return 'Elevated Silhouettes & Pure Silk';
    if (cat.contains('men')) return 'Tailored Suiting & Luxury Essentials';
    if (cat.contains('shoe')) return 'Artisanal Calfskin & Designer Footwear';
    if (cat.contains('bag')) return 'Signature Monograms & Handcrafted Leather';
    if (cat.contains('luxury')) return 'Haute Horlogerie & Precious Gems';
    if (cat.contains('kid')) return 'Organic Fibers & Playful Craftsmanship';
    return 'Curated Haute Couture Collection';
  }

  List<Product> _getFilteredProducts() {
    var list = List<Product>.from(DemoDb.getProductsByCategory(widget.category));

    // 1. Subcategory filter
    if (_selectedSubcategoryIndex > 0) {
      final sub = _subcategories[_selectedSubcategoryIndex].toLowerCase();
      list = list.where((p) {
        final t = p.title.toLowerCase();
        final d = p.description.toLowerCase();
        if (sub.contains('dress') || sub.contains('gala')) return t.contains('dress') || t.contains('gown') || d.contains('dress');
        if (sub.contains('knit') || sub.contains('sweater')) return t.contains('knit') || t.contains('turtleneck') || t.contains('sweater') || t.contains('jumper');
        if (sub.contains('coat') || sub.contains('trench')) return t.contains('coat') || t.contains('trench') || d.contains('coat');
        if (sub.contains('blazer')) return t.contains('blazer') || d.contains('blazer');
        if (sub.contains('skirt')) return t.contains('skirt') || d.contains('skirt');
        if (sub.contains('shirt')) return t.contains('shirt') || t.contains('oxford') || t.contains('tee') || t.contains('button');
        if (sub.contains('hoodie')) return t.contains('hoodie');
        if (sub.contains('denim') || sub.contains('jean')) return t.contains('denim') || t.contains('jean');
        if (sub.contains('loafer')) return t.contains('loafer');
        if (sub.contains('boot')) return t.contains('boot');
        if (sub.contains('sneaker')) return t.contains('sneaker') || t.contains('court');
        if (sub.contains('pump') || sub.contains('heel')) return t.contains('pump') || t.contains('heel');
        if (sub.contains('crossbody')) return t.contains('crossbody');
        if (sub.contains('tote')) return t.contains('tote');
        if (sub.contains('duffle')) return t.contains('duffle');
        if (sub.contains('briefcase')) return t.contains('briefcase');
        if (sub.contains('timepiece') || sub.contains('watch')) return t.contains('watch') || t.contains('chronograph');
        if (sub.contains('cashmere')) return t.contains('cashmere');
        if (sub.contains('jewelry') || sub.contains('bracelet')) return t.contains('bracelet') || t.contains('diamond');
        if (sub.contains('jacket')) return t.contains('jacket');
        return t.contains(sub) || d.contains(sub);
      }).toList();
    }

    // 2. Price range
    list = list
        .where((p) =>
            p.price >= _currentFilter.priceRange.start &&
            p.price <= _currentFilter.priceRange.end)
        .toList();

    // 3. Rating
    if (_currentFilter.ratingAtLeast != null) {
      list = list.where((p) => p.rating >= _currentFilter.ratingAtLeast!).toList();
    }

    // 4. Sort
    switch (_currentSort) {
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.latestArrival:
        list = list.reversed.toList();
        break;
      case SortOption.popularity:
      case SortOption.mostSuitable:
      case SortOption.discount:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    final products = _getFilteredProducts();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main Scrollable Body
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Spacing for Custom Glass Nav Bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 64,
                ),
              ),

              // Category Hero Spotlight Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                primaryColor.withValues(alpha: 0.25),
                                const Color(0xFF161B22),
                              ]
                            : [
                                primaryColor.withValues(alpha: 0.12),
                                Colors.white,
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? primaryColor.withValues(alpha: 0.3)
                            : primaryColor.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'MAISON TRENTIFY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.category} Collection',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _categorySlogan,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${products.length}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                'Pieces',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Subcategories Horizontal Selector
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _subcategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedSubcategoryIndex == index;
                      return PressableScale(
                        onTap: () {
                          AppHaptics.selection();
                          setState(() => _selectedSubcategoryIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : isDark
                                    ? const Color(0xFF161B22)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : borderColor,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              _subcategories[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Products Layout (Empty State OR Grid / List)
              if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withValues(alpha: 0.1),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.slider_horizontal_3,
                              size: 36,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Matching Pieces Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your price range or rating filters to discover more luxury pieces.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PressableScale(
                            onTap: () {
                              AppHaptics.medium();
                              setState(() {
                                _currentFilter = FilterResult.initial();
                                _currentSort = SortOption.mostSuitable;
                                _selectedSubcategoryIndex = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Reset All Filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => AnimatedEntry(
                        delay: Duration(milliseconds: 30 * (i % 8)),
                        child: ProductCardWidget(product: products[i]),
                      ),
                      childCount: products.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final product = products[i];
                        return AnimatedEntry(
                          delay: Duration(milliseconds: 40 * (i % 6)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _EditorialProductListCard(
                              product: product,
                              isDark: isDark,
                              primaryColor: primaryColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          ),

          // Custom Frosted Glass Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 8,
                    16,
                    12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF090D14).withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.90),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      PressableScale(
                        onTap: () {
                          AppHaptics.light();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF161B22) : Colors.white,
                            border: Border.all(color: borderColor, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            CupertinoIcons.arrow_left,
                            size: 18,
                            color: textPrimary,
                          ),
                        ),
                      ),

                      // Title
                      Column(
                        children: [
                          Text(
                            widget.category,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Maison Collection',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Actions (View Toggle + Search)
                      Row(
                        children: [
                          // Grid / List Toggle
                          PressableScale(
                            onTap: () {
                              AppHaptics.selection();
                              setState(() => _isGridView = !_isGridView);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF161B22) : Colors.white,
                                border: Border.all(color: borderColor, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isGridView
                                    ? CupertinoIcons.rectangle_grid_1x2
                                    : CupertinoIcons.square_grid_2x2,
                                size: 18,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Search Button
                          PressableScale(
                            onTap: () {
                              AppHaptics.light();
                              context.push(AppRoutes.search);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF161B22) : Colors.white,
                                border: Border.all(color: borderColor, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                CupertinoIcons.search,
                                size: 18,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Luxury Sort & Filter Bar
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: buildSortFilterBar(
              context: context,
              isCupertino: true,
              isDark: isDark,
              currentSort: _currentSort,
              currentFilter: _currentFilter,
              onSortChanged: (sort) => setState(() => _currentSort = sort),
              onFilterChanged: (filter) => setState(() => _currentFilter = filter),
            ),
          ),
        ],
      ),
    );
  }
}

// Editorial 1-Column List Card for High-Density Browsing
class _EditorialProductListCard extends StatelessWidget {
  final Product product;
  final bool isDark;
  final Color primaryColor;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _EditorialProductListCard({
    required this.product,
    required this.isDark,
    required this.primaryColor,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        context.pushNamed(
          'product-detail',
          pathParameters: {'id': product.effectiveId},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 100,
                height: 100,
                color: isDark ? const Color(0xFF090D14) : const Color(0xFFF1F5F9),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(CupertinoIcons.photo, size: 28, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Description
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Price & Free Shipping
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'EXPRESS DHL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
