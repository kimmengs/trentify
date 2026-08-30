import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/screens/navigation/modern_nav.dart';
import 'package:trentify/screens/seller/dashboard/seller_dashboard_page.dart';
import 'package:trentify/screens/seller/inventory/inventory_page.dart';
import 'package:trentify/screens/seller/orders/seller_order_list_page.dart';
import 'package:trentify/screens/seller/products/seller_product_list_page.dart';
import 'package:trentify/screens/seller/profile/shop_profile_page.dart';

class SellerShell extends StatefulWidget {
  const SellerShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  static void navigateTo(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_SellerShellState>();
    state?.setIndex(index);
  }

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  late int _index;
  bool _appliedExtraOnce = false;
  final _seller = SellerProvider.instance;

  final _visited = <bool>[true, false, false, false, false];
  final _pages = <Widget?>[null, null, null, null, null];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _visited[_index] = true;
    _seller.addListener(_onSellerUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routerState = GoRouterState.of(context);
    final extra = routerState.extra;
    if (extra is Map && extra['tabIndex'] is int) {
      final idx = extra['tabIndex'] as int;
      if (idx != _index) _index = idx;
      _appliedExtraOnce = true;
    } else if (!_appliedExtraOnce) {
      _appliedExtraOnce = true;
    }
  }

  @override
  void dispose() {
    _seller.removeListener(_onSellerUpdate);
    super.dispose();
  }

  void _onSellerUpdate() {
    if (mounted) setState(() {});
  }

  void setIndex(int i) => setState(() => _index = i);

  Widget _buildPage(int i) {
    switch (i) {
      case 0:
        return const SellerDashboardPage();
      case 1:
        return const SellerOrderListPage();
      case 2:
        return const SellerProductListPage();
      case 3:
        return const InventoryPage();
      case 4:
        return const ShopProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    _visited[_index] = true;

    final children = List<Widget>.generate(_visited.length, (i) {
      if (!_visited[i]) return const SizedBox.shrink();
      return _pages[i] ??= _buildPage(i);
    });

    final pendingCount = _seller.pendingOrdersCount;
    final lowStockCount = _seller.lowStockCount;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _index, children: children),
      bottomNavigationBar: ModernBottomBar(
        items: [
          ModernBottomBarItem(
            CupertinoIcons.chart_bar_alt_fill,
            context.tr('nav_overview'),
          ),
          ModernBottomBarItem(
            CupertinoIcons.doc_text_fill,
            context.tr('nav_orders'),
            badge: pendingCount > 0 ? '$pendingCount' : null,
          ),
          ModernBottomBarItem(
            CupertinoIcons.square_grid_2x2_fill,
            context.tr('nav_products'),
          ),
          ModernBottomBarItem(
            CupertinoIcons.slider_horizontal_3,
            context.tr('nav_stock'),
            badge: lowStockCount > 0 ? '$lowStockCount' : null,
          ),
          ModernBottomBarItem(
            CupertinoIcons.building_2_fill,
            context.tr('nav_store'),
          ),
        ],
        currentIndex: _index,
        onTap: setIndex,
      ),
    );
  }
}
