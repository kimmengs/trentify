import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trentify/currency/currency_controller.dart';

/// A standardized luxury price display widget with currency formatting,
/// optional original price strikethrough, and configurable hierarchy.
class AppPriceText extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final String? currencySymbol;

  const AppPriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.fontSize = 16,
    this.color,
    this.fontWeight = FontWeight.w900,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strikeColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF94A3B8);

    CurrencyController? currencyCtl;
    try {
      currencyCtl = context.watch<CurrencyController>();
    } catch (_) {
      currencyCtl = null;
    }

    final formattedPrice = currencySymbol != null
        ? '$currencySymbol${price.toStringAsFixed(2)}'
        : (currencyCtl?.format(price) ?? '\$${price.toStringAsFixed(2)}');

    final formattedOriginal = originalPrice != null
        ? (currencySymbol != null
            ? '$currencySymbol${originalPrice!.toStringAsFixed(2)}'
            : (currencyCtl?.format(originalPrice!) ?? '\$${originalPrice!.toStringAsFixed(2)}'))
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formattedPrice,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: primaryColor,
            letterSpacing: -0.3,
          ),
        ),
        if (formattedOriginal != null && originalPrice! > price) ...[
          const SizedBox(width: 6),
          Text(
            formattedOriginal,
            style: TextStyle(
              fontSize: fontSize * 0.75,
              fontWeight: FontWeight.w500,
              color: strikeColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}
