import 'package:flutter/cupertino.dart';

class WishListPage extends StatelessWidget {
  const WishListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(child: Center(child: Text("Whish List Page"))),
    );
  }
}
