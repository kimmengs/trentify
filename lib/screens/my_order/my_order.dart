import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trentify/model/order_product.dart';
import 'package:trentify/model/order_status.dart';
import 'package:trentify/model/order_summary.dart';
import 'package:trentify/screens/my_order/cancel_sheets.dart';
import 'package:trentify/screens/my_order/order_list_widget.dart';
import 'package:trentify/screens/my_order/segment_tab_widget.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final List<OrderSummary> _orders;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);

    // mock orders
    _orders = [
      OrderSummary(
        id: 'A-1001',
        createdAt: DateTime.now(),
        products: const [
          OrderProduct(
            'Urban Blend Long Sleeve Shirt',
            'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
          ),
          OrderProduct('Slim Jeans', 'https://picsum.photos/seed/jean/400/600'),
          OrderProduct(
            'Canvas Belt',
            'https://picsum.photos/seed/belt/400/600',
          ),
        ],
        total: 441.50,
        status: OrderStatus.active,
      ),
      OrderSummary(
        id: 'A-1000',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        products: const [
          OrderProduct(
            'Urban Elegance Business Jacket',
            'https://picsum.photos/seed/jacket/400/600',
          ),
        ],
        total: 184.50,
        status: OrderStatus.active,
      ),
      OrderSummary(
        id: 'A-0999',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        products: const [
          OrderProduct(
            'Classic Hoodie',
            'https://picsum.photos/seed/hoodie/400/600',
          ),
          OrderProduct('Basic Tee', 'https://picsum.photos/seed/tee/400/600'),
        ],
        total: 120.00,
        status: OrderStatus.completed,
      ),
      OrderSummary(
        id: 'A-0998',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        products: const [
          OrderProduct(
            'Modal Knit',
            'https://picsum.photos/seed/modal/400/600',
          ),
        ],
        total: 90.00,
        status: OrderStatus.canceled,
      ),
    ];
  }

  Future<void> _requestCancel(OrderSummary order) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CancelSheet(
        onConfirm: () => Navigator.pop(context, true),
        onDismiss: () => Navigator.pop(context, false),
      ),
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const CancelSuccessSheet(),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final activeCount = _orders
        .where((o) => o.status == OrderStatus.active)
        .length;
    final completedCount = _orders
        .where((o) => o.status == OrderStatus.completed)
        .length;
    final canceledCount = _orders
        .where((o) => o.status == OrderStatus.canceled)
        .length;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),

          // Segments (tab bar styled like pills)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedTabsWidget(
              controller: _tab,
              items: [
                'Active ($activeCount)',
                'Completed ($completedCount)',
                'Canceled ($canceledCount)',
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Lists
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                OrderListWidget(
                  orders: _orders.where((o) => o.status == OrderStatus.active),
                  onRequestCancel: _requestCancel,
                ),
                OrderListWidget(
                  orders: _orders.where(
                    (o) => o.status == OrderStatus.completed,
                  ),
                  onRequestCancel: _requestCancel,
                ),
                OrderListWidget(
                  orders: _orders.where(
                    (o) => o.status == OrderStatus.canceled,
                  ),
                  onRequestCancel: _requestCancel,
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: cs.surface,
    );
  }
}
