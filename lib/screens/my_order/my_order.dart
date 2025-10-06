import 'package:flutter/cupertino.dart';

class MyOrderPage extends StatelessWidget {
  const MyOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(child: Center(child: Text("My Order Page"))),
    );
  }
}
