import 'package:flutter_test/flutter_test.dart';
import 'package:trentify/model/seller_order.dart';
import 'package:trentify/model/seller_product.dart';
import 'package:trentify/provider/seller_provider.dart';

void main() {
  group('Shop Owner / Seller Center Unit Tests', () {
    late SellerProvider provider;

    setUp(() {
      provider = SellerProvider.instance;
    });

    test('SellerProvider initializes with default store profile and catalog', () {
      expect(provider.profile.name, isNotEmpty);
      expect(provider.products, isNotEmpty);
      expect(provider.orders, isNotEmpty);
      expect(provider.totalRevenue, greaterThan(0));
    });

    test('SellerProduct stock calculation flags low stock and out of stock correctly', () {
      final inStock = SellerProduct(
        id: 'test_1',
        title: 'Test In Stock',
        description: 'Desc',
        brand: 'Brand',
        category: 'Women',
        price: 100,
        images: ['https://example.com/1.jpg'],
        sizes: ['M'],
        colors: ['Black'],
        stock: 12,
        createdAt: DateTime.now(),
      );
      expect(inStock.isLowStock, isFalse);
      expect(inStock.isOutOfStock, isFalse);

      final lowStock = inStock.copyWith(stock: 4);
      expect(lowStock.isLowStock, isTrue);
      expect(lowStock.isOutOfStock, isFalse);

      final outOfStock = inStock.copyWith(stock: 0);
      expect(outOfStock.isLowStock, isFalse);
      expect(outOfStock.isOutOfStock, isTrue);
    });

    test('Adding and toggling product updates state', () {
      final initialCount = provider.products.length;
      final newProd = SellerProduct(
        id: 'sp_new_test',
        title: 'Couture Jacket',
        description: 'Handcrafted',
        brand: 'Maison Trentify',
        category: 'Luxury',
        price: 450,
        images: ['https://example.com/jacket.jpg'],
        sizes: ['S', 'M'],
        colors: ['Navy'],
        stock: 8,
        status: SellerProductStatus.active,
        createdAt: DateTime.now(),
      );

      provider.addProduct(newProd);
      expect(provider.products.length, initialCount + 1);

      provider.toggleProductStatus('sp_new_test');
      final updated = provider.products.firstWhere((p) => p.id == 'sp_new_test');
      expect(updated.status, SellerProductStatus.draft);

      provider.updateStock('sp_new_test', 5);
      final restocked = provider.products.firstWhere((p) => p.id == 'sp_new_test');
      expect(restocked.stock, 13);
    });

    test('Fulfill order changes status and sets tracking details', () {
      final pendingOrder = provider.orders.firstWhere((o) => o.status == SellerOrderStatus.pending);
      final orderId = pendingOrder.id;

      provider.updateOrderStatus(
        orderId,
        SellerOrderStatus.shipped,
        carrier: 'DHL Express',
        trackingNumber: 'DHL-99887766',
      );

      final shippedOrder = provider.orders.firstWhere((o) => o.id == orderId);
      expect(shippedOrder.status, SellerOrderStatus.shipped);
      expect(shippedOrder.carrier, 'DHL Express');
      expect(shippedOrder.trackingNumber, 'DHL-99887766');
      expect(shippedOrder.shippedAt, isNotNull);
    });
  });
}
