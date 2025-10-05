import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trentify/model/recent_trx.dart';
import 'package:trentify/widgets/transaction_detail/transaction_detail.dart';

class TransactionTileAndroid extends StatelessWidget {
  const TransactionTileAndroid({super.key, required this.tx});
  final RecentTrx tx;

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$');
    final isCredit = tx.amount >= 0;
    final color = isCredit ? Colors.green.shade700 : Colors.red.shade600;

    return InkWell(
      onTap: () => _openDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (tx.subtitle.isNotEmpty)
                    Text(
                      tx.subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              (isCredit ? '+ ' : '- ') + f.format(tx.amount.abs()),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final detail = TxDetail(
      counterpartyName: tx.name,
      counterpartyEmail: 'marvin@domain.com',
      createdAt: DateTime.now(),
      amount: tx.amount.abs(),
      fee: 15.50,
      txId: '72L9APTHKC8',
      type: tx.subtitle.isEmpty ? 'Send Money' : tx.subtitle,
      status: tx.status,
    );
    context.push('/transaction-detail', extra: detail);
  }
}
