import 'package:flutter/cupertino.dart';

class DarkCircleWidget extends StatelessWidget {
  final Widget child;
  const DarkCircleWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xCC000000), // black w/ opacity for the mock look
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
