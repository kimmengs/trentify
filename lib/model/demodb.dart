import 'dart:ui';

import 'package:trentify/model/address.dart';
import 'package:trentify/model/payment_method.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/model/promo.dart';
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
        'https://bbtrading.ch/data/image.php?image=851_03920/851_03920_imageMain.jpg&width=280&height=280',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoKjAkCpWRjiMMLXm-UTfDhMYbyQf9sIFK3w&s',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSr8F6TH3NaUoqmZg_gGSxz3m2bbxJ2wpwflw&s',
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
              'https://bbtrading.ch/data/image.php?image=851_03920/851_03920_imageMain.jpg&width=280&height=280',

          title: 'Moda Chic Luxury Hoodie',
          price: 200.00,
          rating: 4.8,
        ),
        RawSuggestion(
          image:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoKjAkCpWRjiMMLXm-UTfDhMYbyQf9sIFK3w&s',
          title: 'Trend Craft Fleece',
          price: 210.00,
          rating: 4.9,
        ),
        RawSuggestion(
          image:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSr8F6TH3NaUoqmZg_gGSxz3m2bbxJ2wpwflw&s',
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
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoKjAkCpWRjiMMLXm-UTfDhMYbyQf9sIFK3w&s',
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
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoKjAkCpWRjiMMLXm-UTfDhMYbyQf9sIFK3w&s',
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

  static const addresses = <Address>[
    Address(
      id: 'home',
      label: 'Home',
      fullName: 'Andrew Ainsley',
      phone: '+1 111 467 378 399',
      line1: '701 7th Ave, New York, NY 10036, USA',
      isMain: true,
    ),
    Address(
      id: 'apartment',
      label: 'Apartment',
      fullName: 'Andrew Ainsley',
      phone: '+1 111 467 378 399',
      line1: 'Liberty Island, New York, NY 10004, USA',
    ),
    Address(
      id: 'mom',
      label: "Mom's House",
      fullName: 'Jenny Ainsley',
      phone: '+1 111 684 049 365',
      line1: 'Central Park, New York, NY 10022, USA',
    ),
  ];

  static const demoMethods = <PaymentMethod>[
    const PaymentMethod(id: 'paypal', kind: PaymentKind.wallet, name: 'PayPal'),
    const PaymentMethod(
      id: 'gpay',
      kind: PaymentKind.wallet,
      name: 'Google Pay',
    ),
    const PaymentMethod(
      id: 'apple',
      kind: PaymentKind.wallet,
      name: 'Apple Pay',
    ),
    const PaymentMethod(
      id: 'mc4679',
      kind: PaymentKind.card,
      name: 'Mastercard',
      brand: 'Mastercard',
      last4: '4679',
    ),
    const PaymentMethod(
      id: 'visa5567',
      kind: PaymentKind.card,
      name: 'Visa',
      brand: 'Visa',
      last4: '5567',
    ),
    const PaymentMethod(
      id: 'amex8456',
      kind: PaymentKind.card,
      name: 'American Express',
      brand: 'AmEx',
      last4: '8456',
    ),
  ];

  static final demoPromos = <Promo>[
    Promo(
      id: 'p1',
      title: '10% OFF & 10% Cashback',
      code: 'CODE',
      type: PromoType.percent,
      value: 10,
      minSpend: 250,
      validUntil: DateTime(2024, 12, 28),
    ),
    Promo(
      id: 'p2',
      title: 'Best Deal: 20% OFF',
      code: '20DEALS',
      type: PromoType.percent,
      value: 20,
      minSpend: 150,
      validUntil: DateTime(2024, 12, 31),
    ),
    Promo(
      id: 'p3',
      title: '15% OFF: New User Promotion',
      code: 'CODE',
      type: PromoType.percent,
      value: 15,
      minSpend: 120,
      validUntil: DateTime(2024, 12, 25),
    ),
    Promo(
      id: 'p4',
      title: '8% OFF & 8% Cashback',
      code: 'CODE',
      type: PromoType.percent,
      value: 8,
      minSpend: 400,
      validUntil: DateTime(2024, 12, 30),
    ),
    Promo(
      id: 'p5',
      title: '12% Cashback',
      code: 'CODE',
      type: PromoType.cashback,
      value: 12,
      minSpend: 1000,
      validUntil: DateTime(2024, 12, 31),
    ),
  ];
}
