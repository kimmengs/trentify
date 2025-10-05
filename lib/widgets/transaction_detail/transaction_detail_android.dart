import 'package:flutter/material.dart';
import 'package:trentify/widgets/transaction_detail/transaction_detail.dart';
import 'package:intl/intl.dart';

class TransactionDetailAndroid extends StatelessWidget {
  const TransactionDetailAndroid({super.key, required this.detail});
  final TxDetail detail;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final date = DateFormat('d MMM, y  •  hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.counterpartyName),
        actions: const [Icon(Icons.more_vert)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  money.format(detail.amount),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${detail.type}  •  ${detail.status}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('To', detail.counterpartyName, bold: true),
                  _kv('Email', detail.counterpartyEmail),
                  _kv('Date', date.format(detail.createdAt), bold: true),
                  _kv('Amount', money.format(detail.amount), bold: true),
                  _kv('Transaction ID', detail.txId, bold: true),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Subtotal', money.format(detail.subtotal), bold: true),
                  _kv('Fees', '- ${money.format(detail.fee)}'),
                  const Divider(),
                  _kv('Net Total', money.format(detail.netTotal), bold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
