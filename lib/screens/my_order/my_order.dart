import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/l10n/app_localizations.dart';
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
  late List<OrderSummary> _orders;
  final TextEditingController _searchCtl = TextEditingController();
  String _searchQuery = '';
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);

    _orders = [
      OrderSummary(
        id: 'ORD-1001',
        createdAt: DateTime.now(),
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
    ];
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _tab.dispose();
    super.dispose();
  }

  Future<void> _requestCancel(OrderSummary order) async {
    HapticFeedback.lightImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CancelSheet(
        onConfirm: () => Navigator.pop(context, true),
        onDismiss: () => Navigator.pop(context, false),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _orders[index] = OrderSummary(
            id: order.id,
            createdAt: order.createdAt,
            products: order.products,
            total: order.total,
            status: OrderStatus.canceled,
          );
        }
      });

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const CancelSuccessSheet(),
      );
    }
  }

  List<OrderSummary> _filterOrders(OrderStatus status) {
    return _orders.where((o) {
      final matchesStatus = o.status == status;
      if (!matchesStatus) return false;
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final matchesId = o.id.toLowerCase().contains(q);
      final matchesProduct = o.products.any((p) => p.title.toLowerCase().contains(q));
      return matchesId || matchesProduct;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    final activeCount = _orders.where((o) => o.status == OrderStatus.active).length;
    final completedCount = _orders.where((o) => o.status == OrderStatus.completed).length;
    final canceledCount = _orders.where((o) => o.status == OrderStatus.canceled).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('my_orders'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(CupertinoIcons.back, color: textPrimary),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.search,
              color: textPrimary,
              size: 22,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchCtl.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Collapsible Search Bar
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtl,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 14,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr('order_search_placeholder'),
                    hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                    prefixIcon: Icon(CupertinoIcons.search, size: 18, color: textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_thick_circled, size: 16),
                            onPressed: () {
                              _searchCtl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

          // Sliding Segmented Tab Pill Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: SegmentedTabsWidget(
              controller: _tab,
              items: [
                '${context.tr('order_active')} ($activeCount)',
                '${context.tr('order_completed')} ($completedCount)',
                '${context.tr('order_canceled')} ($canceledCount)',
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tab,
              physics: const BouncingScrollPhysics(),
              children: [
                OrderListWidget(
                  orders: _filterOrders(OrderStatus.active),
                  onRequestCancel: _requestCancel,
                ),
                OrderListWidget(
                  orders: _filterOrders(OrderStatus.completed),
                  onRequestCancel: _requestCancel,
                ),
                OrderListWidget(
                  orders: _filterOrders(OrderStatus.canceled),
                  onRequestCancel: _requestCancel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
