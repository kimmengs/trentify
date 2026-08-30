import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_settlement.dart';

class FeeCalculatorCard extends StatefulWidget {
  const FeeCalculatorCard({super.key});

  @override
  State<FeeCalculatorCard> createState() => _FeeCalculatorCardState();
}

class _FeeCalculatorCardState extends State<FeeCalculatorCard> {
  double _sampleSale = 200.0;
  final _ctl = TextEditingController(text: '200');

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _onSaleChanged(String text) {
    final val = double.tryParse(text) ?? 0.0;
    setState(() {
      _sampleSale = val;
    });
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

    final breakdown = FeeBreakdown(grossAmount: _sampleSale);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(CupertinoIcons.percent, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('fee_calculator'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      context.tr('fee_calc_hint'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '92.5% NET',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Sale Input
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('simulate_sale_amount'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
              Container(
                width: 120,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _ctl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _onSaleChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Progress Proportional Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 925,
                    child: Container(color: const Color(0xFF10B981)),
                  ),
                  Expanded(
                    flex: 50,
                    child: Container(color: primaryColor),
                  ),
                  Expanded(
                    flex: 25,
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Line Item Breakdown Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              children: [
                _feeRow(
                  label: context.tr('fee_platform_title'),
                  rate: '5.0%',
                  amount: '-\$${breakdown.platformFee.toStringAsFixed(2)}',
                  color: primaryColor,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: 8),
                _feeRow(
                  label: context.tr('fee_payment_title'),
                  rate: '2.5%',
                  amount: '-\$${breakdown.paymentFee.toStringAsFixed(2)}',
                  color: const Color(0xFFF59E0B),
                  textSecondary: textSecondary,
                ),
                Divider(height: 16, color: borderColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('you_keep'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${breakdown.netEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow({
    required String label,
    required String rate,
    required String amount,
    required Color color,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$label ($rate)',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
