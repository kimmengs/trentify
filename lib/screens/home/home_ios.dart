import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class TrendifyHomeCupertino extends StatefulWidget {
  const TrendifyHomeCupertino({super.key});

  @override
  State<TrendifyHomeCupertino> createState() => _TrendifyHomeCupertinoState();
}

class _TrendifyHomeCupertinoState extends State<TrendifyHomeCupertino> {
  final List<String> _tabs = const ['Discover', 'Women', 'Men', 'Shoe'];
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Trendify'),
            trailing: _ProfileButton(),
            leading: _BrandGlyph(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SearchField(
                placeholder: 'Search Trends…',
                onChanged: (v) {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PromoBanner(),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final selected = _selectedTab == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: selected
                              ? CupertinoColors.white
                              : CupertinoColors.label,
                          fontWeight: FontWeight.w600,
                        ),
                        child: Text(_tabs[i]),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: _tabs.length,
              ),
            ),
          ),

          // Featured row of products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: _HorizontalProducts(
                title: null,
                products: DemoDb.topPicks,
              ),
            ),
          ),

          // Category grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _SectionHeader(title: 'Categories'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final c = DemoDb.categories[index];
                return _CategoryPill(title: c.title, icon: c.icon);
              }, childCount: DemoDb.categories.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3.6,
              ),
            ),
          ),

          // New Arrival
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: _SectionHeader(title: 'New Arrival', action: 'View All'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HorizontalProducts(products: DemoDb.newArrivals),
            ),
          ),

          // Hot Deals This Week
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: _SectionHeader(
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

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: CupertinoColors.activeGreen,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'e',
        style: TextStyle(
          color: CupertinoColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: const Icon(CupertinoIcons.bell),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFe6f5ea),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '30% OFF',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  "Today's Special!\nGet discount for every order, only valid for today",
                  style: TextStyle(color: CupertinoColors.secondaryLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 96,
              height: 96,
              color: CupertinoColors.systemGrey4,
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.person_crop_circle_fill,
                size: 64,
                color: CupertinoColors.systemGrey2,
              ),
            ),
          ),
        ],
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
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (action != null)
          Row(
            children: [
              Text(
                action!,
                style: const TextStyle(
                  color: CupertinoColors.activeGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                CupertinoIcons.arrow_right_circle,
                size: 18,
                color: CupertinoColors.activeGreen,
              ),
            ],
          ),
      ],
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  final String? title;
  final List<Product> products;
  const _HorizontalProducts({this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          _SectionHeader(title: title!),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String title;
  final IconData icon;
  const _CategoryPill({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: CupertinoColors.systemGrey4,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: CupertinoColors.activeGreen),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 130,
              color: CupertinoColors.systemGrey5,
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.person_crop_square_fill,
                size: 50,
                color: CupertinoColors.systemGrey3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Rating(rating: product.rating),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 28,
                      onPressed: () {},
                      child: const Icon(
                        CupertinoIcons.heart,
                        size: 20,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  final double rating;
  const _Rating({required this.rating});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.star_fill,
          size: 14,
          color: CupertinoColors.systemYellow,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.placeholder, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.search,
            color: CupertinoColors.secondaryLabel,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField.borderless(
              placeholder: placeholder,
              onChanged: onChanged,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              CupertinoIcons.mic_fill,
              size: 18,
              color: CupertinoColors.activeGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Demo data =====
class Product {
  final String title;
  final double price;
  final double rating;
  const Product({
    required this.title,
    required this.price,
    required this.rating,
  });
}

class CategoryItem {
  final String title;
  final IconData icon;
  const CategoryItem(this.title, this.icon);
}

class DemoDb {
  static const topPicks = [
    Product(title: 'Urban Blend Long Sleeve', price: 185, rating: 4.8),
    Product(title: 'Luxe Blend Formal Tee', price: 160, rating: 4.6),
    Product(title: 'Urban Flex Cotton Hoodie', price: 175, rating: 4.7),
  ];

  static const categories = [
    CategoryItem('Women', CupertinoIcons.person_2),
    CategoryItem('Men', CupertinoIcons.person),
    CategoryItem('Shoe', CupertinoIcons.padlock),
    CategoryItem('Bag', CupertinoIcons.briefcase),
    CategoryItem('Luxury', CupertinoIcons.gift),
    CategoryItem('Kids', CupertinoIcons.smiley),
    CategoryItem('Sports', CupertinoIcons.sportscourt),
    CategoryItem('Beauty', CupertinoIcons.eyedropper),
    CategoryItem('Lifestyle', CupertinoIcons.person_crop_square),
    CategoryItem('Other', CupertinoIcons.headphones),
  ];

  static const newArrivals = [
    Product(title: 'Trend Craft Fleece Hoodie', price: 210, rating: 4.9),
    Product(title: 'Moda Chic Luxurious Top', price: 200, rating: 4.8),
    Product(title: 'Urban Elegant Blazer', price: 215, rating: 4.5),
  ];

  static const hotDeals = [
    Product(title: 'Street Style Cozy Hoodie', price: 120, rating: 4.5),
    Product(title: 'Street Style Comfort Tee', price: 95, rating: 4.7),
    Product(title: 'Vogue Fit Cotton', price: 140, rating: 4.6),
  ];
}
