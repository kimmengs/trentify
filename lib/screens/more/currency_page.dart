import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trentify/currency/app_currency.dart';
import 'package:trentify/currency/currency_controller.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class CurrencySettingsPage extends StatelessWidget {
  const CurrencySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final currencyCtl = context.watch<CurrencyController>();
    final currentCurrency = currencyCtl.currency;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('display_currency')),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              context.tr('select_currency'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            ...AppCurrency.values.map((cur) {
              final isSelected = currentCurrency == cur;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedEntry(
                  delay: Duration(milliseconds: 50 * cur.index),
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.read<CurrencyController>().setCurrency(cur);
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
                                cur.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
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
                                      cur.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        cur.symbol,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${cur.code} • ${cur.exchangeRateLabel}',
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
