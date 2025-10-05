import 'package:flutter/material.dart';

class TrendifyHomeMaterial extends StatefulWidget {
  const TrendifyHomeMaterial({super.key});

  @override
  State<TrendifyHomeMaterial> createState() => _TrendifyHomeMaterialState();
}

class _TrendifyHomeMaterialState extends State<TrendifyHomeMaterial> {
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Trendify'),
            leading: const _BrandGlyph(),
            actions: const [_ProfileButton()],
          ),

          // Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SearchField(
                placeholder: 'Search Trends…',
                onChanged: (v) {},
              ),
            ),
          ),

          // Promo banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const _PromoBanner(),
            ),
          ),

          // Category tabs
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                        color: selected ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Featured row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final c = DemoDb.categories[index];
                return _CategoryTile(
                  title: c.title,
                  // If you have images, pass them via imageProvider (AssetImage/NetworkImage).
                  // imageProvider: AssetImage('assets/cat_women.png'),
                  icon: c.icon, // fallback to big icon if no image
                );
              }, childCount: DemoDb.categories.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // Wider tile but with some height (closer to screenshot)
                childAspectRatio: 2.1, // <-- was 3.6 (too flat)
              ),
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

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final ImageProvider?
  imageProvider; // optional: use real images when you have them
  const _CategoryTile({required this.title, this.icon, this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Left: label
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Right: big image (or large icon) aligned to the right
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90, // narrower than height → rectangular feel
                  height: 72, // gives that “photo chunk” look
                  child: imageProvider != null
                      ? Image(image: imageProvider!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.white,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            icon ?? Icons.image_outlined,
                            size: 48,
                            color: Colors.grey.shade700,
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

// ======= WIDGETS (Material) =======

class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: CircleAvatar(
        backgroundColor: Colors.green,
        radius: 18,
        child: const Text(
          'e',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.notifications),
      tooltip: 'Notifications',
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({super.key});
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
                  style: TextStyle(color: Colors.black54),
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
              color: Colors.grey.shade400,
              alignment: Alignment.center,
              child: Icon(
                Icons.account_circle,
                size: 64,
                color: Colors.grey.shade300,
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
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (action != null)
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: const [
                Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_circle_right, size: 18, color: Colors.green),
              ],
            ),
          ),
      ],
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
        itemBuilder: (context, index) => _ProductCard(product: products[index]),
      ),
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
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: Colors.green),
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
    return SizedBox(
      width: 160, // fixed width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE TILE (rectangle, taller than wide)
          Material(
            elevation: 2,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // product image (placeholder, height > width)
                AspectRatio(
                  aspectRatio: 3 / 4, // rectangle (e.g. 120w x 160h)
                  child: Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),

                // rating chip (top-left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _RatingChip(rating: product.rating),
                ),

                // favorite circular button (top-right)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    elevation: 2,
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.favorite_border, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            product.title,
            maxLines: 1, // force single line
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),

          const SizedBox(height: 4),

          // Price (green)
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;
  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
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
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.mic, color: Colors.green, size: 18),
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ======= DEMO DATA =======

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
    CategoryItem('Women', Icons.woman),
    CategoryItem('Men', Icons.man),
    CategoryItem('Shoe', Icons.hiking), // close enough to a shoe icon
    CategoryItem('Bag', Icons.shopping_bag),
    CategoryItem('Luxury', Icons.card_giftcard),
    CategoryItem('Kids', Icons.child_care),
    CategoryItem('Sports', Icons.sports_basketball),
    CategoryItem('Beauty', Icons.brush),
    CategoryItem('Lifestyle', Icons.style),
    CategoryItem('Other', Icons.headphones),
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
