import 'package:flutter/material.dart';

class RoundIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const RoundIconButtonWidget({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 32, height: 32, child: Icon(icon, size: 18)),
      ),
    );
  }
}
