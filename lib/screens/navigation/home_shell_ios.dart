import 'package:flutter/cupertino.dart';
import 'package:trentify/screens/home/home.dart';
import 'package:trentify/screens/more/%20more_page.dart';
import 'package:trentify/theme/themed_background.dart';

class HomeShellCupertino extends StatelessWidget {
  const HomeShellCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        // colors adapt to light/dark automatically; tweak if you want
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.ellipsis_circle_fill),
            label: 'More',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            // Your existing HomePage already has its own content/nav
            return const ThemedBackground(child: HomePage());

          case 1:
            return const _TabScaffold(
              title: 'Account',
              child: Center(child: Text('Account – Coming soon')),
            );

          case 2:
            return const _TabScaffold(
              title: 'Analytics',
              child: Center(child: Text('Analytics – Coming soon')),
            );

          case 3:
            return const MorePage();

          default:
            return const _TabScaffold(
              title: 'Tab',
              child: Center(child: Text('Coming soon')),
            );
        }
      },
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(child: child),
    );
  }
}
