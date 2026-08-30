import 'package:flutter/material.dart';
import 'package:trentify/model/seller_order.dart';
import 'package:trentify/model/seller_product.dart';
import 'package:trentify/model/seller_settlement.dart';
import 'package:trentify/model/shop_profile.dart';

class SellerProvider extends ChangeNotifier {
  static final SellerProvider instance = SellerProvider._internal();
  factory SellerProvider() => instance;
  SellerProvider._internal() {
    _initDemoData();
  }

  late ShopProfile _profile;
  final List<SellerProduct> _products = [];
  final List<SellerOrder> _orders = [];
  final List<SellerSettlement> _settlements = [];
  final List<SellerPayoutRecord> _payouts = [];

  ShopProfile get profile => _profile;
  List<SellerProduct> get products => List.unmodifiable(_products);
  List<SellerOrder> get orders => List.unmodifiable(_orders);
  List<SellerSettlement> get settlements => List.unmodifiable(_settlements);
  List<SellerPayoutRecord> get payouts => List.unmodifiable(_payouts);

  // Statistics Getters
  double get totalRevenue => _orders
      .where((o) => o.status != SellerOrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.total);

  double get todayRevenue => 1240.50;

  int get pendingOrdersCount =>
      _orders.where((o) => o.status == SellerOrderStatus.pending).length;

  int get processingOrdersCount =>
      _orders.where((o) => o.status == SellerOrderStatus.processing).length;

  int get lowStockCount => _products.where((p) => p.isLowStock).length;

  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;

  int get totalProductsCount => _products.length;

  int get activeProductsCount =>
      _products.where((p) => p.status == SellerProductStatus.active).length;

  // --- Financial & Settlement Getters ---

  double get availableBalance {
    final clearedNet = _settlements
        .where((s) => s.status == SettlementStatus.available)
        .fold(0.0, (sum, s) => sum + s.netAmount);
    return clearedNet;
  }

  double get escrowBalance {
    final inEscrowNet = _settlements
        .where((s) => s.status == SettlementStatus.inEscrow)
        .fold(0.0, (sum, s) => sum + s.netAmount);
    return inEscrowNet;
  }

  double get totalWithdrawn {
    return _payouts
        .where((p) => p.status == PayoutStatus.completed || p.status == PayoutStatus.processing)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get lifetimeNetEarnings {
    return _settlements.fold(0.0, (sum, s) => sum + s.netAmount);
  }

  double get lifetimeGrossRevenue {
    return _settlements.fold(0.0, (sum, s) => sum + s.grossAmount);
  }

  double get totalFeesPaid {
    return _settlements.fold(0.0, (sum, s) => sum + (s.platformFee + s.paymentProcessingFee));
  }

  // --- Product Management ---

  void addProduct(SellerProduct product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(SellerProduct updated) {
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _products[idx] = updated;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleProductStatus(String id) {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final current = _products[idx];
      _products[idx] = current.copyWith(
        status: current.status == SellerProductStatus.active
            ? SellerProductStatus.draft
            : SellerProductStatus.active,
      );
      notifyListeners();
    }
  }

  void updateStock(String id, int delta) {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final current = _products[idx];
      final newStock = (current.stock + delta).clamp(0, 9999);
      _products[idx] = current.copyWith(stock: newStock);
      notifyListeners();
    }
  }

  // --- Order Management & Escrow Lifecycle ---

  void updateOrderStatus(
    String orderId,
    SellerOrderStatus newStatus, {
    String? carrier,
    String? trackingNumber,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId || o.orderNumber == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(
        status: newStatus,
        carrier: carrier,
        trackingNumber: trackingNumber,
        shippedAt: newStatus == SellerOrderStatus.shipped ? DateTime.now() : null,
      );

      // If delivered, release settlement from inEscrow to available
      if (newStatus == SellerOrderStatus.delivered) {
        final orderNumber = _orders[idx].orderNumber;
        final sIdx = _settlements.indexWhere(
          (s) => s.orderId == orderId || s.orderId == orderNumber,
        );
        if (sIdx != -1 && _settlements[sIdx].status == SettlementStatus.inEscrow) {
          _settlements[sIdx] = _settlements[sIdx].copyWith(
            status: SettlementStatus.available,
            clearedDate: DateTime.now(),
          );
        }
      }

      notifyListeners();
    }
  }

  // --- Payout & Withdrawal Execution ---

  bool requestPayout({
    required double amount,
    required String destinationBank,
    required String destinationAccount,
    String speed = 'Instant',
  }) {
    if (amount <= 0 || amount > availableBalance) {
      return false;
    }

    final payoutId = 'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final record = SellerPayoutRecord(
      id: payoutId,
      requestedAt: DateTime.now(),
      completedAt: speed == 'Instant' ? DateTime.now() : null,
      amount: amount,
      destinationBank: destinationBank,
      destinationAccount: destinationAccount,
      referenceCode: 'TRN-PAY-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      status: speed == 'Instant' ? PayoutStatus.completed : PayoutStatus.processing,
      transferSpeed: speed,
    );

    _payouts.insert(0, record);

    // Mark settled items as paidOut up to the withdrawn amount
    double remainingToDeduct = amount;
    for (int i = 0; i < _settlements.length; i++) {
      if (_settlements[i].status == SettlementStatus.available) {
        if (_settlements[i].netAmount <= remainingToDeduct) {
          remainingToDeduct -= _settlements[i].netAmount;
          _settlements[i] = _settlements[i].copyWith(
            status: SettlementStatus.paidOut,
            payoutBatchId: payoutId,
          );
        } else {
          // Partial deduction: split settlement entry
          final original = _settlements[i];
          final deductedPortion = remainingToDeduct;
          final remainingPortion = original.netAmount - deductedPortion;

          _settlements[i] = original.copyWith(
            netAmount: remainingPortion,
            status: SettlementStatus.available,
          );

          _settlements.insert(
            i + 1,
            SellerSettlement(
              id: '${original.id}_paid',
              orderId: original.orderId,
              customerName: original.customerName,
              itemsSummary: original.itemsSummary,
              orderDate: original.orderDate,
              clearedDate: original.clearedDate,
              grossAmount: (original.grossAmount * (deductedPortion / original.netAmount)),
              platformFee: (original.platformFee * (deductedPortion / original.netAmount)),
              paymentProcessingFee: (original.paymentProcessingFee * (deductedPortion / original.netAmount)),
              netAmount: deductedPortion,
              status: SettlementStatus.paidOut,
              payoutBatchId: payoutId,
            ),
          );

          remainingToDeduct = 0;
          break;
        }
      }
      if (remainingToDeduct <= 0.001) break;
    }

    notifyListeners();
    return true;
  }

  // --- Shop Profile Management ---

  void updateShopProfile(ShopProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  // --- Initial Demo Data ---

  void _initDemoData() {
    _profile = ShopProfile(
      id: 'shop_001',
      name: 'Maison Trentify Studio',
      handle: '@maisontrentify',
      logoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&auto=format&fit=crop&q=80',
      bio: 'Contemporary luxury tailoring & streetwear couture engineered in Paris & Tokyo.',
      email: 'concierge@maisontrentify.com',
      phone: '+1 (555) 234-8901',
      address: '742 Fashion Avenue, New York, NY 10018',
      rating: 4.96,
      reviewCount: 428,
      totalSales: 1280,
      followerCount: 14200,
      returnPolicy: '30-day effortless worldwide returns on all unworn garments with tags attached.',
      payoutBankName: 'ABA Bank (Advanced Bank of Asia)',
      payoutAccountNumber: '001 849 204 (USD)',
      payoutAccountHolder: 'MAISON TRENTIFY CO., LTD',
    );

    _products.addAll([
      SellerProduct(
        id: 'sp_1',
        title: 'Oversized Silk Blend Blazer',
        description: 'Double-breasted tailored blazer crafted from premium Italian silk-wool blend with padded shoulders.',
        brand: 'Maison Trentify',
        category: 'Women',
        price: 289.00,
        originalPrice: 349.00,
        costPrice: 95.00,
        images: [
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&auto=format&fit=crop&q=80',
        ],
        sizes: ['XS', 'S', 'M', 'L'],
        colors: ['Black', 'Oatmeal', 'Navy'],
        stock: 14,
        status: SellerProductStatus.active,
        salesCount: 142,
        viewsCount: 3820,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      SellerProduct(
        id: 'sp_2',
        title: 'Minimalist Cashmere Knit Sweater',
        description: 'Ultra-soft grade-A Mongolian cashmere pullover with ribbed cuffs and relaxed crewneck silhouette.',
        brand: 'Maison Trentify',
        category: 'Men',
        price: 195.00,
        originalPrice: 220.00,
        costPrice: 62.00,
        images: [
          'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=800&auto=format&fit=crop&q=80',
        ],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Sage', 'Charcoal', 'Ivory'],
        stock: 4,
        status: SellerProductStatus.active,
        salesCount: 89,
        viewsCount: 2150,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      SellerProduct(
        id: 'sp_3',
        title: 'Structured Leather Crossbody Bag',
        description: 'Full-grain calfskin leather box bag with polished palladium hardware and adjustable strap.',
        brand: 'Trentify Studio',
        category: 'Bags',
        price: 340.00,
        costPrice: 110.00,
        images: [
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800&auto=format&fit=crop&q=80',
        ],
        sizes: ['One Size'],
        colors: ['Cognac', 'Midnight Black'],
        stock: 0,
        status: SellerProductStatus.active,
        salesCount: 64,
        viewsCount: 1940,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      SellerProduct(
        id: 'sp_4',
        title: 'Pleated Wide-Leg Wool Trousers',
        description: 'High-waisted draped wool trousers with deep pleats and tailored horn button fastening.',
        brand: 'Maison Trentify',
        category: 'Women',
        price: 210.00,
        costPrice: 70.00,
        images: [
          'https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?w=800&auto=format&fit=crop&q=80',
        ],
        sizes: ['XS', 'S', 'M'],
        colors: ['Mocha', 'Black'],
        stock: 18,
        status: SellerProductStatus.active,
        salesCount: 38,
        viewsCount: 980,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      SellerProduct(
        id: 'sp_5',
        title: 'Sculptural Chunky Loafers',
        description: 'Brushed spazzolato leather loafers with flared lug soles and tonal penny strap detail.',
        brand: 'Trentify Studio',
        category: 'Shoes',
        price: 265.00,
        costPrice: 88.00,
        images: [
          'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=800&auto=format&fit=crop&q=80',
        ],
        sizes: ['38', '39', '40', '41', '42'],
        colors: ['Black Patent', 'Burgundy'],
        stock: 3,
        status: SellerProductStatus.draft,
        salesCount: 0,
        viewsCount: 120,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    _orders.addAll([
      SellerOrder(
        id: 'ord_101',
        orderNumber: 'TRN-89452',
        customerName: 'Sophia Laurent',
        customerEmail: 'sophia.laurent@gmail.com',
        customerPhone: '+1 (555) 349-1029',
        customerAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
        shippingAddress: '452 Madison Ave, Apt 12B, New York, NY 10022',
        items: [
          SellerOrderItem(
            productId: 'sp_1',
            title: 'Oversized Silk Blend Blazer',
            imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&auto=format&fit=crop&q=80',
            size: 'M',
            color: 'Black',
            quantity: 1,
            unitPrice: 289.00,
          ),
          SellerOrderItem(
            productId: 'sp_4',
            title: 'Pleated Wide-Leg Wool Trousers',
            imageUrl: 'https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?w=400&auto=format&fit=crop&q=80',
            size: 'S',
            color: 'Mocha',
            quantity: 1,
            unitPrice: 210.00,
          ),
        ],
        subtotal: 499.00,
        shippingFee: 15.00,
        tax: 41.16,
        total: 555.16,
        status: SellerOrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      SellerOrder(
        id: 'ord_102',
        orderNumber: 'TRN-89440',
        customerName: 'Marcus Vance',
        customerEmail: 'm.vance@vanceholdings.com',
        customerPhone: '+1 (555) 782-9901',
        customerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        shippingAddress: '1200 Lake Shore Dr, Chicago, IL 60611',
        items: [
          SellerOrderItem(
            productId: 'sp_3',
            title: 'Structured Leather Crossbody Bag',
            imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&auto=format&fit=crop&q=80',
            size: 'One Size',
            color: 'Cognac',
            quantity: 1,
            unitPrice: 340.00,
          ),
        ],
        subtotal: 340.00,
        shippingFee: 0.00,
        tax: 27.20,
        total: 367.20,
        status: SellerOrderStatus.processing,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      SellerOrder(
        id: 'ord_103',
        orderNumber: 'TRN-89312',
        customerName: 'Chloe Dupont',
        customerEmail: 'chloe.dupont@fashion.fr',
        customerPhone: '+33 6 12 34 56 78',
        customerAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
        shippingAddress: '18 Rue de la Paix, 75002 Paris, France',
        items: [
          SellerOrderItem(
            productId: 'sp_1',
            title: 'Oversized Silk Blend Blazer',
            imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&auto=format&fit=crop&q=80',
            size: 'S',
            color: 'Oatmeal',
            quantity: 1,
            unitPrice: 289.00,
          ),
        ],
        subtotal: 289.00,
        shippingFee: 25.00,
        tax: 0.00,
        total: 314.00,
        status: SellerOrderStatus.shipped,
        carrier: 'DHL Express',
        trackingNumber: 'DHL-9481029418',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        shippedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      SellerOrder(
        id: 'ord_104',
        orderNumber: 'TRN-89201',
        customerName: 'Alexander Kim',
        customerEmail: 'alex.kim@gmail.com',
        customerPhone: '+1 (555) 901-4433',
        customerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
        shippingAddress: '789 Olympic Blvd, Los Angeles, CA 90015',
        items: [
          SellerOrderItem(
            productId: 'sp_2',
            title: 'Minimalist Cashmere Knit Sweater',
            imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&auto=format&fit=crop&q=80',
            size: 'L',
            color: 'Sage',
            quantity: 1,
            unitPrice: 195.00,
          ),
        ],
        subtotal: 195.00,
        shippingFee: 0.00,
        tax: 15.60,
        total: 210.60,
        status: SellerOrderStatus.delivered,
        carrier: 'FedEx Priority',
        trackingNumber: 'FDX-774910284',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        shippedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    // Initialize Realistic Settlement Statements and Past Payouts
    _settlements.addAll([
      // 1. In Escrow: Pending Order 101
      SellerSettlement(
        id: 'SET-901',
        orderId: 'TRN-89452',
        customerName: 'Sophia Laurent',
        itemsSummary: '1x Silk Blazer, 1x Wool Trousers',
        orderDate: DateTime.now().subtract(const Duration(minutes: 45)),
        grossAmount: 499.00,
        platformFee: 24.95, // 5%
        paymentProcessingFee: 12.48, // 2.5%
        netAmount: 461.57,
        status: SettlementStatus.inEscrow,
      ),
      // 2. In Escrow: Processing Order 102
      SellerSettlement(
        id: 'SET-902',
        orderId: 'TRN-89440',
        customerName: 'Marcus Vance',
        itemsSummary: '1x Structured Leather Crossbody',
        orderDate: DateTime.now().subtract(const Duration(hours: 3)),
        grossAmount: 340.00,
        platformFee: 17.00, // 5%
        paymentProcessingFee: 8.50, // 2.5%
        netAmount: 314.50,
        status: SettlementStatus.inEscrow,
      ),
      // 3. In Escrow: Shipped Order 103
      SellerSettlement(
        id: 'SET-903',
        orderId: 'TRN-89312',
        customerName: 'Chloe Dupont',
        itemsSummary: '1x Silk Blend Blazer',
        orderDate: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        grossAmount: 289.00,
        platformFee: 14.45,
        paymentProcessingFee: 7.23,
        netAmount: 267.32,
        status: SettlementStatus.inEscrow,
      ),
      // 4. Available for Payout: Delivered Order 104
      SellerSettlement(
        id: 'SET-904',
        orderId: 'TRN-89201',
        customerName: 'Alexander Kim',
        itemsSummary: '1x Cashmere Knit Sweater',
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        clearedDate: DateTime.now().subtract(const Duration(days: 1)),
        grossAmount: 195.00,
        platformFee: 9.75,
        paymentProcessingFee: 4.88,
        netAmount: 180.37,
        status: SettlementStatus.available,
      ),
      // 5. Available for Payout: Delivered Order from last week
      SellerSettlement(
        id: 'SET-905',
        orderId: 'TRN-88914',
        customerName: 'Elena Rostova',
        itemsSummary: '2x Oversized Silk Blend Blazer',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        clearedDate: DateTime.now().subtract(const Duration(days: 3)),
        grossAmount: 578.00,
        platformFee: 28.90,
        paymentProcessingFee: 14.45,
        netAmount: 534.65,
        status: SettlementStatus.available,
      ),
      // 6. Available for Payout: Delivered Order from last week
      SellerSettlement(
        id: 'SET-906',
        orderId: 'TRN-88750',
        customerName: 'Julian Sterling',
        itemsSummary: '1x Structured Leather Bag, 1x Knit Sweater',
        orderDate: DateTime.now().subtract(const Duration(days: 7)),
        clearedDate: DateTime.now().subtract(const Duration(days: 4)),
        grossAmount: 535.00,
        platformFee: 26.75,
        paymentProcessingFee: 13.38,
        netAmount: 494.87,
        status: SettlementStatus.available,
      ),
      // 7. Paid Out batch
      SellerSettlement(
        id: 'SET-880',
        orderId: 'TRN-88210',
        customerName: 'Claire Redfield',
        itemsSummary: '3x Silk Blend Blazer',
        orderDate: DateTime.now().subtract(const Duration(days: 14)),
        clearedDate: DateTime.now().subtract(const Duration(days: 11)),
        grossAmount: 867.00,
        platformFee: 43.35,
        paymentProcessingFee: 21.68,
        netAmount: 801.97,
        status: SettlementStatus.paidOut,
        payoutBatchId: 'PO-882194',
      ),
    ]);

    _payouts.addAll([
      SellerPayoutRecord(
        id: 'PO-882194',
        requestedAt: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
        amount: 801.97,
        destinationBank: 'ABA Bank (USD)',
        destinationAccount: '•••• 8821',
        referenceCode: 'TRN-PAY-882194',
        status: PayoutStatus.completed,
        transferSpeed: 'Instant Transfer',
      ),
      SellerPayoutRecord(
        id: 'PO-879012',
        requestedAt: DateTime.now().subtract(const Duration(days: 24)),
        completedAt: DateTime.now().subtract(const Duration(days: 24)),
        amount: 1450.00,
        destinationBank: 'ABA Bank (USD)',
        destinationAccount: '•••• 8821',
        referenceCode: 'TRN-PAY-879012',
        status: PayoutStatus.completed,
        transferSpeed: 'Instant Transfer',
      ),
    ]);
  }
}
