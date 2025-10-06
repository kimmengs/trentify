import 'package:flutter/cupertino.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(child: Center(child: Text("Cart Page"))),
    );
  }
}
