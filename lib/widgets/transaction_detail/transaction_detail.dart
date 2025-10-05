import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'transaction_detail_ios.dart';
import 'transaction_detail_android.dart';

/// Shared model for the transaction details
class TxDetail {
  final String counterpartyName;
  final String counterpartyEmail;
  final DateTime createdAt;
  final double amount;
  final double fee;
  final String txId;
  final String type;
  final String status;

  const TxDetail({
    required this.counterpartyName,
    required this.counterpartyEmail,
    required this.createdAt,
    required this.amount,
    required this.fee,
    required this.txId,
    this.type = 'Send Money',
    this.status = 'Completed',
  });

  double get subtotal => amount;
  double get netTotal => amount - fee;
}

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// Entry widget – decide which platform page to show
class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.detail});
  final TxDetail detail;

  @override
  Widget build(BuildContext context) => _isCupertino
      ? TransactionDetailIOS(detail: detail)
      : TransactionDetailAndroid(detail: detail);
}
