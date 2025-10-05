import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:trentify/model/recent_trx.dart';

import 'transaction_tile_ios.dart';
import 'transaction_tile_android.dart';

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// Entry point – use this widget in your lists
class TransactionTileWidget extends StatelessWidget {
  const TransactionTileWidget({super.key, required this.tx});
  final RecentTrx tx;

  @override
  Widget build(BuildContext context) => _isCupertino
      ? TransactionTileIOS(tx: tx)
      : TransactionTileAndroid(tx: tx);
}
