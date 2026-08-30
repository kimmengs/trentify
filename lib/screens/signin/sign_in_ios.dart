import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/theme/theme_controller.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SignInPageCupertino extends StatefulWidget {
  const SignInPageCupertino({super.key});

  @override
  State<SignInPageCupertino> createState() => _SignInPageCupertinoState();
}

class _SignInPageCupertinoState extends State<SignInPageCupertino>
    with SingleTickerProviderStateMixin {
  final _emailCtl = TextEditingController(text: 'alex.rivera@example.com');
  final _pwdCtl = TextEditingController(text: '••••••••');
  final _emailNode = FocusNode();
  final _pwdNode = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  bool _rememberMe = true;
  bool _isEmailFocused = false;
  bool _isPwdFocused = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _emailNode.addListener(() {
      setState(() => _isEmailFocused = _emailNode.hasFocus);
    });
    _pwdNode.addListener(() {
      setState(() => _isPwdFocused = _pwdNode.hasFocus);
    });

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _emailCtl.dispose();
    _pwdCtl.dispose();
    _emailNode.dispose();
    _pwdNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    HapticFeedback.mediumImpact();
    _emailNode.unfocus();
    _pwdNode.unfocus();

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _loading = false);

    context.go(AppRoutes.home);
  }

  void _fillVipDemoCredentials() {
    HapticFeedback.lightImpact();
    _emailCtl.text = 'alex.rivera@example.com';
    _pwdCtl.text = 'LuxuryFashion2026!';
    _signIn();
  }

  void _showLanguagePickerModal(BuildContext context, bool isDark) {
    HapticFeedback.selectionClick();
    final localeCtl = context.read<LocaleController>();
    final languages = [
      {'code': 'en', 'name': 'English (US)', 'flag': '🇺🇸'},
      {'code': 'km', 'name': 'ភាសាខ្មែរ (Khmer)', 'flag': '🇰🇭'},
      {'code': 'vi', 'name': 'Tiếng Việt (Vietnamese)', 'flag': '🇻🇳'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.tr('language'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ...languages.map((l) {
                final isSelected = localeCtl.locale.languageCode == l['code'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PressableScale(
                    onTap: () {
                      localeCtl.setLanguageCode(l['code']!);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                            : (isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              l['name']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              CupertinoIcons.checkmark_seal_fill,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final localeCtl = context.watch<LocaleController>();
    final themeCtl = context.watch<ThemeController>();

    final cardBg = isDark
        ? const Color(0xFF161B22).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.92);
    final borderColor = isDark
        ? const Color(0xFF30363D).withValues(alpha: 0.8)
        : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);

    final langFlag = switch (localeCtl.locale.languageCode) {
      'km' => '🇰🇭 KM',
      'vi' => '🇻🇳 VI',
      _ => '🇺🇸 EN',
    };

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Dynamic Atmospheric Ambient Glow Orbs
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) => Transform.scale(
                scale: _glowAnimation.value,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withValues(alpha: isDark ? 0.35 : 0.20),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -80,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) => Transform.scale(
                scale: 2.0 - _glowAnimation.value,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.25 : 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Navigation Utility Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Luxury Brand Emblem Tag
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Icon(
                                CupertinoIcons.sparkles,
                                size: 14,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                context.tr('luxury_brand_tag'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Quick Action Pills (Language & Theme)
                      Row(
                        children: [
                          // Theme Switcher Pill
                          PressableScale(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              themeCtl.setMode(
                                isDark ? AppThemeMode.light : AppThemeMode.dark,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Icon(
                                isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                                size: 14,
                                color: isDark ? const Color(0xFFFBBF24) : primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Language Picker Pill
                          PressableScale(
                            onTap: () => _showLanguagePickerModal(context, isDark),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    langFlag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 10,
                                    color: textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Hero 3D App Icon & Animated Badge
                  Center(
                    child: AnimatedEntry(
                      delay: const Duration(milliseconds: 100),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow Halo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.25),
                                  blurRadius: 36,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          // 3D Glass Squircle Icon
                          ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: isDark ? 0.15 : 0.8),
                                    Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/app_icon_3d.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(
                                    CupertinoIcons.bag_fill,
                                    size: 40,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Headline & Description
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 160),
                    child: Column(
                      children: [
                        Text(
                          context.tr('welcome_back'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            context.tr('sign_in_sub'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 1-Tap VIP Guest Access Shortcut Banner
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 200),
                    child: Center(
                      child: PressableScale(
                        onTap: _fillVipDemoCredentials,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                                const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.2 : 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.bolt_fill,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${context.tr('fast_vip_access')} (Alex Rivera)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.arrow_right,
                                size: 12,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Glassmorphic Form Card
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 260),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Field Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('email_address'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: textPrimary,
                                ),
                              ),
                              if (_emailCtl.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () => setState(() => _emailCtl.clear()),
                                  child: Text(
                                    context.tr('clear'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Email Input Field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _isEmailFocused
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: TextField(
                              controller: _emailCtl,
                              focusNode: _emailNode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: context.tr('email_hint'),
                                hintStyle: TextStyle(
                                  color: textSecondary.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  CupertinoIcons.mail_solid,
                                  size: 18,
                                  color: _isEmailFocused ? primaryColor : textSecondary,
                                ),
                                filled: true,
                                fillColor: inputBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: primaryColor, width: 1.8),
                                ),
                              ),
                              onSubmitted: (_) => _pwdNode.requestFocus(),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Password Field Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('password'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                    const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text('Password reset link sent to your email.'),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.tr('forgot_password'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Password Input Field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _isPwdFocused
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: TextField(
                              controller: _pwdCtl,
                              focusNode: _pwdNode,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••••••',
                                hintStyle: TextStyle(
                                  color: textSecondary.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  CupertinoIcons.lock_fill,
                                  size: 18,
                                  color: _isPwdFocused ? primaryColor : textSecondary,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                                    size: 18,
                                    color: textSecondary,
                                  ),
                                ),
                                filled: true,
                                fillColor: inputBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: primaryColor, width: 1.8),
                                ),
                              ),
                              onSubmitted: (_) => _signIn(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Remember Me Toggle
                          Row(
                            children: [
                              CupertinoSwitch(
                                value: _rememberMe,
                                activeTrackColor: primaryColor,
                                onChanged: (v) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _rememberMe = v);
                                },
                              ),
                              const SizedBox(width: 10),
                              Text(
                                context.tr('remember_me'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Sign In Primary CTA Button
                          PressableScale(
                            onTap: _loading ? null : _signIn,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withValues(alpha: 0.88),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_loading)
                                    const CupertinoActivityIndicator(color: Colors.white)
                                  else ...[
                                    Text(
                                      context.tr('sign_in'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      CupertinoIcons.arrow_right,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Social Logins Divider
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 320),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: borderColor, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            context.tr('or_continue_with').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: borderColor, thickness: 1)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Social Auth Buttons (Apple, Google, Face ID)
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 380),
                    child: Row(
                      children: [
                        // Apple Button
                        Expanded(
                          child: _SocialAuthButton(
                            iconWidget: Icon(
                              Icons.apple,
                              size: 22,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            label: 'Apple',
                            onTap: _signIn,
                            borderColor: borderColor,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Google Button
                        Expanded(
                          child: _SocialAuthButton(
                            iconWidget: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF4285F4),
                                ),
                              ),
                            ),
                            label: 'Google',
                            onTap: _signIn,
                            borderColor: borderColor,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Biometric Face ID Button
                        PressableScale(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            _signIn();
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Icon(
                              CupertinoIcons.viewfinder,
                              size: 22,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Switch to Sign Up
                  AnimatedEntry(
                    delay: const Duration(milliseconds: 440),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${context.tr('no_account')} ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push(AppRoutes.signUp);
                          },
                          child: Text(
                            context.tr('sign_up'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bank-Grade Security Guarantee Footnote
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.lock_shield_fill,
                          size: 13,
                          color: textSecondary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('security_guarantee'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;
  final Color borderColor;
  final Color cardBg;
  final Color textPrimary;

  const _SocialAuthButton({
    required this.iconWidget,
    required this.label,
    required this.onTap,
    required this.borderColor,
    required this.cardBg,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
