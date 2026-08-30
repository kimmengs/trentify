import 'package:flutter/material.dart';

enum SellerProductStatus {
  active,
  draft,
  archived,
}

class SellerProductVariant {
  final String size;
  final String colorName;
  final Color color;
  int stock;
  final String? sku;

  SellerProductVariant({
    required this.size,
    required this.colorName,
    required this.color,
    required this.stock,
    this.sku,
  });

  SellerProductVariant copyWith({
    String? size,
    String? colorName,
    Color? color,
    int? stock,
    String? sku,
  }) {
    return SellerProductVariant(
      size: size ?? this.size,
      colorName: colorName ?? this.colorName,
      color: color ?? this.color,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
    );
  }
}

class SellerProduct {
  final String id;
  String title;
  String description;
  String brand;
  String category;
  double price;
  double? originalPrice;
  double costPrice;
  List<String> images;
  List<String> sizes;
  List<String> colors;
  List<SellerProductVariant> variants;
  int stock;
  SellerProductStatus status;
  int salesCount;
  int viewsCount;
  DateTime createdAt;

  SellerProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.brand,
    required this.category,
    required this.price,
    this.originalPrice,
    this.costPrice = 0.0,
    required this.images,
    required this.sizes,
    required this.colors,
    this.variants = const [],
    required this.stock,
    this.status = SellerProductStatus.active,
    this.salesCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
  });

  bool get isLowStock => stock > 0 && stock <= 5;
  bool get isOutOfStock => stock <= 0;

  SellerProduct copyWith({
    String? title,
    String? description,
    String? brand,
    String? category,
    double? price,
    double? originalPrice,
    double? costPrice,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    List<SellerProductVariant>? variants,
    int? stock,
    SellerProductStatus? status,
    int? salesCount,
    int? viewsCount,
    DateTime? createdAt,
  }) {
    return SellerProduct(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      costPrice: costPrice ?? this.costPrice,
      images: images ?? List.from(this.images),
      sizes: sizes ?? List.from(this.sizes),
      colors: colors ?? List.from(this.colors),
      variants: variants ?? List.from(this.variants),
      stock: stock ?? this.stock,
      status: status ?? this.status,
      salesCount: salesCount ?? this.salesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
