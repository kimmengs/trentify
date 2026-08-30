import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/theme/theme_controller.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/app_badge_pill.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/liquid_glass_card.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class LuxuryColorOption {
  final String name;
  final Color primary;
  final Color secondary;
  final String hex;

  const LuxuryColorOption({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.hex,
  });
}

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool _hapticsEnabled = true;
  bool _glassBlurEnabled = true;

  static const List<LuxuryColorOption> _palettes = [
    LuxuryColorOption(
      name: 'Imperial Sapphire',
      primary: Color(0xFF4F77FE),
      secondary: Color(0xFF38BDF8),
      hex: '#4F77FE',
    ),
    LuxuryColorOption(
      name: 'Emerald Velvet',
      primary: Color(0xFF10B981),
      secondary: Color(0xFF34D399),
      hex: '#10B981',
    ),
    LuxuryColorOption(
      name: 'Rose Gold Couture',
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFF43F5E),
      hex: '#EC4899',
    ),
    LuxuryColorOption(
      name: 'Royal Amethyst',
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFA78BFA),
      hex: '#8B5CF6',
    ),
    LuxuryColorOption(
      name: 'Champagne Amber',
      primary: Color(0xFFF59E0B),
      secondary: Color(0xFFFBBF24),
      hex: '#F59E0B',
    ),
    LuxuryColorOption(
      name: 'Cyber Cyan',
      primary: Color(0xFF06B6D4),
      secondary: Color(0xFF22D3EE),
      hex: '#06B6D4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ctrl.seed;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          context.tr('theme_appearance'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: [
          // 1. Live Interactive Luxury Theme Preview Mockup
          AnimatedEntry(
            delay: const Duration(milliseconds: 40),
            child: LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: 24,
              borderColor: primaryColor.withValues(alpha: isDark ? 0.45 : 0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LIVE VISUAL PREVIEW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                      AppBadgePill(
                        label: ctrl.mode == AppThemeMode.dark
                            ? 'DARK OBSIDIAN'
                            : (ctrl.mode == AppThemeMode.light ? 'LIGHT STUDIO' : 'SYSTEM AUTO'),
                        variant: BadgeVariant.glass,
                        fontSize: 9,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Mini Device Screen Preview Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF090D14) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Mini App Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'WEBUY UAT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'VIP PREVIEW',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Mini Product Preview Tile
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withValues(alpha: 0.8),
                                    primaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.sparkles,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Haute Couture Blazer',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dynamic theme engine active',
                                    style: TextStyle(fontSize: 10, color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // 2. Appearance Theme Modes (3 Visual Selector Cards)
          Text(
            'COLOR SCHEME MODE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          AnimatedEntry(
            delay: const Duration(milliseconds: 80),
            child: Row(
              children: [
                // Light Mode
                Expanded(
                  child: _ThemeModeVisualCard(
                    title: 'Light',
                    subtitle: 'Studio White',
                    icon: CupertinoIcons.sun_max_fill,
                    iconColor: const Color(0xFFF59E0B),
                    isSelected: ctrl.mode == AppThemeMode.light,
                    previewColor: Colors.white,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    primaryColor: primaryColor,
                    onTap: () {
                      AppHaptics.selection();
                      ctrl.setMode(AppThemeMode.light);
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // Dark Mode
                Expanded(
                  child: _ThemeModeVisualCard(
                    title: 'Dark',
                    subtitle: 'Obsidian Noir',
                    icon: CupertinoIcons.moon_stars_fill,
                    iconColor: const Color(0xFF8B5CF6),
                    isSelected: ctrl.mode == AppThemeMode.dark,
                    previewColor: const Color(0xFF0F172A),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    primaryColor: primaryColor,
                    onTap: () {
                      AppHaptics.selection();
                      ctrl.setMode(AppThemeMode.dark);
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // System Mode
                Expanded(
                  child: _ThemeModeVisualCard(
                    title: 'System',
                    subtitle: 'Auto Match',
                    icon: CupertinoIcons.device_phone_portrait,
                    iconColor: const Color(0xFF3B82F6),
                    isSelected: ctrl.mode == AppThemeMode.system,
                    isDualTone: true,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    primaryColor: primaryColor,
                    onTap: () {
                      AppHaptics.selection();
                      ctrl.setMode(AppThemeMode.system);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Haute Couture Luxury Accent Palettes
          Text(
            context.tr('accent_color'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          AnimatedEntry(
            delay: const Duration(milliseconds: 120),
            child: LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 22,
              child: Column(
                children: [
                  for (int i = 0; i < _palettes.length; i++) ...[
                    _PaletteOptionRow(
                      palette: _palettes[i],
                      isSelected: ctrl.seed.toARGB32() == _palettes[i].primary.toARGB32(),
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () {
                        AppHaptics.selection();
                        ctrl.setSeed(_palettes[i].primary);
                      },
                    ),
                    if (i < _palettes.length - 1)
                      Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                        height: 16,
                      ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 4. Visual Effects & Engine Settings
          Text(
            'VISUAL ENGINE & MOTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          AnimatedEntry(
            delay: const Duration(milliseconds: 160),
            child: LiquidGlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 22,
              child: Column(
                children: [
                  _SettingsToggleRow(
                    icon: CupertinoIcons.sparkles,
                    title: 'Liquid Glass Reflections',
                    subtitle: 'Real-time GPU backdrop blur and specular rims',
                    value: _glassBlurEnabled,
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onChanged: (val) {
                      AppHaptics.selection();
                      setState(() => _glassBlurEnabled = val);
                    },
                  ),
                  Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                  _SettingsToggleRow(
                    icon: CupertinoIcons.hand_draw,
                    title: 'Tactile Haptic Feedback',
                    subtitle: 'Sensory vibration ticks during gestures',
                    value: _hapticsEnabled,
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onChanged: (val) {
                      AppHaptics.selection();
                      setState(() => _hapticsEnabled = val);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeVisualCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final Color? previewColor;
  final bool isDualTone;
  final Color borderColor;
  final Color textPrimary;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ThemeModeVisualCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    this.previewColor,
    this.isDualTone = false,
    required this.borderColor,
    required this.textPrimary,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.10)
              : (isDark ? const Color(0xFF161B22) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2.0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Preview Circle Indicator
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDualTone ? null : (previewColor ?? Colors.transparent),
                gradient: isDualTone
                    ? const LinearGradient(
                        colors: [Colors.white, Color(0xFF0F172A)],
                        stops: [0.5, 0.5],
                      )
                    : null,
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: isDualTone ? primaryColor : iconColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? (isDark ? Colors.white : primaryColor) : textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteOptionRow extends StatelessWidget {
  final LuxuryColorOption palette;
  final bool isSelected;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _PaletteOptionRow({
    required this.palette,
    required this.isSelected,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Color Swatch with Gradient
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.primary, palette.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: isSelected ? 0.55 : 0.25),
                    blurRadius: isSelected ? 12 : 6,
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),

            // Palette Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    palette.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? (isDark ? Colors.white : primaryColor) : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Luxury Accent • ${palette.hex}',
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
            ),

            if (isSelected)
              AppBadgePill(
                label: 'ACTIVE',
                variant: BadgeVariant.primary,
                fontSize: 9,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
