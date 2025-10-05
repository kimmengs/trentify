import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/scanned_payee.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:trentify/screens/home/widget/transfer_page/send_money_android.dart';
import 'package:trentify/screens/home/widget/transfer_page/send_money_ios.dart';

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class SendMoneyPage extends StatelessWidget {
  const SendMoneyPage({super.key, required this.payee});
  final ScannedPayee payee;

  @override
  Widget build(BuildContext context) {
    return _isCupertino
        ? SendMoneyCupertino(payee: payee)
        : SendMoneyMaterial(payee: payee);
  }
}
