import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/helper/format_number.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/screens/add_to_cart/add_to_cart.dart';
import 'package:trentify/screens/chat/product_chat_page.dart';
import 'package:trentify/screens/home/widget/horizontal_products.dart';
import 'package:trentify/screens/home/widget/rating_summary_widget.dart';
import 'package:trentify/screens/home/widget/review_tile_widget.dart';
import 'package:trentify/widgets/pressable_scale.dart';

final colorDots = const <String, Color>{
  "Black": Color(0xFF111214),
  "White": Color(0xFFF8FAFC),
  "Brown": Color(0xFF7C543A),
  "Blue Grey": Color(0xFF6C8A99),
  "Indigo": Color(0xFF5D50C6),
  "Deep Purple": Color(0xFF6F3CC3),
};

final standardSizes = const ["XS", "S", "M", "L", "XL", "XXL"];

/// --- DATA MODEL YOU CAN MAP FROM YOUR EXISTING PRODUCT ---
@immutable
class ProductDetailData {
  final String title;
  final double price;
  final List<String> images;
  final double rating; // 0..5
  final int soldCount;
  final List<String> sizes;
  final List<Color> colors;
  final Map<String, String> specs;
  final String description;
  final List<ReviewData> reviews;
  final List<SuggestionData> suggestions;
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
  final String ago;
  final double stars;
  final String variant;
  final String text;
  final List<String> photos;

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
  final String label;
  final String code;
  final String details;
  const VoucherData({
    required this.label,
    required this.code,
    required this.details,
  });
}

/// --- PRODUCT DETAIL PAGE ---
class ProductDetailPage extends StatefulWidget {
  final FilterResult initial;
  final ProductDetailData data;
  const ProductDetailPage({
    super.key,
    required this.data,
    required this.initial,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String _size;
  late String _selectedColorName;
  final _pageController = PageController();
  int _imageIndex = 0;
  bool _isWishlisted = false;
  bool _isAdded = false;
  Timer? _addedResetTimer;

  // Accordion state
  bool _descExpanded = false;
  bool _specsOpen = true;
  bool _deliveryOpen = false;

  @override
  void initState() {
    super.initState();
    _size = widget.data.sizes.isNotEmpty ? widget.data.sizes.first : 'M';
    _selectedColorName = widget.initial.colorName ?? 'Black';
  }

  @override
  void dispose() {
    _addedResetTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openCart() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => const AddToCartPage(),
      ),
    );
  }

  void _addToBag() {
    HapticFeedback.mediumImpact();
    final selectedColorValue = colorDots[_selectedColorName] ??
        (widget.data.colors.isNotEmpty
            ? widget.data.colors.first
            : const Color(0xFF111214));
    final firstImage = widget.data.images.isNotEmpty
        ? widget.data.images.first
        : '';

    CartProvider.instance.addToCart(
      title: widget.data.title,
      price: widget.data.price,
      imageUrl: firstImage,
      size: _size,
      colorName: _selectedColorName,
      color: selectedColorValue,
      qty: 1,
    );

    _addedResetTimer?.cancel();
    setState(() {
      _isAdded = true;
    });

    _addedResetTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isAdded = false;
        });
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: isDark
            ? const Color(0xFF1E2633)
            : const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF10B981),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('item_added_to_cart'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Size: $_size • $_selectedColorName',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                messenger.hideCurrentSnackBar();
                _openCart();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.tr('view_bag'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatWithSeller() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => ProductChatPage(
          product: widget.data,
          selectedSize: _size,
          selectedColor: _selectedColorName,
        ),
      ),
    );
  }

  void _showSizeGuideModal(BuildContext context, bool isDark, Color cardBg, Color borderColor, Color textPrimary, Color textSecondary, Color primaryColor) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('size_guide'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Garment measurements in inches. Fits true to size with a tailored silhouette.',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Table(
                  border: TableBorder.symmetric(inside: BorderSide(color: borderColor, width: 0.8)),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9)),
                      children: const [
                        Padding(padding: EdgeInsets.all(10), child: Text('Size', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(10), child: Text('Chest', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(10), child: Text('Length', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(10), child: Text('Shoulder', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                      ],
                    ),
                    _tableRow('XS', '36 - 38"', '27.5"', '17.0"'),
                    _tableRow('S', '38 - 40"', '28.0"', '17.5"'),
                    _tableRow('M', '40 - 42"', '28.5"', '18.0"'),
                    _tableRow('L', '42 - 44"', '29.0"', '18.5"'),
                    _tableRow('XL', '44 - 46"', '29.5"', '19.0"'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableRow(String s, String c, String l, String sh) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(s, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        Padding(padding: const EdgeInsets.all(10), child: Text(c, style: const TextStyle(fontSize: 12))),
        Padding(padding: const EdgeInsets.all(10), child: Text(l, style: const TextStyle(fontSize: 12))),
        Padding(padding: const EdgeInsets.all(10), child: Text(sh, style: const TextStyle(fontSize: 12))),
      ],
    );
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

    final sizeList = widget.data.sizes.isNotEmpty ? widget.data.sizes : standardSizes;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Collapsible Image Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _GlassIconButton(
                icon: CupertinoIcons.back,
                onTap: () => Navigator.of(context).pop(),
                isDark: isDark,
              ),
            ),
            actions: [
              _GlassIconButton(
                icon: CupertinoIcons.chat_bubble_2_fill,
                onTap: _openChatWithSeller,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _GlassCartIconButton(
                isDark: isDark,
                onTap: _openCart,
              ),
              const SizedBox(width: 8),
              _GlassIconButton(
                icon: CupertinoIcons.share,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  messenger?.showSnackBar(
                    const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Product link copied to clipboard!')),
                  );
                },
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _GlassIconButton(
                icon: _isWishlisted ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                iconColor: _isWishlisted ? const Color(0xFFEF4444) : null,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _isWishlisted = !_isWishlisted);
                },
                isDark: isDark,
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(context, isDark),
            ),
          ),

          // Main Product Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Category Micro-Eyebrow
                  Row(
                    children: [
                      Text(
                        'MAISON TRENTIFY • STUDIO COLLECTION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('in_stock'),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Refined Product Title
                  Text(
                    widget.data.title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.3,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Price & Micro-Rating Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${widget.data.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 3),
                            Text(
                              widget.data.rating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textPrimary),
                            ),
                            Text(
                              ' (248)',
                              style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Text(
                          '${formatNumber(widget.data.soldCount)} sold',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Compact Promo Voucher Tickets Carousel
                  if (widget.data.vouchers.isNotEmpty) ...[
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.data.vouchers.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final v = widget.data.vouchers[i];
                          return PressableScale(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  content: Text('${v.code}: ${context.tr('copied_code')}'),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: primaryColor.withValues(alpha: 0.25), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.ticket_fill, size: 14, color: primaryColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    v.label,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: primaryColor),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '• ${v.code}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Size Selection Section (Sleek Horizontal Pills)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _microSectionLabel(context.tr('select_size').toUpperCase(), textSecondary),
                      GestureDetector(
                        onTap: () => _showSizeGuideModal(context, isDark, cardBg, borderColor, textPrimary, textSecondary, primaryColor),
                        child: Row(
                          children: [
                            Icon(Icons.straighten_rounded, size: 14, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('size_guide'),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sizeList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final s = sizeList[i];
                        final isSel = _size == s;
                        return PressableScale(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _size = s);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 52,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor : cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? primaryColor : borderColor,
                                width: isSel ? 1.5 : 1,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isSel ? Colors.white : textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Color Selection Section (Sleek Micro Swatches)
                  Row(
                    children: [
                      _microSectionLabel(context.tr('select_color').toUpperCase(), textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '• $_selectedColorName',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: colorDots.entries.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final entry = colorDots.entries.elementAt(i);
                        final name = entry.key;
                        final color = entry.value;
                        final isSel = _selectedColorName == name;

                        return PressableScale(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedColorName = name);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? primaryColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                              child: isSel
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Expandable Luxury Accordions (Description, Specs, Delivery)
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Description Tile
                        _accordionTile(
                          icon: CupertinoIcons.doc_plaintext,
                          title: context.tr('description'),
                          isOpen: _descExpanded,
                          onToggle: () => setState(() => _descExpanded = !_descExpanded),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          primaryColor: primaryColor,
                          content: Text(
                            widget.data.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: textSecondary,
                            ),
                          ),
                          showDivider: true,
                          borderColor: borderColor,
                        ),

                        // Specifications & Material Tile
                        _accordionTile(
                          icon: CupertinoIcons.sparkles,
                          title: context.tr('composition_care'),
                          isOpen: _specsOpen,
                          onToggle: () => setState(() => _specsOpen = !_specsOpen),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          primaryColor: primaryColor,
                          content: Column(
                            children: widget.data.specs.entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: Text(
                                        e.key,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          showDivider: true,
                          borderColor: borderColor,
                        ),

                        // Complimentary Delivery & Returns Tile
                        _accordionTile(
                          icon: CupertinoIcons.cube_box,
                          title: context.tr('delivery_returns'),
                          isOpen: _deliveryOpen,
                          onToggle: () => setState(() => _deliveryOpen = !_deliveryOpen),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          primaryColor: primaryColor,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _perkRow(CupertinoIcons.car_detailed, 'Complimentary express delivery on orders over \$100 (2-3 business days).', textSecondary),
                              const SizedBox(height: 8),
                              _perkRow(CupertinoIcons.arrow_2_squarepath, '30-day effortless worldwide returns with prepaid return shipping labels.', textSecondary),
                              const SizedBox(height: 8),
                              _perkRow(CupertinoIcons.shield_lefthalf_fill, '100% Genuine designer authenticity guarantee.', textSecondary),
                            ],
                          ),
                          showDivider: false,
                          borderColor: borderColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Compact Verified Boutique Merchant Card
                  _buildSellerStoreCard(context, isDark, cardBg, borderColor, textPrimary, textSecondary, primaryColor),

                  const SizedBox(height: 22),

                  // Customer Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _microSectionLabel(context.tr('customer_reviews').toUpperCase(), textSecondary),
                      Text(
                        '${widget.data.rating} / 5.0 ★',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  RatingSummaryWidget(
                    average: widget.data.rating,
                    totalRatings: 2238,
                    totalReviews: 941,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Reviews List
          if (widget.data.reviews.isNotEmpty)
            SliverList.separated(
              itemCount: widget.data.reviews.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: borderColor),
              itemBuilder: (_, i) => ReviewTileWidget(widget.data.reviews[i]),
            ),

          // "You May Also Like" Curated Recommendations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: _microSectionLabel(context.tr('you_may_also_like').toUpperCase(), textSecondary),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HorizontalProducts(products: DemoDb.newArrivals),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      // Fixed Ultra-Clean Luxury Bottom Checkout Bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF161B22).withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.96),
            border: Border(top: BorderSide(color: borderColor, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Chat with Stylist Button
              PressableScale(
                onTap: _openChatWithSeller,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2633) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(CupertinoIcons.chat_bubble_2_fill, size: 20, color: primaryColor),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Price Breakdown
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('total_price'),
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${widget.data.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // "Add to Bag" Primary CTA Button
              Expanded(
                child: PressableScale(
                  onTap: _addToBag,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isAdded ? const Color(0xFF10B981) : primaryColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (_isAdded
                                  ? const Color(0xFF10B981)
                                  : primaryColor)
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isAdded
                                ? Icons.check_circle_rounded
                                : CupertinoIcons.bag_fill,
                            key: ValueKey<bool>(_isAdded),
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isAdded
                              ? context.tr('item_added_to_cart')
                              : context.tr('add_to_bag'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
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

  Widget _microSectionLabel(String label, Color textSecondary) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: textSecondary,
      ),
    );
  }

  Widget _perkRow(IconData icon, String text, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, height: 1.4, color: textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _accordionTile({
    required IconData icon,
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required Widget content,
    required bool showDivider,
    required Color borderColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                ),
                Icon(
                  isOpen ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                  size: 14,
                  color: textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: content,
          ),
        if (showDivider)
          Divider(height: 1, indent: 46, endIndent: 16, color: borderColor),
      ],
    );
  }

  Widget _buildSellerStoreCard(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    final seller = SellerProvider.instance.profile;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(seller.logoUrl),
                backgroundColor: borderColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            seller.name,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: primaryColor),
                      ],
                    ),
                    Text(
                      '${context.tr("official_store")} • ★ ${seller.rating}',
                      style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openChatWithSeller,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.chat_bubble_text, size: 13, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('chat_with_seller'),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, bool isDark) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _imageIndex = i),
            itemCount: widget.data.images.length,
            itemBuilder: (_, i) => Image.network(widget.data.images[i], fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_imageIndex + 1}/${widget.data.images.length}',
                      style: TextStyle(
                        fontSize: 11,
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PressableScale(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCartIconButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _GlassCartIconButton({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartProvider.instance,
      builder: (context, _) {
        final count = CartProvider.instance.totalCount;
        return Center(
          child: PressableScale(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.bag_fill,
                        size: 18,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
