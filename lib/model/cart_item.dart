import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String? productId;
  final String title;
  final String imageUrl;
  final String size;
  final String colorName;
  final Color color;
  final double price;
  int qty;
  bool selected;
  int stock;

  CartItem({
    required this.id,
    this.productId,
    required this.title,
    required this.imageUrl,
    required this.size,
    required this.colorName,
    required this.color,
    required this.price,
    this.qty = 1,
    this.selected = true,
    this.stock = 10,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? title,
    String? imageUrl,
    String? size,
    String? colorName,
    Color? color,
    double? price,
    int? qty,
    bool? selected,
    int? stock,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      colorName: colorName ?? this.colorName,
      color: color ?? this.color,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      selected: selected ?? this.selected,
      stock: stock ?? this.stock,
    );
  }
}
