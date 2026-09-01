class Product {
  final String id;
  final String title;
  final double price;
  final double rating;
  final String imageUrl;
  final String category;
  final double? originalPrice;
  final int? discountPercent;
  final int soldCount;
  final String brand;
  final List<String> gallery;
  final String description;

  const Product({
    this.id = '',
    required this.title,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.category = 'All',
    this.originalPrice,
    this.discountPercent,
    this.soldCount = 120,
    this.brand = 'Maison Trentify',
    this.gallery = const [],
    this.description = '',
  });

  String get effectiveId => id.isNotEmpty ? id : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
}
