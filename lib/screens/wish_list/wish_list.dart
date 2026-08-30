import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/main.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/screens/home/widget/build_product_image_widget.dart';
import 'package:trentify/screens/home/widget/category_pill_widget.dart';
import 'package:trentify/screens/home/widget/rating_chip_widget.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/animated_favorite_button.dart';
import 'package:trentify/widgets/pressable_scale.dart';
import 'package:trentify/widgets/sort_filter/sort_filter_widget.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  int _selectedTab = 0;
  bool _isGridView = true;
  bool _isSearchVisible = false;
  String _searchQuery = '';
  final _searchCtl = TextEditingController();

  // Dynamic wishlist items initialized from DemoDb
  late List<Product> _wishlistItems;

  @override
  void initState() {
    super.initState();
    _wishlistItems = [
      ...DemoDb.topPicks,
      ...DemoDb.newArrivals.take(2),
    ];
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _removeFromWishlist(Product product) {
    HapticFeedback.mediumImpact();
    setState(() {
      _wishlistItems.removeWhere((p) => p.title == product.title);
    });
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text('Removed "${product.title}" from wishlist'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _wishlistItems.add(product);
            });
          },
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    HapticFeedback.mediumImpact();
    context.read<CartProvider>().addToCart(
          title: product.title,
          price: product.price,
          imageUrl: product.imageUrl,
          size: 'M',
          colorName: 'Black',
          color: const Color(0xFF111214),
          qty: 1,
        );

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${product.title} added to bag!')),
          ],
        ),
        action: SnackBarAction(
          label: context.tr('view_bag'),
          textColor: Colors.amberAccent,
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }

  void _moveAllToBag() {
    HapticFeedback.heavyImpact();
    final cart = context.read<CartProvider>();
    for (final product in _wishlistItems) {
      cart.addToCart(
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        size: 'M',
        colorName: 'Black',
        color: const Color(0xFF111214),
        qty: 1,
      );
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('All ${_wishlistItems.length} items moved to shopping bag!'),
        action: SnackBarAction(
          label: context.tr('view_bag'),
          textColor: Colors.amberAccent,
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }

  void _clearAllWishlist() {
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(context.tr('clear')),
        content: const Text('Are you sure you want to remove all saved items?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _wishlistItems.clear());
            },
            child: Text(context.tr('clear')),
          ),
        ],
      ),
    );
  }

  List<Product> get _filteredItems {
    var list = _wishlistItems;

    // Filter by category tab
    if (_selectedTab == 1) {
      list = list.where((p) => p.title.toLowerCase().contains('shirt') || p.title.toLowerCase().contains('hoodie') || p.title.toLowerCase().contains('top')).toList();
    } else if (_selectedTab == 2) {
      list = list.where((p) => p.title.toLowerCase().contains('shoe') || p.title.toLowerCase().contains('sneaker')).toList();
    } else if (_selectedTab == 3) {
      list = list.where((p) => p.title.toLowerCase().contains('bag')).toList();
    } else if (_selectedTab == 4) {
      list = list.where((p) => p.title.toLowerCase().contains('blazer') || p.title.toLowerCase().contains('formal')).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) => p.title.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    final tabs = [
      context.tr('tab_all_items'),
      context.tr('tab_clothing'),
      context.tr('tab_shoes'),
      context.tr('tab_bags'),
      context.tr('tab_luxury'),
    ];

    final displayItems = _filteredItems;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          '${context.tr('nav_wishlist')} (${_wishlistItems.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(CupertinoIcons.back, color: textPrimary),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        actions: [
          // Search Toggle Button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchCtl.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: Icon(
              _isSearchVisible ? CupertinoIcons.search_circle_fill : CupertinoIcons.search,
              size: 20,
              color: _isSearchVisible ? primaryColor : textPrimary,
            ),
          ),

          // Layout Mode Toggle (Grid vs List)
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _isGridView = !_isGridView);
            },
            icon: Icon(
              _isGridView ? CupertinoIcons.list_bullet : CupertinoIcons.square_grid_2x2,
              size: 20,
              color: textPrimary,
            ),
          ),

          // Overflow Menu (Move All / Clear All)
          if (_wishlistItems.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(CupertinoIcons.ellipsis, size: 20, color: textPrimary),
              color: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (val) {
                if (val == 'move_all') {
                  _moveAllToBag();
                } else if (val == 'clear_all') {
                  _clearAllWishlist();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'move_all',
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.bag_badge_plus, size: 16, color: primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        context.tr('move_all_to_bag'),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.trash, size: 16, color: Color(0xFFEF4444)),
                      const SizedBox(width: 10),
                      Text(
                        context.tr('clear'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Collapsible Search Bar
              if (_isSearchVisible)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtl,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 14,
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search saved items...',
                          hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                          prefixIcon: Icon(CupertinoIcons.search, size: 18, color: textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(CupertinoIcons.clear_thick_circled, size: 16),
                                  onPressed: () {
                                    _searchCtl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  ),
                ),

              // Category Pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: CategoryPillsWidget(
                    tabs: tabs,
                    value: _selectedTab,
                    onTap: (i) => setState(() => _selectedTab = i),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Content: Empty State vs Grid vs List
              if (displayItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyWishlistState(
                    isDark: isDark,
                    primaryColor: primaryColor,
                    isSearching: _searchQuery.isNotEmpty,
                  ),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 280,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = displayItems[index];
                      return AnimatedEntry(
                        delay: Duration(milliseconds: index * 35),
                        child: _WishlistGridCard(
                          product: item,
                          isDark: isDark,
                          primaryColor: primaryColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onRemove: () => _removeFromWishlist(item),
                          onAddToCart: () => _addToCart(item),
                        ),
                      );
                    }, childCount: displayItems.length),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = displayItems[index];
                      return AnimatedEntry(
                        delay: Duration(milliseconds: index * 35),
                        child: _WishlistListCard(
                          product: item,
                          isDark: isDark,
                          primaryColor: primaryColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onRemove: () => _removeFromWishlist(item),
                          onAddToCart: () => _addToCart(item),
                        ),
                      );
                    }, childCount: displayItems.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),

          // Floating Sort & Filter Capsule Bar
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: buildSortFilterBar(
                context: context,
                isCupertino: isCupertino,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistGridCard extends StatelessWidget {
  final Product product;
  final bool isDark;
  final Color primaryColor;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistGridCard({
    required this.product,
    required this.isDark,
    required this.primaryColor,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        context.pushNamed(
          'product-detail',
          pathParameters: {'id': 'ubl-ss-001'},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                    child: buildProductImageWidget(product.imageUrl),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: RatingChipWidget(rating: product.rating),
                  ),
                  // Heart Active Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedFavoriteButton(
                      initialIsFavorite: true,
                      onChanged: (isFav) {
                        if (!isFav) onRemove();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product Details & Quick Bag Action
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      // 1-Tap Quick Add to Bag Pill
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.bag_badge_plus,
                            size: 13,
                            color: Colors.white,
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

class _WishlistListCard extends StatelessWidget {
  final Product product;
  final bool isDark;
  final Color primaryColor;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistListCard({
    required this.product,
    required this.isDark,
    required this.primaryColor,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 84,
              height: 94,
              child: buildProductImageWidget(product.imageUrl),
            ),
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(
                        CupertinoIcons.heart_fill,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Rating & Stock Chip
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      '${product.rating}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        context.tr('in_stock'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Price and Add to Bag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: primaryColor,
                      ),
                    ),
                    PressableScale(
                      onTap: onAddToCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.bag_badge_plus, size: 13, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('view_bag'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }
}

class _EmptyWishlistState extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;
  final bool isSearching;

  const _EmptyWishlistState({
    required this.isDark,
    required this.primaryColor,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.heart,
                size: 42,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'No Matching Items Found' : context.tr('empty_wishlist_title'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try searching with different keywords.'
                  : context.tr('empty_wishlist_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            PressableScale(
              onTap: () => context.go(AppRoutes.home),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('start_shopping'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
