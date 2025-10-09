import 'package:flutter/material.dart';

class FilterResult {
  final Set<String> categories;
  final RangeValues priceRange; // (min, max) in dollars
  final int? ratingAtLeast; // 3, 4, 5 or null
  final Set<String> sizes; // e.g. ["S","M","L","38"]
  final String? colorName; // e.g. "Black"
  const FilterResult({
    required this.categories,
    required this.priceRange,
    required this.ratingAtLeast,
    required this.sizes,
    required this.colorName,
  });

  FilterResult copyWith({
    Set<String>? categories,
    RangeValues? priceRange,
    int? ratingAtLeast,
    Set<String>? sizes,
    String? colorName,
  }) {
    return FilterResult(
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      ratingAtLeast: ratingAtLeast,
      sizes: sizes ?? this.sizes,
      colorName: colorName,
    );
  }

  static const defaultMin = 1.0;
  static const defaultMax = 300.0;

  static FilterResult initial() => const FilterResult(
    categories: {"Men"},
    priceRange: RangeValues(85, 220),
    ratingAtLeast: null,
    sizes: {"L", "38"},
    colorName: "Black",
  );

  static FilterResult cleared() => const FilterResult(
    categories: {},
    priceRange: RangeValues(defaultMin, defaultMax),
    ratingAtLeast: null,
    sizes: {},
    colorName: null,
  );
}
