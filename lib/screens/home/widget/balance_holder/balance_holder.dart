import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:trentify/screens/home/widget/balance_holder/balance_holder_android.dart';
import 'package:trentify/screens/home/widget/balance_holder/balance_holder_ios.dart';

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class BalanceHeader extends StatelessWidget {
  const BalanceHeader({
    super.key,
    required this.balance,
    this.onScan,
    this.onBell,
  });

  final double balance;
  final VoidCallback? onScan;
  final VoidCallback? onBell;

  @override
  Widget build(BuildContext context) => _isCupertino
      ? BalanceHeaderCupertino(balance: balance, onScan: onScan, onBell: onBell)
      : BalanceHeaderAndroid(balance: balance, onScan: onScan, onBell: onBell);
}
