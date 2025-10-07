// import 'package:flutter/material.dart';
// import 'package:trentify/screens/cart/cart.dart';
// import 'package:trentify/screens/home/home.dart';
// import 'package:trentify/screens/more/ more_page.dart';
// import 'package:trentify/screens/my_order/my_order.dart';
// import 'package:trentify/screens/wish_list/wish_list.dart';

// class HomeShellMaterial extends StatefulWidget {
//   const HomeShellMaterial({super.key});
//   @override
//   State<HomeShellMaterial> createState() => _HomeShellMaterialState();
// }

// class _HomeShellMaterialState extends State<HomeShellMaterial> {
//   int _index = 0;
//   final _visited = <bool>[true, false, false, false, false];
//   final _pages = <Widget?>[null, null, null, null, null];

//   Widget _buildPage(int i) {
//     switch (i) {
//       case 0:
//         return const HomePage();
//       case 1:
//         return const WishListPage();
//       case 2:
//         return const CartPage();
//       case 3:
//         return const MyOrderPage();
//       case 4:
//         return const MorePage();
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // mark current tab as visited
//     _visited[_index] = true;

//     final children = List<Widget>.generate(_visited.length, (i) {
//       if (!_visited[i]) return const SizedBox.shrink(); // not built yet
//       return _pages[i] ??= _buildPage(i); // build once, keep alive
//     });

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.transparent,
//       body: IndexedStack(index: _index, children: children),

//       // MATERIAL 3 NAV BAR (recommended)
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _index,
//         onDestinationSelected: (i) => setState(() => _index = i),
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home_outlined),
//             selectedIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.favorite_border),
//             selectedIcon: Icon(Icons.favorite),
//             label: 'Wishlist',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.shopping_cart_outlined),
//             selectedIcon: Icon(Icons.shopping_cart),
//             label: 'Cart',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.receipt_long_outlined),
//             selectedIcon: Icon(Icons.receipt_long),
//             label: 'My Order',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person_outline),
//             selectedIcon: Icon(Icons.person),
//             label: 'Account',
//           ),
//         ],
//       ),

//       // If you prefer the classic BottomNavigationBar, comment the NavigationBar above
//       // and uncomment this:
//       /*
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _index,
//         type: BottomNavigationBarType.fixed,
//         onTap: (i) => setState(() => _index = i),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
//           BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
//           BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'My Order'),
//           BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
//         ],
//       ),
//       */
//     );
//   }
// }
