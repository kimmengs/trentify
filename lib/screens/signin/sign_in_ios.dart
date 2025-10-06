// lib/screens/auth/sign_in/sign_in_ios.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SignInPageCupertino extends StatefulWidget {
  const SignInPageCupertino({super.key});

  @override
  State<SignInPageCupertino> createState() => _SignInPageCupertinoState();
}

class _SignInPageCupertinoState extends State<SignInPageCupertino> {
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _emailNode = FocusNode();
  final _pwdNode = FocusNode();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwdCtl.dispose();
    _emailNode.dispose();
    _pwdNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.\-+]+@[\w\.\-]+\.[A-Za-z]{2,}$');
    if (!re.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if ((v ?? '').isEmpty) return 'Password is required';
    if ((v ?? '').length < 6) return 'Minimum 6 characters';
    return null;
  }

  Future<void> _signIn() async {
    // Dismiss keyboard
    _emailNode.unfocus();
    _pwdNode.unfocus();

    // Simple inline validation (replace with your auth flow)
    // final emailErr = _validateEmail(_emailCtl.text);
    // final pwdErr = _validatePassword(_pwdCtl.text);
    // if (emailErr != null || pwdErr != null) {
    //   _showCupertinoAlert([emailErr, pwdErr].whereType<String>().join('\n'));
    //   return;
    // }

    // setState(() => _loading = true);
    // await Future.delayed(const Duration(milliseconds: 900));
    // if (!mounted) return;
    // setState(() => _loading = false);

    if (!mounted) return;
    context.go('/home');
  }

  void _showCupertinoAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Check your input'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    // Set iOS-style status bar (optional)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: CupertinoColors.systemBackground,
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login to Your Account'),
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        bottom: false,
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    height: 96,
                    width: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFF528F65),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.square_grid_2x2,
                        size: 36,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Email
                _LabeledField(
                  label: 'Email',
                  child: CupertinoTextField(
                    controller: _emailCtl,
                    focusNode: _emailNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    placeholder: 'you@example.com',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(CupertinoIcons.envelope_open),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    onSubmitted: (_) => _pwdNode.requestFocus(),
                  ),
                ),
                const SizedBox(height: 14),

                // Password
                _LabeledField(
                  label: 'Password',
                  child: CupertinoTextField(
                    controller: _pwdCtl,
                    focusNode: _pwdNode,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    placeholder: '••••••••',
                    clearButtonMode: OverlayVisibilityMode.never,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(CupertinoIcons.lock),
                    ),
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minSize: 0,
                      onPressed: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        size: 20,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    onSubmitted: (_) => _signIn(),
                  ),
                ),

                const SizedBox(height: 18),

                // Sign in button
                CupertinoButton.filled(
                  color: Color(0xFF528F65),
                  onPressed: _loading ? null : _signIn,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _loading
                      ? const CupertinoActivityIndicator()
                      : const Text('Sign in'),
                ),

                const SizedBox(height: 10),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: navigate to forgot page
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 4),

                // Sign up row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? '),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => context.go('/signup'),
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small helper to mimic Material's "labelText" feel in Cupertino land.
class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final labelStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      fontSize: 13,
      color: CupertinoColors.inactiveGray,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        _CupertinoFieldContainer(child: child),
      ],
    );
  }
}

/// Rounded container with iOS field look (thin border, subtle background).
class _CupertinoFieldContainer extends StatelessWidget {
  const _CupertinoFieldContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = CupertinoDynamicColor.resolve(
      CupertinoColors.secondarySystemBackground,
      context,
    );
    final border = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: 0.6), width: 0.8),
      ),
      child: child,
    );
  }
}
