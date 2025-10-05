// success_payment_page.dart
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:trentify/screens/home/widget/successful_payment/success_payment_android.dart';
import 'package:trentify/screens/home/widget/successful_payment/success_payment_ios.dart';

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class SuccessPaymentPage extends StatelessWidget {
  const SuccessPaymentPage({super.key, required this.payeeName});

  final String payeeName;

  @override
  Widget build(BuildContext context) {
    return _isCupertino
        ? SuccessPaymentCupertino(payeeName: payeeName)
        : SuccessPaymentMaterial(payeeName: payeeName);
  }
}
