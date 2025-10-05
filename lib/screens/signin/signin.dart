import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'sign_in_ios.dart';
import 'sign_in_android.dart';

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// Route to this in GoRouter. It picks the native page at runtime.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _isCupertino
        ? const SignInPageCupertino()
        : const SignInPageAndroid();
  }
}
