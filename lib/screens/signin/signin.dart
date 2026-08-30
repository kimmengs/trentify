import 'package:flutter/widgets.dart';
import 'sign_in_ios.dart';

/// Route to this in GoRouter. It picks the native page at runtime.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignInPageCupertino();
  }
}
