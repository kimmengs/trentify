import 'dart:ui';

import 'package:trentify/model/product.dart';
import 'package:trentify/screens/home/home_ios.dart';
import 'package:trentify/screens/home/product_detail.dart';
import 'package:flutter/material.dart';

class RawVoucher {
  final String label, code, details;
  const RawVoucher({
    required this.label,
    required this.code,
    required this.details,
  });
}

class RawReview {
  final String author, ago, variant, text;
  final double stars;
  final List<String> photos;
  const RawReview({
    required this.author,
    required this.ago,
    required this.stars,
    required this.variant,
    required this.text,
    this.photos = const [],
  });
}

class RawSuggestion {
  final String image, title;
  final double price, rating;
  const RawSuggestion({
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
  });
}

class RawProduct {
  final String id, name, description, material, care, sku, neck, pattern;
  final double price, rating;
  final int sold;
  final List<String> imageUrls, sizes;
  final List<int> colorHexes; // ARGB ints, e.g. 0xFF000000
  final List<RawVoucher> vouchers;
  final List<RawReview> reviews;
  final List<RawSuggestion> suggestions;

  const RawProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    required this.rating,
    required this.sold,
    required this.sizes,
    required this.colorHexes,
    required this.material,
    required this.care,
    required this.sku,
    required this.neck,
    required this.pattern,
    required this.description,
    this.vouchers = const [],
    this.reviews = const [],
    this.suggestions = const [],
  });
}

class DemoDb {
  static final Map<String, RawProduct> _products = {
    // ---------------- Product A ----------------
    'ubl-ss-001': RawProduct(
      id: 'ubl-ss-001',
      name: 'Urban Blend Long Sleeve Shirt',
      price: 185.00,
      imageUrls: const [
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=1200&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1520975922203-b6a5969c8d46?q=80&w=1200&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1520975619010-6b2a5d4fb70e?q=80&w=1200&auto=format&fit=crop',
      ],
      rating: 4.8,
      sold: 2475,
      sizes: const ['XS', 'S', 'M', 'L', 'XL'],
      colorHexes: const [
        0xFF000000, // Black
        0xFFFFFFFF, // White
        0xFF7C543A, // Brown
        0xFF6C8A99, // Blue Grey
        0xFF5D50C6, // Indigo
        0xFF6F3CC3, // Deep Purple
      ],
      material: '100% Acrylic',
      care: 'Machine Washable',
      sku: 'UBL-SS-S5-C6-24S',
      neck: 'High Neck',
      pattern: 'Solid',
      description:
          'Elevate your style with the Urban Blend Long Sleeve Shirt — a blend of urban sophistication and comfort. Crafted with meticulous attention to detail for everyday wear.',
      vouchers: const [
        RawVoucher(
          label: 'Best Deal: 20% OFF',
          code: '2ODEALS',
          details: 'Min. spend \$150 • Valid till 12/31/2024',
        ),
        RawVoucher(
          label: '10% OFF',
          code: 'WELL10',
          details: 'Min. spend \$50 • New users',
        ),
      ],
      reviews: const [
        RawReview(
          author: 'Amelia Williams',
          ago: '2 weeks ago',
          stars: 5,
          variant: 'L, Black',
          text:
              "The item just arrived! Can’t wait to try it this week. Looks great! 🔥",
          photos: [],
        ),
        RawReview(
          author: 'Victoria Rodriguez',
          ago: '6 days ago',
          stars: 4,
          variant: 'XL, Black',
          text:
              'Versatile addition. Slightly snug but stylish and well-made ❤️',
          photos: [],
        ),
      ],
      suggestions: const [
        RawSuggestion(
          image:
              'https://images.unsplash.com/photo-1520975916090-3105956dac38?q=80&w=600&auto=format&fit=crop',
          title: 'Moda Chic Luxury Hoodie',
          price: 200.00,
          rating: 4.8,
        ),
        RawSuggestion(
          image:
              'https://images.unsplash.com/photo-1520975867597-0f23a4fb0a3a?q=80&w=600&auto=format&fit=crop',
          title: 'Trend Craft Fleece',
          price: 210.00,
          rating: 4.9,
        ),
        RawSuggestion(
          image:
              'https://images.unsplash.com/photo-1520975846138-bd1d4d1d8a9a?q=80&w=600&auto=format&fit=crop',
          title: 'Street Style Zip',
          price: 190.00,
          rating: 4.5,
        ),
      ],
    ),

    // ---------------- Product B ----------------
    'cln-hd-002': RawProduct(
      id: 'cln-hd-002',
      name: 'Cleanline Essential Hoodie',
      price: 129.00,
      imageUrls: const [
        'https://images.unsplash.com/photo-1520975731977-5f1406f9a6b1?q=80&w=1200&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1520975706600-79b4b3c1f9d8?q=80&w=1200&auto=format&fit=crop',
      ],
      rating: 4.6,
      sold: 1349,
      sizes: const ['S', 'M', 'L', 'XL'],
      colorHexes: const [
        0xFF111827,
        0xFFF3F4F6,
        0xFF2563EB,
      ], // near-black, off-white, blue
      material: '80% Cotton, 20% Polyester',
      care: 'Cold Machine Wash',
      sku: 'CLN-HD-ES-002',
      neck: 'Hooded',
      pattern: 'Solid',
      description:
          'Everyday hoodie with a soft brushed interior. Tailored fit without bulk.',
      vouchers: const [
        RawVoucher(
          label: '5% OFF',
          code: 'HELLO5',
          details: 'No min. spend • First order',
        ),
      ],
      reviews: const [
        RawReview(
          author: 'Jacob Ortiz',
          ago: '1 week ago',
          stars: 5,
          variant: 'M, Near-Black',
          text: 'Remarkably comfy. Fabric feels premium for the price.',
        ),
      ],
      suggestions: const [
        RawSuggestion(
          image:
              'https://images.unsplash.com/photo-1520975635021-3a2a08f9854f?q=80&w=600&auto=format&fit=crop',
          title: 'City Knit Beanie',
          price: 29.00,
          rating: 4.7,
        ),
      ],
    ),
  };

  /// Build the UI-ready model from the raw product.
  static ProductDetailData? productDetailById(String id) {
    final p = _products[id];
    if (p == null) return null;

    return ProductDetailData(
      title: p.name,
      price: p.price,
      images: p.imageUrls,
      rating: p.rating,
      soldCount: p.sold,
      sizes: p.sizes,
      colors: p.colorHexes.map((v) => Color(v)).toList(),
      specs: {
        'Material': p.material,
        'Care Label': p.care,
        'SKU': p.sku,
        'Neck': p.neck,
        'Pattern': p.pattern,
      },
      description: p.description,
      vouchers: p.vouchers
          .map(
            (v) =>
                VoucherData(label: v.label, code: v.code, details: v.details),
          )
          .toList(),
      reviews: p.reviews
          .map(
            (r) => ReviewData(
              author: r.author,
              ago: r.ago,
              stars: r.stars,
              variant: r.variant,
              text: r.text,
              photos: r.photos,
            ),
          )
          .toList(),
      suggestions: p.suggestions
          .map(
            (s) => SuggestionData(
              image: s.image,
              title: s.title,
              price: s.price,
              rating: s.rating,
            ),
          )
          .toList(),
    );
  }

  static const topPicks = [
    Product(
      title: 'Urban Blend Long Sleeve',
      price: 185,
      rating: 4.8,
      imageUrl: 'assets/images/demo/01.jpeg',
    ),
    Product(
      title: 'Luxe Blend Formal Tee',
      price: 160,
      rating: 4.6,
      imageUrl: 'assets/images/demo/02.jpeg',
    ),
    Product(
      title: 'Urban Flex Cotton Hoodie',
      price: 175,
      rating: 4.7,
      imageUrl: 'assets/images/demo/03.jpeg',
    ),
  ];

  static const categories = [
    CategoryItem('Women', 'assets/images/demo/promotion.png'),
    CategoryItem('Men', 'assets/images/demo/men.png'),
    CategoryItem('Shoe', 'assets/images/demo/shoe.png'),
    CategoryItem('Bag', 'assets/images/demo/bag.png'),
    CategoryItem('Luxury', 'assets/images/demo/luxury.png'),
    CategoryItem('Kids', 'assets/images/demo/kid.png'),
    CategoryItem('Sports', 'assets/images/demo/sport.png'),
    CategoryItem('Beauty', 'assets/images/demo/beauty.png'),
  ];

  static const newArrivals = [
    Product(
      title: 'Trend Craft Fleece Hoodie',
      price: 210,
      rating: 4.9,
      imageUrl: 'assets/images/demo/01.jpeg',
    ),
    Product(
      title: 'Moda Chic Luxurious Top',
      price: 200,
      rating: 4.8,
      imageUrl: 'assets/images/demo/02.jpeg',
    ),
    Product(
      title: 'Urban Elegant Blazer',
      price: 215,
      rating: 4.5,
      imageUrl: 'assets/images/demo/03.jpeg',
    ),
  ];

  static const hotDeals = [
    Product(
      title: 'Street Style Cozy Hoodie',
      price: 120,
      rating: 4.5,
      imageUrl: 'assets/images/demo/01.jpeg',
    ),
    Product(
      title: 'Street Style Comfort Tee',
      price: 95,
      rating: 4.7,
      imageUrl: 'assets/images/demo/02.jpeg',
    ),
    Product(
      title: 'Vogue Fit Cotton',
      price: 140,
      rating: 4.6,
      imageUrl: 'assets/images/demo/03.jpeg',
    ),
  ];
}
