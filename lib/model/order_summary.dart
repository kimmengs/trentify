import 'package:trentify/model/order_product.dart';
import 'package:trentify/model/order_status.dart';

class OrderSummary {
  final String id;
  final DateTime createdAt;
  final List<OrderProduct> products;
  final double total;
  final OrderStatus status;

  const OrderSummary({
    required this.id,
    required this.createdAt,
    required this.products,
    required this.total,
    required this.status,
  });
}
