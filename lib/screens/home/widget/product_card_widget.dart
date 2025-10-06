import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/screens/home/widget/build_product_image_widget.dart';
import 'package:trentify/screens/home/widget/dark_circle_widget.dart';
import 'package:trentify/screens/home/widget/rating_chip_widget.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;

  const ProductCardWidget({required this.product, super.key});
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFFF1F2F4) : Colors.black;
    final bgColor = isDark ? Colors.black : const Color(0xFFF1F2F4);
    const priceColor = Color(0xFF528F65);
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;

        // image area (switches between Expanded vs AspectRatio based on constraints)
        Widget imageArea(Widget child) {
          if (hasBoundedHeight) {
            return Expanded(child: child);
          } else {
            return AspectRatio(aspectRatio: 3 / 4, child: child);
          }
        }

        final card = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: bgColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                imageArea(
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: tileBg),
                        BuildProductImageWidget(product.imageUrl),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: RatingChipWidget(rating: product.rating),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: DarkCircleWidget(
                            child: CupertinoButton(
                              padding: const EdgeInsets.all(6),
                              minSize: 0,
                              onPressed: () {},
                              child: const Icon(
                                CupertinoIcons.heart,
                                size: 18,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // TEXTS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: priceColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        );

        // If the parent didn’t give us a finite width (rare), constrain it.
        final needsWidth =
            !(constraints.hasBoundedWidth && constraints.maxWidth.isFinite);
        return needsWidth ? SizedBox(width: 160, child: card) : card;
      },
    );
  }
}
