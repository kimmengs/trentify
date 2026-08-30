import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/theme/theme_controller.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/app_badge_pill.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/app_network_image.dart';
import 'package:trentify/widgets/liquid_glass_card.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  void _showLanguagePickerModal(BuildContext context) {
    AppHaptics.light();
    final localeCtl = context.read<LocaleController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161B22).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.tr('select_language'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LanguageOptionTile(
                    flag: '🇺🇸',
                    title: 'English (US)',
                    selected: localeCtl.locale.languageCode == 'en',
                    onTap: () {
                      localeCtl.setLanguageCode('en');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _LanguageOptionTile(
                    flag: '🇰🇭',
                    title: 'ភាសាខ្មែរ (Khmer)',
                    selected: localeCtl.locale.languageCode == 'km',
                    onTap: () {
                      localeCtl.setLanguageCode('km');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _LanguageOptionTile(
                    flag: '🇻🇳',
                    title: 'Tiếng Việt (Vietnamese)',
                    selected: localeCtl.locale.languageCode == 'vi',
                    onTap: () {
                      localeCtl.setLanguageCode('vi');
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final localeCtl = context.watch<LocaleController>();
    final themeCtl = context.watch<ThemeController>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('account_settings'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
              color: primaryColor,
              size: 20,
            ),
            onPressed: () {
              AppHaptics.light();
              themeCtl.setMode(isDark ? AppThemeMode.light : AppThemeMode.dark);
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 140),
          children: [
            // 1. Liquid Glass Profile Hero Card
            AnimatedEntry(
              delay: const Duration(milliseconds: 40),
              child: LiquidGlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar with glowing VIP ring
                        Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const AppNetworkImage(
                                imageUrl: 'https://i.pravatar.cc/150?img=12',
                                width: 64,
                                height: 64,
                                borderRadius: 32,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  CupertinoIcons.checkmark_alt,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Name & Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Alex Rivera',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const AppBadgePill(
                                    label: 'VIP ELITE',
                                    variant: BadgeVariant.vip,
                                    fontSize: 9,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'alex.rivera@example.com',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Edit Button
                        PressableScale(
                          onTap: () {
                            AppHaptics.light();
                            context.push(AppRoutes.editProfile);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.pencil,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _GlassDivider(isDark: isDark),
                    const SizedBox(height: 14),

                    // Stats Quick Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProfileStatPill(
                          count: '2',
                          label: context.tr('order_active'),
                          icon: CupertinoIcons.cube_box_fill,
                          iconColor: const Color(0xFF3B82F6),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => context.go(AppRoutes.home, extra: {'tabIndex': 3}),
                        ),
                        _ProfileStatPill(
                          count: '${cart.totalCount}',
                          label: context.tr('shopping_bag'),
                          icon: CupertinoIcons.bag_fill,
                          iconColor: primaryColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => context.go(AppRoutes.home, extra: {'tabIndex': 2}),
                        ),
                        _ProfileStatPill(
                          count: '5',
                          label: context.tr('nav_wishlist'),
                          icon: CupertinoIcons.heart_fill,
                          iconColor: const Color(0xFFEF4444),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => context.go(AppRoutes.home, extra: {'tabIndex': 1}),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Liquid Glass Seller Portal Card
            AnimatedEntry(
              delay: const Duration(milliseconds: 80),
              child: PressableScale(
                onTap: () {
                  AppHaptics.medium();
                  context.go(AppRoutes.seller);
                },
                child: LiquidGlassCard(
                  borderColor: primaryColor.withValues(alpha: 0.35),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.building_2_fill,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.tr('shop_owner_center'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AppBadgePill(
                                  label: context.tr('active_badge'),
                                  variant: BadgeVariant.success,
                                  fontSize: 9,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              context.tr('shop_owner_sub'),
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.arrow_right_circle_fill,
                        color: primaryColor,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Settings Group 1 - Preferences
            Text(
              context.tr('preferences'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            AnimatedEntry(
              delay: const Duration(milliseconds: 120),
              child: LiquidGlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _LiquidSettingsTile(
                      icon: CupertinoIcons.color_filter,
                      gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
                      title: context.tr('theme_appearance'),
                      subtitle: isDark ? 'Dark Mode (Glass Active)' : 'Light Mode',
                      onTap: () => context.push(AppRoutes.theme),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _GlassDivider(isDark: isDark),
                    _LiquidSettingsTile(
                      icon: CupertinoIcons.globe,
                      gradientColors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      title: context.tr('language_region'),
                      subtitle: localeCtl.displayName,
                      onTap: () => _showLanguagePickerModal(context),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _GlassDivider(isDark: isDark),
                    _LiquidSettingsTile(
                      icon: CupertinoIcons.bell_fill,
                      gradientColors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                      title: context.tr('notifications_title'),
                      subtitle: 'Active • 3 unread',
                      onTap: () => context.push(AppRoutes.notification),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4. Settings Group 2 - Security & Support
            Text(
              context.tr('security_legal'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            AnimatedEntry(
              delay: const Duration(milliseconds: 160),
              child: LiquidGlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _LiquidSettingsTile(
                      icon: CupertinoIcons.lock_shield_fill,
                      gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                      title: context.tr('privacy_security'),
                      subtitle: 'Face ID Biometrics Enabled',
                      onTap: () {},
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _GlassDivider(isDark: isDark),
                    _LiquidSettingsTile(
                      icon: CupertinoIcons.question_circle_fill,
                      gradientColors: const [Color(0xFF06B6D4), Color(0xFF22D3EE)],
                      title: context.tr('help_support'),
                      subtitle: '24/7 VIP Concierge Support',
                      onTap: () {},
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Liquid Glass Log Out Button
            AnimatedEntry(
              delay: const Duration(milliseconds: 200),
              child: PressableScale(
                onTap: () {
                  AppHaptics.medium();
                  context.go(AppRoutes.signIn);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.arrow_right_square,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidSettingsTile extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;

  const _LiquidSettingsTile({
    required this.icon,
    required this.gradientColors,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatPill extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _ProfileStatPill({
    required this.count,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String flag;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.flag,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primaryColor : (isDark ? const Color(0xFF30363D) : Colors.transparent),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? (isDark ? Colors.white : primaryColor)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ),
            if (selected)
              Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: primaryColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  final bool isDark;
  const _GlassDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFE2E8F0),
    );
  }
}
