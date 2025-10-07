import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trentify/screens/home/home_android.dart';
import 'package:trentify/screens/home/home_ios.dart';

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _isCupertino
        ? const TrendifyHomeCupertino()
        : const TrendifyHomeCupertino();
  }
}
