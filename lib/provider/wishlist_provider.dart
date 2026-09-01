import 'package:flutter/material.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/provider/cart_provider.dart';

class WishlistProvider extends ChangeNotifier {
  static final WishlistProvider instance = WishlistProvider._internal();
  factory WishlistProvider() => instance;

  WishlistProvider._internal() {
    _initDefaultItems();
  }

  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  void _initDefaultItems() {
    _items.addAll(DemoDb.allProducts.take(5));
  }

  void resetToDefaults() {
    _items.clear();
    _initDefaultItems();
    notifyListeners();
  }

  bool isFavorite(String title) {
    return _items.any((p) => p.title.toLowerCase() == title.toLowerCase());
  }

  bool isProductFavorite(Product product) {
    return isFavorite(product.title);
  }

  void toggleFavorite(Product product) {
    final index = _items.indexWhere(
      (p) => p.title.toLowerCase() == product.title.toLowerCase(),
    );
    if (index != -1) {
      _items.removeAt(index);
    } else {
      _items.insert(0, product);
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.removeWhere((p) => p.title == product.title);
    notifyListeners();
  }

  void addProduct(Product product) {
    if (!isProductFavorite(product)) {
      _items.insert(0, product);
      notifyListeners();
    }
  }

  void moveToBag(BuildContext context, Product product) {
    CartProvider.instance.addToCart(
      title: product.title,
      price: product.price,
      imageUrl: product.imageUrl,
      size: 'M',
      colorName: 'Black',
      color: const Color(0xFF111214),
      qty: 1,
    );
  }

  void moveAllToBag(BuildContext context) {
    for (final product in _items) {
      CartProvider.instance.addToCart(
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        size: 'M',
        colorName: 'Black',
        color: const Color(0xFF111214),
        qty: 1,
      );
    }
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
