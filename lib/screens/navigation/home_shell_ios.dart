import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/screens/add_to_cart/add_to_cart.dart';
import 'package:trentify/screens/home/home.dart';
import 'package:trentify/screens/more/more_page.dart';
import 'package:trentify/screens/my_order/my_order.dart';
import 'package:trentify/screens/navigation/modern_nav.dart';
import 'package:trentify/screens/wish_list/wish_list.dart';

import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class HomeShellCupertino extends StatefulWidget {
  const HomeShellCupertino({super.key});

  static void navigateTo(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomeShellCupertinoState>();
    state?.setIndex(index);
  }

  @override
  State<HomeShellCupertino> createState() => _HomeShellCupertinoState();
}

class _HomeShellCupertinoState extends State<HomeShellCupertino> {
  int _index = 0;
  bool _appliedExtraOnce = false; // <- important

  final _visited = <bool>[true, false, false, false, false];
  final _pages = <Widget?>[null, null, null, null, null];

  void setIndex(int i) => setState(() => _index = i);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read tabIndex from GoRouter extra ONLY when it exists
    // and only apply it once per entry into the shell.
    final routerState = GoRouterState.of(context);
    final extra = routerState.extra;
    if (extra is Map && extra['tabIndex'] is int) {
      final idx = extra['tabIndex'] as int;
      if (idx != _index) _index = idx;
      _appliedExtraOnce = true;
    } else if (!_appliedExtraOnce) {
      // first time without extra: do nothing (keep default 0)
      _appliedExtraOnce = true;
    }
  }

  Widget _buildPage(int i) {
    switch (i) {
      case 0:
        return const HomePage();
      case 1:
        return const WishListPage();
      case 2:
        return const AddToCartPage();
      case 3:
        return const MyOrderPage();
      case 4:
        return const MorePage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    _visited[_index] = true;
    final cart = context.watch<CartProvider>();

    final children = List<Widget>.generate(_visited.length, (i) {
      if (!_visited[i]) return const SizedBox.shrink();
      return _pages[i] ??= _buildPage(i);
    });

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _index, children: children),
      bottomNavigationBar: ModernBottomBar(
        items: [
          ModernBottomBarItem(CupertinoIcons.house, context.tr('nav_home')),
          ModernBottomBarItem(CupertinoIcons.heart_circle, context.tr('nav_wishlist')),
          ModernBottomBarItem(
            CupertinoIcons.cart_fill,
            context.tr('nav_cart'),
            badge: cart.totalCount > 0 ? '${cart.totalCount}' : null,
          ),
          ModernBottomBarItem(CupertinoIcons.doc_text_fill, context.tr('nav_orders')),
          ModernBottomBarItem(CupertinoIcons.person, context.tr('nav_account')),
        ],
        currentIndex: _index,
        onTap: setIndex,
      ),
    );
  }
}
