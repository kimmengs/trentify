enum SellerOrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

class SellerOrderItem {
  final String productId;
  final String title;
  final String imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;

  SellerOrderItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;
}

class SellerOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAvatar;
  final String shippingAddress;
  final List<SellerOrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  SellerOrderStatus status;
  final String paymentMethod;
  String? carrier;
  String? trackingNumber;
  final DateTime createdAt;
  DateTime? shippedAt;
  final String? customerNote;

  SellerOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAvatar,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    this.shippingFee = 0.0,
    this.tax = 0.0,
    required this.total,
    this.status = SellerOrderStatus.pending,
    this.paymentMethod = 'Credit Card',
    this.carrier,
    this.trackingNumber,
    required this.createdAt,
    this.shippedAt,
    this.customerNote,
  });

  SellerOrder copyWith({
    SellerOrderStatus? status,
    String? carrier,
    String? trackingNumber,
    DateTime? shippedAt,
  }) {
    return SellerOrder(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      customerAvatar: customerAvatar,
      shippingAddress: shippingAddress,
      items: items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      tax: tax,
      total: total,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      carrier: carrier ?? this.carrier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt,
      shippedAt: shippedAt ?? this.shippedAt,
      customerNote: customerNote,
    );
  }
}
