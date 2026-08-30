import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  static const List<LanguageOption> options = [
    LanguageOption(
      code: 'en',
      name: 'English (US)',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'km',
      name: 'Khmer (Cambodia)',
      nativeName: 'ភាសាខ្មែរ',
      flag: '🇰🇭',
    ),
    LanguageOption(
      code: 'vi',
      name: 'Vietnamese (Vietnam)',
      nativeName: 'Tiếng Việt',
      flag: '🇻🇳',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final localeController = context.watch<LocaleController>();
    final currentCode = localeController.languageCode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('language_region')),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              context.tr('select_language'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            ...options.map((opt) {
              final isSelected = currentCode == opt.code;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedEntry(
                  delay: const Duration(milliseconds: 50),
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.read<LocaleController>().setLanguageCode(opt.code);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0D1117)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                opt.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.nativeName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.checkmark_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
