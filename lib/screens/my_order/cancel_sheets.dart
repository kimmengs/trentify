import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class CancelSheet extends StatelessWidget {
  const CancelSheet({
    super.key,
    required this.onConfirm,
    required this.onDismiss,
  });

  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Container(
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Warning Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: Color(0xFFEF4444),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Cancel This Order?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Are you sure you want to cancel? Any processed payments will be refunded to your original payment method within 1-3 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onDismiss();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Keep Order',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      onConfirm();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Yes, Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CancelSuccessSheet extends StatefulWidget {
  const CancelSuccessSheet({super.key});

  @override
  State<CancelSuccessSheet> createState() => _CancelSuccessSheetState();
}

class _CancelSuccessSheetState extends State<CancelSuccessSheet> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF10B981), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Order Canceled & Refund Initiated',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
