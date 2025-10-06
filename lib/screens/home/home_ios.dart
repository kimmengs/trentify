// lib/screens/home/trendify_home_ios.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/screens/home/widget/category_pill_widget.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';
import 'package:trentify/screens/home/widget/search_fill_widget.dart';

class TrendifyHomeCupertino extends StatefulWidget {
  const TrendifyHomeCupertino({super.key});

  @override
  State<TrendifyHomeCupertino> createState() => _TrendifyHomeCupertinoState();
}

class _TrendifyHomeCupertinoState extends State<TrendifyHomeCupertino> {
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
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Trendify'),
            leading: const _BrandGlyph(),
            trailing: const _ProfileButton(),
            stretch: true,
            border: null,
          ),
          // Search (CupertinoSearchTextField)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchFieldWidget(
                placeholder: 'Search Trends…',
                onChanged: (v) {},
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          // Promo banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const _PromoBanner(),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          // Tabs (CupertinoSlidingSegmentedControl)
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

          // Featured row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _HorizontalProducts(products: DemoDb.topPicks),
            ),
          ),

          // Categories grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: const _SectionHeader(title: 'Categories'),
            ),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final c = DemoDb.categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: _CategoryTile(
                  title: c.title,
                  imagePathOrUrl: c.imagePath, // asset path OR network URL
                  icon: c.icon, // optional fallback
                ),
              );
            }, childCount: DemoDb.categories.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
          ),

          // New Arrival
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: const _SectionHeader(
                title: 'New Arrival',
                action: 'View All',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HorizontalProducts(products: DemoDb.newArrivals),
            ),
          ),

          // Hot Deals
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: const _SectionHeader(
                title: 'Hot Deals This Week',
                action: 'View All',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HorizontalProducts(products: DemoDb.hotDeals),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }
}

// ======= Cupertino Widgets =======

class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: _CircleGlyph(
        color: Color(0xFF528F65),
        child: Text(
          'e',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: const Icon(CupertinoIcons.bell),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const double bannerHeight = 170;

    return SizedBox(
      height: bannerHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                image: const DecorationImage(
                  image: AssetImage('assets/images/demo/image-bk-2.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  opacity: 0.4, // softens the white pattern
                ),
              ),
            ),

            // Text
            const Positioned.fill(
              left: 16,
              right: 160, // reserve space for the model
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 18, 0, 16),
                child: _PromoText(),
              ),
            ),

            // Image pinned to right, sized to banner height
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/demo/promotion.png',
                height: bannerHeight,
                fit: BoxFit.fitHeight,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoText extends StatelessWidget {
  const _PromoText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '30% OFF',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: CupertinoColors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Today's Special!",
          style: TextStyle(
            color: Color(0xFFDFF5E6),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Get discount for every\norder, only valid for today',
          style: TextStyle(color: Color(0xFFEAF7EE), height: 1.2),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final String? imagePathOrUrl; // <-- pass asset path or network URL
  final IconData? icon; // optional fallback icon

  const _CategoryTile({required this.title, this.imagePathOrUrl, this.icon});

  @override
  Widget build(BuildContext context) {
    const double bannerHeight = 90;

    return InkWell(
      onTap: () {
        context.pushNamed('category', pathParameters: {'name': title});
      },
      child: SizedBox(
        height: bannerHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF5F5F5,
                  ), // light gray (softer and cleaner)
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000), // subtle black with 20% opacity
                      blurRadius: 8, // how soft the shadow looks
                      offset: Offset(0, 3), // vertical movement
                    ),
                  ],
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ), // optional: soft corners
                ),
              ),
              // Text
              Positioned.fill(
                left: 5,
                top: 5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                    ),
                  ),
                ),
              ),

              // Image pinned to right, sized to banner height
              Positioned(
                right: 0,
                bottom: 0,
                child: Image.asset(
                  imagePathOrUrl!,
                  height: bannerHeight,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final base = CupertinoTheme.of(context).textTheme.navTitleTextStyle;
    return Row(
      children: [
        Text(title, style: base.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        if (action != null)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            onPressed: () {},
            child: Row(
              children: const [
                Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF528F65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  CupertinoIcons.arrow_right_circle,
                  size: 18,
                  color: Color(0xFF528F65),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TabsBar extends StatelessWidget {
  final List<String> tabs;
  final int value;
  final ValueChanged<int> onChanged;
  const _TabsBar({
    required this.tabs,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<int>(
      groupValue: value,
      children: {
        for (int i = 0; i < tabs.length; i++)
          i: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              tabs[i],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      },
      onValueChanged: (i) {
        if (i != null) onChanged(i);
      },
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final String? pathOrUrl;
  final IconData icon;

  const _CategoryImage({required this.pathOrUrl, required this.icon});

  bool get _isNetwork => (pathOrUrl ?? '').startsWith('http');

  @override
  Widget build(BuildContext context) {
    if (pathOrUrl == null || pathOrUrl!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 44, color: CupertinoColors.systemGrey),
      );
    }

    // Network URL
    if (_isNetwork) {
      return Image.network(
        pathOrUrl!,
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        errorBuilder: (_, __, ___) => Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 44, color: CupertinoColors.systemGrey),
        ),
      );
    }

    // Asset image
    return Image.asset(
      pathOrUrl!,
      fit: BoxFit.contain,
      alignment: Alignment.centerRight,
      errorBuilder: (_, __, ___) => Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 44, color: CupertinoColors.systemGrey),
      ),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  final List<Product> products;
  const _HorizontalProducts({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            ProductCardWidget(product: products[index]),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.placeholder, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      placeholder: placeholder,
      onChanged: onChanged,
      prefixIcon: const Icon(CupertinoIcons.search),
      suffixIcon: const Icon(CupertinoIcons.mic),
      backgroundColor: CupertinoColors.systemGrey5,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      borderRadius: BorderRadius.circular(14),
    );
  }
}

class _CircleGlyph extends StatelessWidget {
  final Color color;
  final Widget child;
  const _CircleGlyph({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

// ======= DEMO DATA (Cupertino Icons) =======

class CategoryItem {
  final String title;
  final String imagePath;
  final IconData? icon;
  const CategoryItem(this.title, this.imagePath, {this.icon});
}

class DemoDb {
  static const topPicks = [
    Product(
      title: 'Urban Blend Long Sleeve',
      price: 185,
      rating: 4.8,
      imageUrl: 'assets/images/demo/01.jpeg',
    ),
    Product(
      title: 'Luxe Blend Formal Tee',
      price: 160,
      rating: 4.6,
      imageUrl: 'assets/images/demo/02.jpeg',
    ),
    Product(
      title: 'Urban Flex Cotton Hoodie',
      price: 175,
      rating: 4.7,
      imageUrl: 'assets/images/demo/03.jpeg',
    ),
  ];

  static const categories = [
    CategoryItem('Women', 'assets/images/demo/promotion.png'),
    CategoryItem('Men', 'assets/images/demo/men.png'),
    CategoryItem('Shoe', 'assets/images/demo/shoe.png'),
    CategoryItem('Bag', 'assets/images/demo/bag.png'),
    CategoryItem('Luxury', 'assets/images/demo/luxury.png'),
    CategoryItem('Kids', 'assets/images/demo/kid.png'),
    CategoryItem('Sports', 'assets/images/demo/sport.png'),
    CategoryItem('Beauty', 'assets/images/demo/beauty.png'),
  ];

  static const newArrivals = [
    Product(
      title: 'Trend Craft Fleece Hoodie',
      price: 210,
      rating: 4.9,
      imageUrl: 'assets/images/demo/01.jpeg',
    ),
    Product(
      title: 'Moda Chic Luxurious Top',
      price: 200,
      rating: 4.8,
      imageUrl: 'assets/images/demo/02.jpeg',
    ),
    Product(
      title: 'Urban Elegant Blazer',
      price: 215,
      rating: 4.5,
      imageUrl: 'assets/images/demo/03.jpeg',
    ),
  ];

  static const hotDeals = [
    Product(
      title: 'Street Style Cozy Hoodie',
      price: 120,
      rating: 4.5,
      imageUrl: 'assets/images/demo/01.jpeg',
    ),
    Product(
      title: 'Street Style Comfort Tee',
      price: 95,
      rating: 4.7,
      imageUrl: 'assets/images/demo/02.jpeg',
    ),
    Product(
      title: 'Vogue Fit Cotton',
      price: 140,
      rating: 4.6,
      imageUrl: 'assets/images/demo/03.jpeg',
    ),
  ];
}
