import 'package:flutter/material.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/screens/home/widget/product_card_widget.dart';

class HorizontalProducts extends StatelessWidget {
  final List<Product> products;
  const HorizontalProducts({required this.products});

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
