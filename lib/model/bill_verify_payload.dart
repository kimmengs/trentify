import 'package:trentify/model/bill_category.dart';

class BillVerifyPayload {
  final BillCategory category;
  final String customerId;
  final String customerName;
  final String? avatarUrl;
  final double amount; // bill amount
  final bool isPaid; // false = Unpaid badge

  const BillVerifyPayload({
    required this.category,
    required this.customerId,
    required this.customerName,
    required this.amount,
    this.avatarUrl,
    this.isPaid = false,
  });
}
