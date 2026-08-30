import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_order.dart';
import 'package:trentify/model/seller_settlement.dart';
import 'package:trentify/provider/seller_provider.dart';

void main() {
  group('Marketplace Fee & Settlement Financial Logic Tests', () {
    test('FeeBreakdown calculates 5% platform fee and 2.5% payment fee accurately', () {
      const breakdown = FeeBreakdown(grossAmount: 200.0);

      expect(breakdown.grossAmount, 200.0);
      expect(breakdown.platformFee, 10.00); // 5% of 200
      expect(breakdown.paymentFee, 5.00); // 2.5% of 200
      expect(breakdown.totalFees, 15.00); // 7.5% total
      expect(breakdown.netEarnings, 185.00); // 92.5% net
      expect(breakdown.netRatePercent, 92.5);
    });

    test('FeeBreakdown handles custom or zero amounts gracefully', () {
      const zeroBreakdown = FeeBreakdown(grossAmount: 0.0);
      expect(zeroBreakdown.platformFee, 0.0);
      expect(zeroBreakdown.paymentFee, 0.0);
      expect(zeroBreakdown.netEarnings, 0.0);

      const highBreakdown = FeeBreakdown(grossAmount: 1000.0);
      expect(highBreakdown.platformFee, 50.0);
      expect(highBreakdown.paymentFee, 25.0);
      expect(highBreakdown.netEarnings, 925.0);
    });
  });

  group('SellerProvider Settlement & Payout Engine Tests', () {
    late SellerProvider provider;

    setUp(() {
      provider = SellerProvider.instance;
    });

    test('Initializes with active settlements in both Available and Escrow states', () {
      expect(provider.settlements, isNotEmpty);
      expect(provider.availableBalance, isNonZero);
      expect(provider.escrowBalance, isNonZero);
      expect(provider.lifetimeGrossRevenue, isPositive);
      expect(provider.lifetimeNetEarnings, isPositive);
    });

    test('Delivering an in-escrow order unlocks funds into available balance', () {
      final initialAvailable = provider.availableBalance;
      final initialEscrow = provider.escrowBalance;

      // Find an in-escrow order (e.g. ord_101 or ord_102)
      final escrowSettlement = provider.settlements.firstWhere(
        (s) => s.status == SettlementStatus.inEscrow,
      );

      // Update order status to delivered
      provider.updateOrderStatus(escrowSettlement.orderId, SellerOrderStatus.delivered);

      expect(provider.availableBalance, greaterThan(initialAvailable));
      expect(provider.escrowBalance, lessThan(initialEscrow));
    });

    test('Payout withdrawal fails when amount exceeds available balance or is negative', () {
      final available = provider.availableBalance;

      final overdraw = provider.requestPayout(
        amount: available + 500.0,
        destinationBank: 'ABA Bank',
        destinationAccount: '001 849 204',
      );
      expect(overdraw, isFalse);

      final zeroWithdraw = provider.requestPayout(
        amount: 0.0,
        destinationBank: 'ABA Bank',
        destinationAccount: '001 849 204',
      );
      expect(zeroWithdraw, isFalse);
    });

    test('Payout withdrawal succeeds for valid amount and reduces available balance', () {
      final initialAvailable = provider.availableBalance;
      final withdrawAmount = (initialAvailable * 0.5).roundToDouble();

      final success = provider.requestPayout(
        amount: withdrawAmount,
        destinationBank: 'ABA Bank',
        destinationAccount: '001 849 204',
        speed: 'Instant',
      );

      expect(success, isTrue);
      expect(provider.availableBalance, closeTo(initialAvailable - withdrawAmount, 0.01));
      expect(provider.payouts.first.amount, withdrawAmount);
      expect(provider.payouts.first.status, PayoutStatus.completed);
    });
  });

  group('Settlement & Payout 3-Language Localization Tests', () {
    test('English settlement terms resolve correctly', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.translate('payouts_settlements'), 'Payouts & Settlements');
      expect(loc.translate('available_for_payout'), 'Available for Payout');
      expect(loc.translate('withdraw_funds'), 'Withdraw Funds');
      expect(loc.translate('fee_calculator'), 'Interactive Fee Calculator');
      expect(loc.translate('confirm_payout'), 'Confirm Withdrawal');
    });

    test('Khmer settlement terms resolve in natural Khmer script', () {
      final loc = AppLocalizations(const Locale('km'));
      expect(loc.translate('payouts_settlements'), 'ការដកប្រាក់ និងទូទាត់ចំណូល');
      expect(loc.translate('available_for_payout'), 'សមតុល្យដែលអាចដកបាន');
      expect(loc.translate('withdraw_funds'), 'ដកប្រាក់ឥឡូវនេះ');
      expect(loc.translate('fee_calculator'), 'ម៉ាស៊ីនគណនាកម្រៃសេវា');
      expect(loc.translate('confirm_payout'), 'បញ្ជាក់ការដកប្រាក់');
    });

    test('Vietnamese settlement terms resolve in natural Vietnamese script', () {
      final loc = AppLocalizations(const Locale('vi'));
      expect(loc.translate('payouts_settlements'), 'Rút tiền & Quyết toán doanh thu');
      expect(loc.translate('available_for_payout'), 'Số dư khả dụng có thể rút');
      expect(loc.translate('withdraw_funds'), 'Rút tiền ngay');
      expect(loc.translate('fee_calculator'), 'Công cụ tính phí & Doanh thu ròng');
      expect(loc.translate('confirm_payout'), 'Xác nhận rút tiền');
    });
  });
}
