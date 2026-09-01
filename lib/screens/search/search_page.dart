import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchCtl;
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  int _selectedCategoryIndex = 0;

  final List<String> _recentSearches = [
    'Silk Blazer',
    'Cashmere Sweater',
    'Leather Bag',
    'Wool Trousers',
  ];

  final List<String> _trendingSearches = [
    'Italian Silk',
    'Obsidian Noir',
    'Summer Couture',
    'Oversized Hoodie',
    'Lug Loafers',
  ];

  final List<String> _categories = [
    'All',
    'Blazers',
    'Knitwear',
    'Hoodies',
    'Bags',
    'Shoes',
  ];

  // Aggregate all unique catalog products
  late final List<Product> _allProducts;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchCtl = TextEditingController(text: _query);

    // Merge catalog lists removing duplicates by title
    final seen = <String>{};
    _allProducts = [];
    for (final p in [
      ...DemoDb.topPicks,
      ...DemoDb.newArrivals,
      ...DemoDb.hotDeals,
      const Product(
        title: 'Oversized Silk Blend Blazer',
        price: 289.00,
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&auto=format&fit=crop&q=80',
      ),
      const Product(
        title: 'Minimalist Cashmere Knit Sweater',
        price: 195.00,
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800&auto=format&fit=crop&q=80',
      ),
      const Product(
        title: 'Structured Leather Crossbody Bag',
        price: 340.00,
        rating: 5.0,
        imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&auto=format&fit=crop&q=80',
      ),
      const Product(
        title: 'Pleated Wide-Leg Wool Trousers',
        price: 210.00,
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?w=800&auto=format&fit=crop&q=80',
      ),
    ]) {
      if (seen.add(p.title)) {
        _allProducts.add(p);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_query.isEmpty) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    var list = _allProducts;
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) => p.title.toLowerCase().contains(q)).toList();
    }
    if (_selectedCategoryIndex > 0) {
      final cat = _categories[_selectedCategoryIndex].toLowerCase();
      list = list.where((p) => p.title.toLowerCase().contains(cat)).toList();
    }
    return list;
  }

  void _submitSearch(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;
    AppHaptics.light();
    setState(() {
      _query = clean;
      _searchCtl.text = clean;
      if (!_recentSearches.contains(clean)) {
        _recentSearches.insert(0, clean);
      }
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    final results = _filteredProducts;
    final isSearching = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtl,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 15, color: textPrimary),
              onChanged: (val) => setState(() => _query = val),
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: context.tr('search_placeholder'),
                hintStyle: TextStyle(fontSize: 14, color: textSecondary),
                prefixIcon: Icon(CupertinoIcons.search, size: 18, color: textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          AppHaptics.light();
                          _searchCtl.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(CupertinoIcons.clear_circled_solid, size: 18, color: textSecondary),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: isSearching
            ? _buildSearchResults(results, textPrimary, textSecondary, primaryColor, isDark)
            : _buildSearchSuggestions(textPrimary, textSecondary, primaryColor, isDark),
      ),
    );
  }

  Widget _buildSearchSuggestions(
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    bool isDark,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // Recent Searches Header
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppHaptics.light();
                  setState(() => _recentSearches.clear());
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((term) {
              return PressableScale(
                onTap: () => _submitSearch(term),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.clock, size: 13, color: textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        term,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          AppHaptics.light();
                          setState(() => _recentSearches.remove(term));
                        },
                        child: Icon(CupertinoIcons.xmark, size: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
        ],

        // Trending Searches
        Row(
          children: [
            const Icon(CupertinoIcons.flame_fill, color: Color(0xFFEF4444), size: 18),
            const SizedBox(width: 6),
            Text(
              'Trending Searches',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trendingSearches.map((term) {
            return PressableScale(
              onTap: () => _submitSearch(term),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.12),
                      primaryColor.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  term,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // Curated Recommendations Header
        Text(
          'Popular in Haute Couture',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DemoDb.topPicks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.64,
          ),
          itemBuilder: (context, idx) {
            return ProductCardWidget(product: DemoDb.topPicks[idx]);
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    List<Product> results,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    bool isDark,
  ) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.search, size: 32, color: primaryColor),
              ),
              const SizedBox(height: 18),
              Text(
                'No matching pieces found',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for "Blazer", "Sweater", or "Bag"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: List.generate(_categories.length, (i) {
              final active = _selectedCategoryIndex == i;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PressableScale(
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _selectedCategoryIndex = i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? primaryColor : (isDark ? const Color(0xFF161B22) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? primaryColor
                            : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      _categories[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? Colors.white : textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Count Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text(
            '${results.length} Pieces Found for "$_query"',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ),

        // Products Grid
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.64,
            ),
            itemBuilder: (context, idx) {
              return AnimatedEntry(
                delay: Duration(milliseconds: 30 * idx),
                child: ProductCardWidget(product: results[idx]),
              );
            },
          ),
        ),
      ],
    );
  }
}
