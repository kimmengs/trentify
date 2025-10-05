import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/screens/home/home.dart';
import 'package:trentify/screens/more/%20more_page.dart';
import 'package:trentify/screens/navigation/modern_nav.dart';

class HomeShellCupertino extends StatefulWidget {
  const HomeShellCupertino({super.key});
  @override
  State<HomeShellCupertino> createState() => _HomeShellCupertinoState();
}

class _HomeShellCupertinoState extends State<HomeShellCupertino> {
  int _index = 0;
  final _visited = <bool>[true, false, false, false];
  final _pages = <Widget?>[null, null, null, null];

  Widget _buildPage(int i) {
    switch (i) {
      case 0:
        return const HomePage(); // real pages here
      case 1:
        return const HomePage();
      case 2:
        return const HomePage();
      case 3:
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
          ModernBottomBarItem(CupertinoIcons.person_2, 'Lead'),
          ModernBottomBarItem(CupertinoIcons.person_2, 'Challenge'),
          ModernBottomBarItem(CupertinoIcons.ellipsis, 'More'),
        ],
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
