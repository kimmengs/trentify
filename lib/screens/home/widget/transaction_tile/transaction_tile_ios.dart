import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trentify/model/recent_trx.dart';
import 'package:trentify/widgets/transaction_detail/transaction_detail.dart';

class TransactionTileIOS extends StatelessWidget {
  const TransactionTileIOS({super.key, required this.tx});
  final RecentTrx tx;

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$');
    final isCredit = tx.amount >= 0;
    final color = isCredit ? const Color(0xFF2DA54E) : const Color(0xFFEC4D4D);

    final content = Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              borderRadius: BorderRadius.circular(50),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.person_fill,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                if (tx.subtitle.isNotEmpty)
                  Text(
                    tx.subtitle,
                    style: TextStyle(
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                      fontSize: 12,
                    ),
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
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _openDetail(context),
      child: content,
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
