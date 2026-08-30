import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class RequestPayoutSheet extends StatefulWidget {
  const RequestPayoutSheet({super.key});

  @override
  State<RequestPayoutSheet> createState() => _RequestPayoutSheetState();
}

class _RequestPayoutSheetState extends State<RequestPayoutSheet> {
  final _amountCtl = TextEditingController();
  String _selectedSpeed = 'Instant'; // 'Instant' or 'Standard'
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final seller = SellerProvider.instance;
    final defaultAmount = (seller.availableBalance * 0.5).clamp(0.0, seller.availableBalance);
    _amountCtl.text = defaultAmount > 0 ? defaultAmount.toStringAsFixed(2) : '0.00';
  }

  @override
  void dispose() {
    _amountCtl.dispose();
    super.dispose();
  }

  void _setAmount(double val) {
    HapticFeedback.selectionClick();
    setState(() {
      _amountCtl.text = val.toStringAsFixed(2);
    });
  }

  void _submit() async {
    final seller = SellerProvider.instance;
    final amount = double.tryParse(_amountCtl.text.trim()) ?? 0.0;

    if (amount <= 0 || amount > seller.availableBalance) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text(
            amount <= 0
                ? 'Please enter a valid withdrawal amount.'
                : 'Insufficient available balance (\$${seller.availableBalance.toStringAsFixed(2)} max).',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    final success = seller.requestPayout(
      amount: amount,
      destinationBank: seller.profile.payoutBankName,
      destinationAccount: seller.profile.payoutAccountNumber,
      speed: _selectedSpeed == 'Instant' ? 'Instant Transfer' : 'Standard Transfer (T+1)',
    );

    if (mounted) {
      setState(() => _submitting = false);
      Navigator.of(context).pop(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final seller = SellerProvider.instance;
    final available = seller.availableBalance;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('withdraw_modal_title'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Available: \$${available.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(CupertinoIcons.xmark_circle_fill, color: textSecondary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amount Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _amountCtl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                    ),
                  ),
                ),
                PressableScale(
                  onTap: () => _setAmount(available),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'MAX',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [100.0, 250.0, 500.0, 1000.0].map((preset) {
              final enabled = preset <= available;
              return GestureDetector(
                onTap: enabled ? () => _setAmount(preset) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: enabled
                        ? (isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9))
                        : (isDark ? const Color(0xFF161B22).withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Text(
                    '\$${preset.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: enabled ? textPrimary : textSecondary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Destination Bank Card
          Text(
            context.tr('payout_account'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3D64),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'ABA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.profile.payoutBankName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${seller.profile.payoutAccountHolder} • ${seller.profile.payoutAccountNumber}',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.checkmark_circle_fill, color: primaryColor, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Speed Selection
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSpeed = 'Instant'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSpeed == 'Instant'
                          ? primaryColor.withValues(alpha: 0.1)
                          : cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedSpeed == 'Instant' ? primaryColor : borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.bolt_fill, size: 14, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Instant',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Within 5 mins • Fee \$0',
                          style: TextStyle(fontSize: 10, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSpeed = 'Standard'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSpeed == 'Standard'
                          ? primaryColor.withValues(alpha: 0.1)
                          : cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedSpeed == 'Standard' ? primaryColor : borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.calendar, size: 14, color: textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Standard',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Next business day',
                          style: TextStyle(fontSize: 10, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Confirm CTA Button
          PressableScale(
            onTap: _submitting ? null : _submit,
            child: Container(
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.arrow_right_circle_fill, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('confirm_payout'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
