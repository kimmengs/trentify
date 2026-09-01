import 'package:flutter/material.dart';
import 'package:trentify/model/cart_item.dart';
import 'package:trentify/model/order_product.dart';
import 'package:trentify/model/order_status.dart';
import 'package:trentify/model/order_summary.dart';
import 'package:trentify/provider/cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  static final OrderProvider instance = OrderProvider._internal();
  factory OrderProvider() => instance;

  OrderProvider._internal() {
    _initDefaultOrders();
  }

  final List<OrderSummary> _orders = [];

  List<OrderSummary> get orders => List.unmodifiable(_orders);
  List<OrderSummary> get activeOrders =>
      _orders.where((o) => o.status == OrderStatus.active).toList();
  List<OrderSummary> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();
  List<OrderSummary> get canceledOrders =>
      _orders.where((o) => o.status == OrderStatus.canceled).toList();

  int get activeCount => activeOrders.length;
  int get completedCount => completedOrders.length;
  int get canceledCount => canceledOrders.length;

  void _initDefaultOrders() {
    _orders.addAll([
      OrderSummary(
        id: 'ORD-1001',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        products: const [
          OrderProduct(
            'Urban Blend Long Sleeve Silk Shirt',
            'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
          ),
          OrderProduct(
            'Tailored Slim Fit Denim Jeans',
            'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=800&auto=format&fit=crop',
          ),
          OrderProduct(
            'Italian Leather Luxury Belt',
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=800&auto=format&fit=crop',
          ),
        ],
        total: 441.50,
        status: OrderStatus.active,
      ),
      OrderSummary(
        id: 'ORD-1000',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        products: const [
          OrderProduct(
            'Urban Elegance Wool Business Blazer',
            'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=800&auto=format&fit=crop',
          ),
        ],
        total: 184.50,
        status: OrderStatus.active,
      ),
      OrderSummary(
        id: 'ORD-0999',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        products: const [
          OrderProduct(
            'Oversized Heavyweight Cotton Hoodie',
            'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?q=80&w=800&auto=format&fit=crop',
          ),
          OrderProduct(
            'Minimalist Premium Crewneck Tee',
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=800&auto=format&fit=crop',
          ),
        ],
        total: 120.00,
        status: OrderStatus.completed,
      ),
      OrderSummary(
        id: 'ORD-0998',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        products: const [
          OrderProduct(
            'Modal Silk Fine Knit Sweater',
            'https://images.unsplash.com/photo-1576566588028-4147f3842f27?q=80&w=800&auto=format&fit=crop',
          ),
        ],
        total: 90.00,
        status: OrderStatus.canceled,
      ),
    ]);
  }

  String createOrderFromCart({
    required List<CartItem> items,
    required double total,
    String? address,
    String? paymentMethod,
  }) {
    final orderId = 'ORD-${1002 + _orders.length}';
    final orderProducts = items
        .map((item) => OrderProduct(
              '${item.title} (${item.size}, ${item.colorName})',
              item.imageUrl,
            ))
        .toList();

    final newOrder = OrderSummary(
      id: orderId,
      createdAt: DateTime.now(),
      products: orderProducts,
      total: total,
      status: OrderStatus.active,
    );

    _orders.insert(0, newOrder);
    notifyListeners();
    return orderId;
  }

  void cancelOrder(String orderId, {String? reason}) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final current = _orders[index];
      _orders[index] = OrderSummary(
        id: current.id,
        createdAt: current.createdAt,
        products: current.products,
        total: current.total,
        status: OrderStatus.canceled,
      );
      notifyListeners();
    }
  }

  void reorder(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    for (final p in order.products) {
      CartProvider.instance.addToCart(
        title: p.title,
        price: order.total / (order.products.isEmpty ? 1 : order.products.length),
        imageUrl: p.imageUrl,
        size: 'M',
        colorName: 'Black',
        color: const Color(0xFF111214),
        qty: 1,
      );
    }
  }
}
