import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trentify/provider/cart_provider.dart';

void main() {
  group('CartProvider and Add to Bag Real Flow Tests', () {
    late CartProvider cart;

    setUp(() {
      cart = CartProvider();
      cart.clearCart();
    });

    test('Adding product dynamically populates shopping bag items and recalculates totals', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.totalCount, 0);

      cart.addToCart(
        title: 'Silk Minimalist Blazer',
        price: 289.0,
        imageUrl: 'https://example.com/blazer.jpg',
        size: 'M',
        colorName: 'Black',
        color: const Color(0xFF111214),
        qty: 1,
      );

      expect(cart.isEmpty, isFalse);
      expect(cart.items.length, 1);
      expect(cart.totalCount, 1);
      expect(cart.selectedTotal, 289.0);

      // Adding the same item increments quantity rather than creating duplicates
      cart.addToCart(
        title: 'Silk Minimalist Blazer',
        price: 289.0,
        imageUrl: 'https://example.com/blazer.jpg',
        size: 'M',
        colorName: 'Black',
        color: const Color(0xFF111214),
        qty: 2,
      );

      expect(cart.items.length, 1);
      expect(cart.totalCount, 3);
      expect(cart.items.first.qty, 3);
      expect(cart.selectedTotal, 289.0 * 3);
    });

    test('Adding distinct variants creates separate cart items', () {
      cart.addToCart(
        title: 'Urban Blend Shirt',
        price: 185.0,
        imageUrl: 'https://example.com/shirt.jpg',
        size: 'S',
        colorName: 'White',
        color: const Color(0xFFFFFFFF),
      );

      cart.addToCart(
        title: 'Urban Blend Shirt',
        price: 185.0,
        imageUrl: 'https://example.com/shirt.jpg',
        size: 'L',
        colorName: 'Black',
        color: const Color(0xFF000000),
      );

      expect(cart.items.length, 2);
      expect(cart.totalCount, 2);
      expect(cart.selectedTotal, 370.0);
    });

    test('Updating quantity, selection, and removing items works accurately', () {
      cart.addToCart(
        title: 'Cashmere Knit Sweater',
        price: 195.0,
        imageUrl: 'https://example.com/sweater.jpg',
        size: 'M',
        colorName: 'Sage',
        color: const Color(0xFF8FBC8F),
        qty: 2,
      );

      final itemId = cart.items.first.id;

      // Update quantity
      cart.updateQty(itemId, 1);
      expect(cart.items.first.qty, 3);

      // Toggle selection
      cart.toggleSelection(itemId);
      expect(cart.selectedCount, 0);
      expect(cart.selectedTotal, 0.0);

      // Select again
      cart.toggleSelection(itemId);
      expect(cart.selectedCount, 3);
      expect(cart.selectedTotal, 195.0 * 3);

      // Remove item
      cart.removeItem(itemId);
      expect(cart.isEmpty, isTrue);
      expect(cart.totalCount, 0);
    });
  });
}
