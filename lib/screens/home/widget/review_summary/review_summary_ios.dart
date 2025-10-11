import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trentify/model/scanned_payee.dart';

class ReviewSummaryCupertino extends StatelessWidget {
  const ReviewSummaryCupertino({
    super.key,
    required this.payee,
    required this.amount,
    required this.tax,
    required this.notes,
  });

  final ScannedPayee payee;
  final double amount;
  final double tax;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final total = amount - tax;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Review Summary'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            // ---- Avatar and Name ----
            Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3D4FF),
                    borderRadius: BorderRadius.circular(43),
                    image: payee.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(payee.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: payee.avatarUrl == null
                      ? const Icon(
                          CupertinoIcons.person_fill,
                          color: Colors.white,
                          size: 44,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  payee.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  payee.email,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: CupertinoColors.separator),
            const SizedBox(height: 24),

            // ---- Amount / Tax / Total ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Amount (USD)', value: f.format(amount)),
                  const SizedBox(height: 12),
                  _SummaryRow(label: 'fee', value: '- ${f.format(0.00)}'),
                  const Divider(height: 24, color: CupertinoColors.separator),
                  _SummaryRow(
                    label: 'Total',
                    value: f.format(total),
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ---- Payment Type ----
            const Text(
              'Payment Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'For goods and services',
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ---- Notes ----
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              notes.isEmpty ? '—' : notes,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 36),

            // ---- Confirm Button ----
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(30),
              onPressed: () async {
                // await callYourPaymentAPI(...);

                if (!context.mounted) return;
                context.go(
                  '/success',
                  extra: payee.name,
                ); // clears stack to /success, then OK → '/'
              },
              child: const Text('Confirm & Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 18,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
