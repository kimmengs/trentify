import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SignUpPageCupertino extends StatefulWidget {
  const SignUpPageCupertino({super.key});

  @override
  State<SignUpPageCupertino> createState() => _SignUpPageCupertinoState();
}

class _SignUpPageCupertinoState extends State<SignUpPageCupertino> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _nameNode = FocusNode();
  final _emailNode = FocusNode();
  final _pwdNode = FocusNode();

  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _pwdCtl.dispose();
    _nameNode.dispose();
    _emailNode.dispose();
    _pwdNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _submitting = false);

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.go(AppRoutes.signIn),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                context.tr('create_account'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('join_trentify'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
              const SizedBox(height: 28),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    Text(
                      context.tr('full_name'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtl,
                      focusNode: _nameNode,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Alex Morgan',
                        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          size: 20,
                          color: textSecondary,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _emailNode.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Email Address
                    Text(
                      context.tr('email_address'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtl,
                      focusNode: _emailNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: context.tr('email_hint'),
                        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                        prefixIcon: Icon(
                          CupertinoIcons.mail,
                          size: 20,
                          color: textSecondary,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _pwdNode.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    Text(
                      context.tr('password'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pwdCtl,
                      focusNode: _pwdNode,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                        prefixIcon: Icon(
                          CupertinoIcons.lock,
                          size: 20,
                          color: textSecondary,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                            size: 18,
                            color: textSecondary,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up CTA Button
                    PressableScale(
                      onTap: _submitting ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _submitting
                              ? const CupertinoActivityIndicator(color: Colors.white)
                              : Text(
                                  context.tr('sign_up'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign in Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${context.tr('have_account')} ',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.signIn),
                    child: Text(
                      context.tr('sign_in'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
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
