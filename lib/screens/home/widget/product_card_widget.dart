import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/screens/home/widget/build_product_image_widget.dart';
import 'package:trentify/screens/home/widget/rating_chip_widget.dart';
import 'package:trentify/widgets/animated_favorite_button.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final String? heroTag;

  const ProductCardWidget({required this.product, this.heroTag, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;

        Widget imageArea(Widget child) {
          if (hasBoundedHeight) {
            return Expanded(child: child);
          } else {
            return AspectRatio(aspectRatio: 3 / 3.8, child: child);
          }
        }

        final card = PressableScale(
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
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header with Badges
                imageArea(
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                        child: heroTag != null
                            ? Hero(
                                tag: heroTag!,
                                child: buildProductImageWidget(product.imageUrl),
                              )
                            : buildProductImageWidget(product.imageUrl),
                      ),
                      // Rating Chip
                      Positioned(
                        top: 10,
                        left: 10,
                        child: RatingChipWidget(rating: product.rating),
                      ),
                      // Wishlist Heart Button with Spring Animation
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedFavoriteButton(
                          initialIsFavorite: false,
                          onChanged: (val) {},
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Section
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
                          Flexible(
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'FREE SHIP',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
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

        final needsWidth =
            !(constraints.hasBoundedWidth && constraints.maxWidth.isFinite);
        return needsWidth ? SizedBox(width: 170, child: card) : card;
      },
    );
  }
}
