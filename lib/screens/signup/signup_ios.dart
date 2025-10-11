// lib/screens/auth/sign_up/sign_up_ios.dart
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/widgets/input_widget.dart';

class SignUpPageCupertino extends StatefulWidget {
  const SignUpPageCupertino({super.key});

  @override
  State<SignUpPageCupertino> createState() => _SignUpPageCupertinoState();
}

class _SignUpPageCupertinoState extends State<SignUpPageCupertino> {
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwdCtl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final emailRe = RegExp(r'^[\w\.\-+]+@[\w\.\-]+\.[A-Za-z]{2,}$');
    if (!emailRe.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '');
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final emailErr = _validateEmail(_emailCtl.text);
    final pwdErr = _validatePassword(_pwdCtl.text);

    if (emailErr != null || pwdErr != null) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Check your details'),
          content: Text([emailErr, pwdErr].whereType<String>().join('\n')),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _submitting = false);

    // Navigate or show success
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Account created'),
        content: Text('Welcome, ${_emailCtl.text.trim()}!'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Nice'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: true,
        border: null,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        middle: Text('Sign up'),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + safe.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF528F65), CupertinoColors.systemBlue],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.circle_grid_3x3_fill,
                    color: CupertinoColors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Create New Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              InputWidget(
                controller: _emailCtl,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(
                  CupertinoIcons.envelope_fill,
                  size: 18,
                  color: CupertinoColors.systemGrey,
                ),
                validator: _validateEmail,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 14),
              InputWidget(
                controller: _pwdCtl,
                placeholder: 'Password',
                obscureText: _obscure,
                prefix: const Icon(
                  CupertinoIcons.lock_fill,
                  size: 18,
                  color: CupertinoColors.systemGrey,
                ),
                suffix: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 0),
                  onPressed: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    size: 20,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
                validator: _validatePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: 18),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(16),
                onPressed: _submitting ? null : _submit,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _submitting
                    ? const CupertinoActivityIndicator()
                    : const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 22),
              // You can reuse your DividerTextWidget / SocialCircleWidget here if desired.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: CupertinoColors.inactiveGray),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.go('/signin'),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFF528F65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
