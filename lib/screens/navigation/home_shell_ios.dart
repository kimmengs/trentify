import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/screens/cart/cart.dart';
import 'package:trentify/screens/home/home.dart';
import 'package:trentify/screens/more/%20more_page.dart';
import 'package:trentify/screens/my_order/my_order.dart';
import 'package:trentify/screens/navigation/modern_nav.dart';
import 'package:trentify/screens/wish_list/wish_list.dart';

class HomeShellCupertino extends StatefulWidget {
  const HomeShellCupertino({super.key});
  @override
  State<HomeShellCupertino> createState() => _HomeShellCupertinoState();
}

class _HomeShellCupertinoState extends State<HomeShellCupertino> {
  int _index = 0;
  final _visited = <bool>[true, false, false, false, false];
  final _pages = <Widget?>[null, null, null, null, null];

  Widget _buildPage(int i) {
    switch (i) {
      case 0:
        return const HomePage();
      case 1:
        return const WishListPage();
      case 2:
        return const CartPage();
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
    // mark current tab as visited
    _visited[_index] = true;

    final children = List<Widget>.generate(_visited.length, (i) {
      if (!_visited[i]) return const SizedBox.shrink(); // not built yet
      return _pages[i] ??= _buildPage(i); // build once, keep
    });

    return Scaffold(
      extendBody: true, // 🔑 lets content render under the bar
      backgroundColor:
          Colors.transparent, // optional if you have your own backdrop
      body: IndexedStack(index: _index, children: children),
      bottomNavigationBar: ModernBottomBar(
        items: const [
          ModernBottomBarItem(CupertinoIcons.house, 'Home'),
          ModernBottomBarItem(CupertinoIcons.heart_circle, 'Wishlist'),
          ModernBottomBarItem(CupertinoIcons.cart_fill, 'Cart'),
          ModernBottomBarItem(CupertinoIcons.doc_text_fill, 'My Order'),
          ModernBottomBarItem(CupertinoIcons.person, 'Account'),
        ],
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
