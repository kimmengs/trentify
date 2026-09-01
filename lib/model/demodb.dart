import 'package:trentify/model/address.dart';
import 'package:trentify/model/payment_method.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/model/promo.dart';
import 'package:trentify/screens/home/product_detail.dart';
import 'package:flutter/material.dart';

class CategoryItem {
  final String title;
  final String imagePath;
  final IconData? icon;
  const CategoryItem(this.title, this.imagePath, {this.icon});
}

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
  // Comprehensive Product Catalog (30+ Luxury Pieces)
  static final List<Product> allProducts = [
    // --- CLASSIC ESSENTIALS & MEN ---
    const Product(
      id: 'ubl-ss-001',
      title: 'Urban Blend Long Sleeve',
      price: 185.00,
      originalPrice: 220.00,
      discountPercent: 16,
      rating: 4.8,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
      description: 'Elevate your wardrobe with the Urban Blend Shirt — a harmony of urban sophistication, silk drape, and breathable comfort.',
    ),
    const Product(
      id: 'lxb-ft-002',
      title: 'Luxe Blend Formal Tee',
      price: 160.00,
      rating: 4.6,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=800&auto=format&fit=crop',
      description: 'Mercerized Supima cotton formal t-shirt with a lustrous silk finish and tailored crewneck.',
    ),
    const Product(
      id: 'ufc-ch-003',
      title: 'Urban Flex Cotton Hoodie',
      price: 175.00,
      rating: 4.7,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?q=80&w=800&auto=format&fit=crop',
      description: 'Everyday heavyweight hoodie with soft brushed interior, drop shoulders, and durable ribbed hems.',
    ),
    const Product(
      id: 'wmn-silk-gown-01',
      title: 'Monogram Silk Evening Gala Gown',
      price: 480.00,
      originalPrice: 600.00,
      discountPercent: 20,
      rating: 4.9,
      category: 'Women',
      imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=800&auto=format&fit=crop',
      description: 'Hand-draped mulberry silk evening dress featuring delicate embroidery and an elegant silhouette suitable for galas and red-carpet events.',
    ),
    const Product(
      id: 'wmn-wool-trench-03',
      title: 'Double-Breasted Camel Wool Trench',
      price: 420.00,
      originalPrice: 490.00,
      discountPercent: 15,
      rating: 4.9,
      category: 'Women',
      imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=800&auto=format&fit=crop',
      description: 'Classic double-breasted trench coat tailored in virgin camel wool with horn buttons and storm flap.',
    ),
    const Product(
      id: 'wmn-cashmere-knit-02',
      title: 'Italian Cashmere Turtleneck Knit',
      price: 240.00,
      rating: 4.8,
      category: 'Women',
      imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?q=80&w=800&auto=format&fit=crop',
      description: 'Ultra-soft 100% Mongolian cashmere knit with ribbed cuffs and relaxed luxury drape.',
    ),
    const Product(
      id: 'wmn-satin-slip-04',
      title: 'Champagne Satin Slip Maxi Dress',
      price: 195.00,
      rating: 4.7,
      category: 'Women',
      imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?q=80&w=800&auto=format&fit=crop',
      description: 'Effortlessly chic bias-cut liquid satin dress with cowl neckline and adjustable straps.',
    ),
    const Product(
      id: 'wmn-peplum-blazer-05',
      title: 'Structured Velvet Peplum Blazer',
      price: 295.00,
      rating: 4.8,
      category: 'Women',
      imageUrl: 'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?q=80&w=800&auto=format&fit=crop',
      description: 'Tailored black velvet blazer with nipped waist, padded shoulders, and satin lapel accents.',
    ),
    const Product(
      id: 'wmn-pleated-skirt-06',
      title: 'Floral Chiffon Pleated Midi Skirt',
      price: 165.00,
      rating: 4.6,
      category: 'Women',
      imageUrl: 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?q=80&w=800&auto=format&fit=crop',
      description: 'Romantic pleated chiffon skirt with subtle metallic thread and comfortable elasticized waistband.',
    ),
    const Product(
      id: 'cln-hd-002',
      title: 'Cleanline Essential Heavyweight Hoodie',
      price: 129.00,
      rating: 4.6,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?q=80&w=800&auto=format&fit=crop',
      description: 'Everyday heavyweight hoodie with soft brushed interior, drop shoulders, and durable ribbed hems.',
    ),
    const Product(
      id: 'men-navy-blazer-03',
      title: 'Urban Elegance Wool Business Blazer',
      price: 380.00,
      rating: 4.9,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=800&auto=format&fit=crop',
      description: 'Impeccably tailored Super 120s Italian wool blazer in midnight navy with mother-of-pearl buttons.',
    ),
    const Product(
      id: 'men-merino-crew-04',
      title: 'Merino Wool Minimalist Crewneck',
      price: 210.00,
      rating: 4.8,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=800&auto=format&fit=crop',
      description: 'Fine 16-gauge Australian merino wool crewneck sweater with seamless knit construction.',
    ),
    const Product(
      id: 'men-selvedge-jeans-05',
      title: 'Tailored Selvedge Slim Denim Jeans',
      price: 165.00,
      rating: 4.7,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=800&auto=format&fit=crop',
      description: 'Japanese raw selvedge denim in a contemporary slim tapered fit that ages with unique patina.',
    ),
    const Product(
      id: 'men-oxford-shirt-06',
      title: 'Classic Egyptian Oxford Button-Down',
      price: 135.00,
      rating: 4.7,
      category: 'Men',
      imageUrl: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?q=80&w=800&auto=format&fit=crop',
      description: 'Long-staple Egyptian cotton shirt with button-down collar and tailored chest pocket.',
    ),

    // --- SHOES ---
    const Product(
      id: 'shoe-leather-loafer-01',
      title: 'Royal Calfskin Burnished Loafers',
      price: 320.00,
      originalPrice: 380.00,
      discountPercent: 15,
      rating: 4.9,
      category: 'Shoe',
      imageUrl: 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?q=80&w=800&auto=format&fit=crop',
      description: 'Hand-burnished Italian calfskin penny loafers with Blake-stitched leather sole and memory cushion insole.',
    ),
    const Product(
      id: 'shoe-chelsea-boot-02',
      title: 'Obsidian Suede Chelsea Boots',
      price: 285.00,
      rating: 4.8,
      category: 'Shoe',
      imageUrl: 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?q=80&w=800&auto=format&fit=crop',
      description: 'Velvety suede Chelsea boots with elastic side gussets and weather-resistant Goodyear welt.',
    ),
    const Product(
      id: 'shoe-runway-sneaker-03',
      title: 'Air Cushion Urban Runway Sneakers',
      price: 215.00,
      rating: 4.7,
      category: 'Shoe',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800&auto=format&fit=crop',
      description: 'Futuristic architectural silhouette with responsive nitrogen-infused foam midsole and breathable mesh.',
    ),
    const Product(
      id: 'shoe-gold-pump-04',
      title: 'Metallic Stiletto Evening Pumps',
      price: 310.00,
      rating: 4.9,
      category: 'Shoe',
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=800&auto=format&fit=crop',
      description: 'Sculptural 90mm gold metallic stiletto heel with pointed toe and cushioned red leather sole.',
    ),
    const Product(
      id: 'shoe-court-sneaker-05',
      title: 'Monochrome Leather Court Sneakers',
      price: 175.00,
      rating: 4.8,
      category: 'Shoe',
      imageUrl: 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?q=80&w=800&auto=format&fit=crop',
      description: 'Minimalist white full-grain leather sneakers with gold-stamped heel tab and vulcanized rubber sole.',
    ),

    // --- BAGS ---
    const Product(
      id: 'bag-quilted-crossbody-01',
      title: 'Monogram Quilted Caviar Crossbody',
      price: 520.00,
      originalPrice: 650.00,
      discountPercent: 20,
      rating: 5.0,
      category: 'Bag',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800&auto=format&fit=crop',
      description: 'Diamond quilted caviar leather bag with woven gold chain strap and signature interlocking clasp.',
    ),
    const Product(
      id: 'bag-tote-calfskin-02',
      title: 'Architectural Structured Tan Tote',
      price: 450.00,
      rating: 4.9,
      category: 'Bag',
      imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=800&auto=format&fit=crop',
      description: 'Spacious daily tote crafted from rich cognac calfskin with magnetic closure and padded 14-inch laptop sleeve.',
    ),
    const Product(
      id: 'bag-leather-duffle-03',
      title: 'Luxury Heritage Weekend Duffle Bag',
      price: 380.00,
      rating: 4.9,
      category: 'Bag',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=800&auto=format&fit=crop',
      description: 'Full-grain leather weekender with heavy-duty brass hardware and detachable padded shoulder strap.',
    ),
    const Product(
      id: 'bag-micro-vanity-04',
      title: 'Micro Chain Vanity Shoulder Bag',
      price: 260.00,
      rating: 4.7,
      category: 'Bag',
      imageUrl: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?q=80&w=800&auto=format&fit=crop',
      description: 'Cylindrical leather vanity case bag with gold zip-around closure and interior compact mirror.',
    ),
    const Product(
      id: 'bag-exec-briefcase-05',
      title: 'Matte Black Executive Briefcase',
      price: 410.00,
      rating: 4.8,
      category: 'Bag',
      imageUrl: 'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?q=80&w=800&auto=format&fit=crop',
      description: 'Slimline executive document carrier with dual compartments, key lock, and water-resistant finish.',
    ),

    // --- LUXURY & HAUTE COUTURE ---
    const Product(
      id: 'lux-gold-watch-01',
      title: 'Handcrafted 18K Gold Chronograph',
      price: 1250.00,
      rating: 5.0,
      category: 'Luxury',
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=800&auto=format&fit=crop',
      description: 'Swiss automatic movement chronograph with 18-karat gold bezel, sapphire crystal glass, and alligator leather strap.',
    ),
    const Product(
      id: 'lux-cashmere-overcoat-02',
      title: 'Bespoke Cashmere Double Overcoat',
      price: 890.00,
      originalPrice: 1100.00,
      discountPercent: 19,
      rating: 4.9,
      category: 'Luxury',
      imageUrl: 'https://images.unsplash.com/photo-1548883354-7622d03aca27?q=80&w=800&auto=format&fit=crop',
      description: 'Unlined pure Loro Piana cashmere overcoat with hand-stitched edges and horn buttons.',
    ),
    const Product(
      id: 'lux-diamond-bracelet-03',
      title: 'Platinum Diamond Tennis Bracelet',
      price: 950.00,
      rating: 5.0,
      category: 'Luxury',
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=800&auto=format&fit=crop',
      description: 'Round brilliant-cut lab diamonds totaling 3.5 carats set in solid 950 platinum with double safety clasp.',
    ),
    const Product(
      id: 'lux-crystal-gala-04',
      title: 'Crystal Embellished Silk Gala Dress',
      price: 1100.00,
      rating: 5.0,
      category: 'Luxury',
      imageUrl: 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?q=80&w=800&auto=format&fit=crop',
      description: 'Hand-sewn Swarovski crystal embellishments along an open back black velvet and silk evening gown.',
    ),

    // --- KIDS, SPORTS & BEAUTY ---
    const Product(
      id: 'kid-bear-sweater-01',
      title: 'Kids Organic Cotton Bear Jumper',
      price: 75.00,
      rating: 4.8,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?q=80&w=800&auto=format&fit=crop',
      description: '100% GOTS certified organic cotton sweater featuring whimsical knit bear motif.',
    ),
    const Product(
      id: 'kid-denim-jacket-02',
      title: 'Kids Vintage Washed Denim Jacket',
      price: 85.00,
      rating: 4.7,
      category: 'Kids',
      imageUrl: 'https://images.unsplash.com/photo-1519457431-44ccd64a579b?q=80&w=800&auto=format&fit=crop',
      description: 'Soft stretch denim jacket with cozy sherpa lining and brass button accents.',
    ),
    const Product(
      id: 'sport-compression-01',
      title: 'Seamless Performance Activewear Set',
      price: 135.00,
      rating: 4.7,
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=800&auto=format&fit=crop',
      description: 'High-waisted compression leggings and matching cross-back sports bra with moisture-wicking technology.',
    ),
    const Product(
      id: 'beauty-extract-perfume-01',
      title: 'Botanical Extract Eau de Parfum (100ml)',
      price: 165.00,
      rating: 4.9,
      category: 'Beauty',
      imageUrl: 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?q=80&w=800&auto=format&fit=crop',
      description: 'Artisanal fragrance with top notes of bergamot and pink pepper, floral heart of damask rose, and cedar base.',
    ),
  ];

  /// Filter products by category name
  static List<Product> getProductsByCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'all') {
      return allProducts;
    }
    final c = category.toLowerCase().trim();
    return allProducts.where((p) {
      final pCat = p.category.toLowerCase();
      if (c == 'women' || c == 'tab_women') return pCat == 'women';
      if (c == 'men' || c == 'tab_men') return pCat == 'men';
      if (c == 'shoe' || c == 'shoes' || c == 'tab_shoes') return pCat == 'shoe';
      if (c == 'bag' || c == 'bags' || c == 'tab_bags') return pCat == 'bag';
      if (c == 'luxury' || c == 'tab_luxury') return pCat == 'luxury';
      if (c == 'kids' || c == 'kid') return pCat == 'kids';
      if (c == 'sports' || c == 'sport') return pCat == 'sports';
      if (c == 'beauty') return pCat == 'beauty';
      return pCat.contains(c) || p.title.toLowerCase().contains(c);
    }).toList();
  }

  /// Top picks collection
  static List<Product> get topPicks => allProducts.take(8).toList();

  /// New arrivals collection
  static List<Product> get newArrivals => allProducts.skip(6).take(8).toList();

  /// Hot deals collection
  static List<Product> get hotDeals => allProducts
      .where((p) => p.discountPercent != null || p.price < 200)
      .take(8)
      .toList();

  static const categories = [
    CategoryItem('Women', 'assets/images/demo/promotion.png', icon: Icons.woman_rounded),
    CategoryItem('Men', 'assets/images/demo/men.png', icon: Icons.man_rounded),
    CategoryItem('Shoe', 'assets/images/demo/shoe.png', icon: Icons.snowshoeing_rounded),
    CategoryItem('Bag', 'assets/images/demo/bag.png', icon: Icons.shopping_bag_rounded),
    CategoryItem('Luxury', 'assets/images/demo/luxury.png', icon: Icons.diamond_rounded),
    CategoryItem('Kids', 'assets/images/demo/kid.png', icon: Icons.child_care_rounded),
    CategoryItem('Sports', 'assets/images/demo/sport.png', icon: Icons.sports_gymnastics_rounded),
    CategoryItem('Beauty', 'assets/images/demo/beauty.png', icon: Icons.spa_rounded),
  ];

  /// Dynamic product detail lookup with automatic fallback generator
  static ProductDetailData productDetailById(String id) {
    // 1. Try to find product in allProducts
    final matchedProduct = allProducts.firstWhere(
      (p) => p.id == id || p.effectiveId == id,
      orElse: () => allProducts.first,
    );

    return ProductDetailData(
      title: matchedProduct.title,
      price: matchedProduct.price,
      images: [
        matchedProduct.imageUrl,
        'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1576566588028-4147f3842f27?q=80&w=800&auto=format&fit=crop',
      ],
      rating: matchedProduct.rating,
      soldCount: matchedProduct.soldCount,
      sizes: const ['XS', 'S', 'M', 'L', 'XL'],
      colors: const [
        Color(0xFF111214), // Obsidian
        Color(0xFFFFFFFF), // White
        Color(0xFF7C543A), // Tan
        Color(0xFF1E293B), // Navy
        Color(0xFF5D50C6), // Indigo
      ],
      specs: {
        'Category': matchedProduct.category,
        'Brand': matchedProduct.brand,
        'Material': '100% Ultra-Fine Mulberry Silk / Virgin Wool',
        'Care Label': 'Dry Clean or Cold Gentle Cycle',
        'SKU': 'TRN-${matchedProduct.id.toUpperCase()}',
        'Origin': 'Made in Milan, Italy',
      },
      description: matchedProduct.description.isNotEmpty
          ? matchedProduct.description
          : 'Crafted with peerless craftsmanship for discerning fashion enthusiasts. Features hand-finished stitching, premium tactile materials, and signature Haute Couture accents.',
      vouchers: const [
        VoucherData(
          label: 'VIP Member Deal: 20% OFF',
          code: '20VIPDEAL',
          details: 'Min. spend \$150 • Valid for VIP Club Members',
        ),
        VoucherData(
          label: 'Free Worldwide Express Shipping',
          code: 'SHIPFREE',
          details: 'No min. spend • DHL Express 24-48h',
        ),
      ],
      reviews: [
        ReviewData(
          author: 'Amelia Williams (Verified Buyer)',
          ago: '2 days ago',
          stars: 5.0,
          variant: 'M, Obsidian',
          text: 'The drape and texture in person are beyond extraordinary! Exceeded all expectations. ⭐',
          photos: const [],
        ),
        ReviewData(
          author: 'Julian Thorne (Haute Collector)',
          ago: '1 week ago',
          stars: 5.0,
          variant: 'L, Tan',
          text: 'Flawless tailoring and luxury packaging. Fast delivery via DHL courier.',
          photos: const [],
        ),
      ],
      suggestions: allProducts
          .where((p) => p.id != matchedProduct.id)
          .take(4)
          .map((p) => SuggestionData(
                image: p.imageUrl,
                title: p.title,
                price: p.price,
                rating: p.rating,
              ))
          .toList(),
    );
  }

  static const addresses = <Address>[
    Address(
      id: 'home',
      label: 'Home',
      fullName: 'Alex Rivera',
      phone: '+1 (555) 389-2041',
      line1: '742 Evergreen Terrace, New York, NY 10021, USA',
      isMain: true,
    ),
    Address(
      id: 'office',
      label: 'Penthouse Office',
      fullName: 'Alex Rivera',
      phone: '+1 (555) 389-2041',
      line1: '888 5th Avenue, Suite 42B, Manhattan, NY 10022, USA',
    ),
  ];

  static const demoMethods = <PaymentMethod>[
    PaymentMethod(id: 'apple', kind: PaymentKind.wallet, name: 'Apple Pay'),
    PaymentMethod(
      id: 'mc4679',
      kind: PaymentKind.card,
      name: 'Mastercard Black Card',
      brand: 'Mastercard',
      last4: '4679',
    ),
    PaymentMethod(
      id: 'visa5567',
      kind: PaymentKind.card,
      name: 'Visa Infinite',
      brand: 'Visa',
      last4: '5567',
    ),
  ];

  static final demoPromos = <Promo>[
    Promo(
      id: 'p1',
      title: '20% OFF Haute Couture Collection',
      code: 'VIP20',
      type: PromoType.percent,
      value: 20,
      minSpend: 200,
      validUntil: DateTime(2026, 12, 31),
    ),
    Promo(
      id: 'p2',
      title: '\$50 VIP Birthday Voucher',
      code: 'BDAY50',
      type: PromoType.percent,
      value: 50,
      minSpend: 250,
      validUntil: DateTime(2026, 12, 31),
    ),
  ];
}
