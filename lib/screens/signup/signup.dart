import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:trentify/screens/signup/signup_android.dart';
import 'package:trentify/screens/signup/signup_ios.dart';

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _isCupertino
        ? const SignUpPageCupertino()
        : const SignUpPageAndroid();
  }
}
