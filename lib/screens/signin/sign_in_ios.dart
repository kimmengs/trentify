// lib/screens/auth/sign_in/sign_in_ios.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/widgets/input_widget.dart';

class SignInPageCupertino extends StatefulWidget {
  const SignInPageCupertino({super.key});

  @override
  State<SignInPageCupertino> createState() => _SignInPageCupertinoState();
}

class _SignInPageCupertinoState extends State<SignInPageCupertino> {
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwdCtl.dispose();
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
    FocusManager.instance.primaryFocus?.unfocus();
    final emailErr = _validateEmail(_emailCtl.text);
    final pwdErr = _validatePassword(_pwdCtl.text);
    if (emailErr != null || pwdErr != null) {
      // light inline feedback is enough; you can keep your dialog if you prefer
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        border: null,
        middle: Text('Login'),
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
                      colors: [
                        CupertinoColors.activeBlue,
                        CupertinoColors.systemBlue,
                      ],
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
                'Login to Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
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
                onSubmitted: (_) => _signIn(),
              ),

              const SizedBox(height: 18),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(20),
                onPressed: _loading ? null : _signIn,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _loading
                    ? const CupertinoActivityIndicator()
                    : const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account? ',
                    style: TextStyle(color: CupertinoColors.inactiveGray),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.go('/signup'),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
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
