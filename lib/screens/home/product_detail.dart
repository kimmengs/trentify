import 'dart:ui';
import 'package:flutter/material.dart';

/// --- DATA MODEL YOU CAN MAP FROM YOUR EXISTING PRODUCT ---
@immutable
class ProductDetailData {
  final String title;
  final double price;
  final List<String> images;
  final double rating; // 0..5
  final int soldCount;
  final List<String> sizes; // e.g., ["XS","S","M","L","XL"]
  final List<Color> colors; // swatches
  final Map<String, String> specs; // key -> value
  final String description;
  final List<ReviewData> reviews; // optional sample reviews
  final List<SuggestionData> suggestions; // "You may also like"
  final List<VoucherData> vouchers;

  const ProductDetailData({
    required this.title,
    required this.price,
    required this.images,
    required this.rating,
    required this.soldCount,
    required this.sizes,
    required this.colors,
    required this.specs,
    required this.description,
    this.reviews = const [],
    this.suggestions = const [],
    this.vouchers = const [],
  });
}

@immutable
class ReviewData {
  final String author;
  final String ago; // "2 weeks ago"
  final double stars;
  final String variant; // e.g., "L, Black"
  final String text;
  final List<String> photos; // optional thumbs

  const ReviewData({
    required this.author,
    required this.ago,
    required this.stars,
    required this.variant,
    required this.text,
    this.photos = const [],
  });
}

@immutable
class SuggestionData {
  final String image;
  final String title;
  final double price;
  final double rating;
  const SuggestionData({
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
  });
}

@immutable
class VoucherData {
  final String label; // e.g., "Best Deal: 20% OFF"
  final String code; // e.g., "2ODEALS"
  final String details; // e.g., "Min. spend \$150 • Valid till 12/31/2024"
  const VoucherData({
    required this.label,
    required this.code,
    required this.details,
  });
}

/// --- PAGE ---
class ProductDetailPage extends StatefulWidget {
  final ProductDetailData data;
  const ProductDetailPage({super.key, required this.data});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _pageController = PageController();
  int _imageIndex = 0;

  int _selectedSize = -1;
  int _selectedColor = 0;

  bool _descExpanded = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              /* TODO */
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              /* TODO */
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildImageCarousel(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.title,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${widget.data.price.toStringAsFixed(2)}',
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Tag(
                        text: '${_formatNumber(widget.data.soldCount)} sold',
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.data.rating.toStringAsFixed(1),
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vouchers
                  _SectionHeader(
                    title: 'Vouchers Available',
                    onViewAll: widget.data.vouchers.isNotEmpty ? () {} : null,
                  ),
                  if (widget.data.vouchers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.data.vouchers
                          .map((v) => _VoucherChip(v))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Size
                  _SectionHeader(title: 'Size'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: List.generate(widget.data.sizes.length, (i) {
                      final selected = _selectedSize == i;
                      return ChoiceChip(
                        label: Text(widget.data.sizes[i]),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedSize = i),
                        shape: const StadiumBorder(),
                        labelStyle: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Color
                  _SectionHeader(title: 'Color'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: List.generate(widget.data.colors.length, (i) {
                      final selected = _selectedColor == i;
                      return _ColorDot(
                        color: widget.data.colors[i],
                        selected: selected,
                        onTap: () => setState(() => _selectedColor = i),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Product info (specs)
                  _SectionHeader(title: 'Product Information'),
                  const SizedBox(height: 8),
                  _SpecTable(specs: widget.data.specs),
                  const SizedBox(height: 16),

                  // Description
                  _SectionHeader(title: 'Description'),
                  const SizedBox(height: 6),
                  _ExpandableText(
                    text: widget.data.description,
                    expanded: _descExpanded,
                    onToggle: () =>
                        setState(() => _descExpanded = !_descExpanded),
                  ),
                  const SizedBox(height: 16),

                  // Rating summary + histogram
                  _SectionHeader(title: 'Rating & Reviews', onViewAll: () {}),
                  const SizedBox(height: 10),
                  _RatingSummary(
                    average: widget.data.rating,
                    totalRatings: 2238,
                    totalReviews: 941,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Reviews (demo items)
          if (widget.data.reviews.isNotEmpty)
            SliverList.separated(
              itemCount: widget.data.reviews.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _ReviewTile(widget.data.reviews[i]),
            ),

          // Suggestions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: _SectionHeader(
                title: 'You May Also Like',
                onViewAll: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) =>
                    _SuggestionCard(widget.data.suggestions[i]),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: widget.data.suggestions.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 88),
          ), // space for bottom bar
        ],
      ),

      // Sticky bottom bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircleIconButton(
                icon: Icons.chat_bubble_outline,
                onTap: () {
                  /* TODO: Chat */
                },
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                icon: Icons.favorite_border,
                onTap: () {
                  /* TODO: Wishlist toggle */
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    /* TODO: Buy now */
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    /* TODO: Add to cart */
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _imageIndex = i),
            itemCount: widget.data.images.length,
            itemBuilder: (_, i) => Hero(
              tag: '${widget.data.title}-$i',
              child: Image.network(widget.data.images[i], fit: BoxFit.cover),
            ),
          ),
          // pill indicator
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black87
                          : Colors.white.withOpacity(0.75),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '${_imageIndex + 1}/${widget.data.images.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
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

/// --- SMALL UI PIECES ---

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (onViewAll != null)
          TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('View All'),
          ),
      ],
    );
  }
}

class _VoucherChip extends StatelessWidget {
  final VoucherData v;
  const _VoucherChip(this.v);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_outlined, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                v.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '${v.code} · ${v.details}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _SpecTable extends StatelessWidget {
  final Map<String, String> specs;
  const _SpecTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final rows = specs.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                e.key,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Text(':  '),
            Expanded(child: Text(e.value)),
          ],
        ),
      );
    }).toList();

    return Column(children: rows);
  }
}

class _ExpandableText extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  const _ExpandableText({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final max = expanded ? null : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: max,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: style,
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            expanded ? 'read less' : 'read more…',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double average;
  final int totalRatings;
  final int totalReviews;
  const _RatingSummary({
    required this.average,
    required this.totalRatings,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget bar(int stars, double fraction) {
      return Row(
        children: [
          SizedBox(width: 16, child: Text('$stars', style: text.labelMedium)),
          const SizedBox(width: 6),
          Expanded(child: LinearProgressIndicator(value: fraction)),
        ],
      );
    }

    // demo fractions; replace with real distribution
    final dist = [0.75, 0.16, 0.05, 0.03, 0.01];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // left: average + stars
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              average.toStringAsFixed(1),
              style: text.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) {
                final filled = i < average.round();
                return Icon(filled ? Icons.star : Icons.star_border, size: 18);
              }),
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatNumber(totalRatings)} rating • ${_formatNumber(totalReviews)} reviews',
              style: text.bodySmall,
            ),
          ],
        ),
        const SizedBox(width: 16),
        // right: histogram
        Expanded(
          child: Column(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: bar(5 - i, dist[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewData r;
  const _ReviewTile(this.r);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/avatar_placeholder.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.author,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(r.ago, style: text.bodySmall),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final filled = i < r.stars.round();
              return Icon(filled ? Icons.star : Icons.star_border, size: 16);
            }),
          ),
          const SizedBox(height: 6),
          Text('Variant : ${r.variant}', style: text.bodySmall),
          const SizedBox(height: 8),
          Text(r.text),
          if (r.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: r.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    r.photos[i],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final SuggestionData s;
  const _SuggestionCard(this.s);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(s.image, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white70,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 14),
              const SizedBox(width: 3),
              Text(s.rating.toStringAsFixed(1), style: text.labelMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${s.price.toStringAsFixed(2)}',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 44, height: 44, child: Icon(icon)),
      ),
    );
  }
}

/// --- HELPERS ---
String _formatNumber(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}
