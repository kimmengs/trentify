enum SettlementStatus {
  inEscrow, // Held while order is pending/in-transit
  available, // Cleared after delivery confirmation, ready for payout
  paidOut, // Withdrawn to seller's bank account
}

enum PayoutStatus {
  processing,
  completed,
  failed,
}

class FeeBreakdown {
  final double grossAmount;
  final double platformFeeRate; // e.g. 0.05 (5%)
  final double paymentFeeRate; // e.g. 0.025 (2.5%)
  final double fixedProcessingFee; // e.g. $0.30

  const FeeBreakdown({
    required this.grossAmount,
    this.platformFeeRate = 0.05,
    this.paymentFeeRate = 0.025,
    this.fixedProcessingFee = 0.00,
  });

  double get platformFee => grossAmount * platformFeeRate;
  double get paymentFee => grossAmount * paymentFeeRate + fixedProcessingFee;
  double get totalFees => platformFee + paymentFee;
  double get netEarnings => (grossAmount - totalFees).clamp(0.0, double.infinity);
  double get netRatePercent => ((1.0 - (platformFeeRate + paymentFeeRate)) * 100);
}

class SellerSettlement {
  final String id;
  final String orderId;
  final String customerName;
  final String itemsSummary;
  final DateTime orderDate;
  final DateTime? clearedDate;
  final double grossAmount;
  final double platformFee;
  final double paymentProcessingFee;
  final double netAmount;
  final SettlementStatus status;
  final String? payoutBatchId;

  const SellerSettlement({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.itemsSummary,
    required this.orderDate,
    this.clearedDate,
    required this.grossAmount,
    required this.platformFee,
    required this.paymentProcessingFee,
    required this.netAmount,
    required this.status,
    this.payoutBatchId,
  });

  SellerSettlement copyWith({
    SettlementStatus? status,
    DateTime? clearedDate,
    String? payoutBatchId,
    double? grossAmount,
    double? platformFee,
    double? paymentProcessingFee,
    double? netAmount,
  }) {
    return SellerSettlement(
      id: id,
      orderId: orderId,
      customerName: customerName,
      itemsSummary: itemsSummary,
      orderDate: orderDate,
      clearedDate: clearedDate ?? this.clearedDate,
      grossAmount: grossAmount ?? this.grossAmount,
      platformFee: platformFee ?? this.platformFee,
      paymentProcessingFee: paymentProcessingFee ?? this.paymentProcessingFee,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      payoutBatchId: payoutBatchId ?? this.payoutBatchId,
    );
  }
}

class SellerPayoutRecord {
  final String id;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final double amount;
  final String destinationBank;
  final String destinationAccount;
  final String referenceCode;
  final PayoutStatus status;
  final String transferSpeed; // 'Instant' or 'Standard (T+1)'

  const SellerPayoutRecord({
    required this.id,
    required this.requestedAt,
    this.completedAt,
    required this.amount,
    required this.destinationBank,
    required this.destinationAccount,
    required this.referenceCode,
    required this.status,
    this.transferSpeed = 'Instant',
  });
}
