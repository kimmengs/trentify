import 'package:flutter/material.dart';
import 'package:trentify/model/cart_item.dart';

class CartProvider extends ChangeNotifier {
  static final CartProvider instance = CartProvider._internal();
  factory CartProvider() => instance;
  CartProvider._internal() {
    _initDefaultItems();
  }

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold<int>(0, (sum, item) => sum + item.qty);

  int get selectedCount =>
      _items.where((e) => e.selected).fold<int>(0, (sum, e) => sum + e.qty);

  double get selectedTotal => _items
      .where((e) => e.selected)
      .fold<double>(0.0, (sum, e) => sum + (e.price * e.qty));

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.selected);

  bool get isEmpty => _items.isEmpty;

  void addToCart({
    required String title,
    required double price,
    required String imageUrl,
    required String size,
    required String colorName,
    required Color color,
    String? productId,
    int qty = 1,
    int stock = 10,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.title == title &&
          item.size == size &&
          item.colorName == colorName,
    );

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      final newQty = (existing.qty + qty).clamp(1, existing.stock);
      _items[existingIndex] = existing.copyWith(
        qty: newQty,
        selected: true,
      );
    } else {
      final newItem = CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}_${_items.length}',
        productId: productId,
        title: title,
        imageUrl: imageUrl,
        size: size,
        colorName: colorName,
        color: color,
        price: price,
        qty: qty,
        selected: true,
        stock: stock,
      );
      _items.insert(0, newItem);
    }

    notifyListeners();
  }

  void updateQty(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _items[index];
      final newQty = item.qty + delta;
      if (newQty > 0 && newQty <= item.stock) {
        _items[index] = item.copyWith(qty: newQty);
        notifyListeners();
      } else if (newQty <= 0) {
        removeItem(id);
      }
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleSelection(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(selected: !_items[index].selected);
      notifyListeners();
    }
  }

  void toggleSelectAll(bool selectAll) {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(selected: selectAll);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void updateVariant(String id, {String? newSize, String? newColorName, Color? newColor}) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        size: newSize,
        colorName: newColorName,
        color: newColor,
      );
      notifyListeners();
    }
  }

  void _initDefaultItems() {
    _items.addAll([
      CartItem(
        id: 'cart_demo_1',
        title: 'Urban Blend Long Sleeve Shirt',
        imageUrl:
            'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
        size: 'L',
        colorName: 'Black',
        color: const Color(0xFF111214),
        price: 185.0,
        qty: 1,
        selected: true,
        stock: 10,
      ),
      CartItem(
        id: 'cart_demo_2',
        title: 'Street Style Comfort Tee',
        imageUrl:
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=800&auto=format&fit=crop',
        size: 'M',
        colorName: 'White',
        color: const Color(0xFFFFFFFF),
        price: 155.0,
        qty: 2,
        selected: true,
        stock: 8,
      ),
    ]);
  }
}
