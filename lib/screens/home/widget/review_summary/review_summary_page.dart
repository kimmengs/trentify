import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/screens/home/widget/review_summary/review_summary_android.dart';
import 'package:trentify/screens/home/widget/review_summary/review_summary_ios.dart';
import 'package:trentify/model/scanned_payee.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class ReviewSummaryPage extends StatelessWidget {
  const ReviewSummaryPage({
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
    return _isCupertino
        ? ReviewSummaryCupertino(
            payee: payee,
            amount: amount,
            tax: tax,
            notes: notes,
          )
        : ReviewSummaryMaterial(
            payee: payee,
            amount: amount,
            tax: tax,
            notes: notes,
          );
  }
}
