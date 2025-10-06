import 'package:flutter/material.dart';
import 'package:trentify/screens/home/home.dart';
import 'package:trentify/screens/more/%20more_page.dart';

class HomeShellAndroid extends StatefulWidget {
  const HomeShellAndroid({super.key});

  @override
  State<HomeShellAndroid> createState() => _HomeShellAndroidState();
}

class _HomeShellAndroidState extends State<HomeShellAndroid> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const _ScaffoldPage(
        title: 'Account',
        child: Text('Account – Coming soon'),
      ),
      const _ScaffoldPage(
        title: 'Analytics',
        child: Text('Analytics – Coming soon'),
      ),
      const MorePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),

          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'My Order',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _ScaffoldPage extends StatelessWidget {
  const _ScaffoldPage({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: child),
    );
  }
}
