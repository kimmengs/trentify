import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_settlement.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/screens/seller/payouts/widgets/fee_calculator_card.dart';
import 'package:trentify/screens/seller/payouts/widgets/request_payout_sheet.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SellerPayoutsPage extends StatefulWidget {
  const SellerPayoutsPage({super.key});

  @override
  State<SellerPayoutsPage> createState() => _SellerPayoutsPageState();
}

class _SellerPayoutsPageState extends State<SellerPayoutsPage> {
  final _seller = SellerProvider.instance;
  int _selectedFilter = 0; // 0: All, 1: Available, 2: In Escrow, 3: Paid Out

  @override
  void initState() {
    super.initState();
    _seller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _seller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _openWithdrawSheet() async {
    HapticFeedback.mediumImpact();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RequestPayoutSheet(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('payout_success_desc'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  List<SellerSettlement> get _filteredSettlements {
    switch (_selectedFilter) {
      case 1:
        return _seller.settlements.where((s) => s.status == SettlementStatus.available).toList();
      case 2:
        return _seller.settlements.where((s) => s.status == SettlementStatus.inEscrow).toList();
      case 3:
        return _seller.settlements.where((s) => s.status == SettlementStatus.paidOut).toList();
      default:
        return _seller.settlements;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final available = _seller.availableBalance;
    final inEscrow = _seller.escrowBalance;
    final totalWithdrawn = _seller.totalWithdrawn;
    final settlements = _filteredSettlements;

    final filterTabs = [
      context.tr('tab_all_trans'),
      context.tr('tab_available'),
      context.tr('tab_escrow'),
      context.tr('tab_paid_out'),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('payouts_settlements')),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showEscrowInfoDialog(context, isDark, primaryColor, textPrimary, textSecondary);
            },
            icon: const Icon(CupertinoIcons.info_circle, size: 22),
            tooltip: 'Escrow & Fee Policy',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            // Hero Balance Card
            _buildHeroBalanceCard(
              context: context,
              available: available,
              inEscrow: inEscrow,
              totalWithdrawn: totalWithdrawn,
              primaryColor: primaryColor,
              cardBg: cardBg,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Linked Bank Account Card
            _buildBankAccountCard(
              context: context,
              profile: _seller.profile,
              cardBg: cardBg,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 20),

            // Interactive Fee & Commission Calculator
            const FeeCalculatorCard(),

            const SizedBox(height: 24),

            // Statement Ledger Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('settlement_statements'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '${settlements.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Tabs
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filterTabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final isSel = _selectedFilter == i;
                  return PressableScale(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? primaryColor : cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSel ? primaryColor : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filterTabs[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Statement List
            if (settlements.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.doc_text, size: 40, color: textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'No transactions found in this filter',
                        style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: settlements.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = settlements[i];
                  return AnimatedEntry(
                    delay: Duration(milliseconds: i * 30),
                    child: _buildSettlementTile(
                      context: context,
                      settlement: s,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Recent Withdrawals History
            if (_seller.payouts.isNotEmpty) ...[
              Text(
                'RECENT WITHDRAWALS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              ..._seller.payouts.map((p) => _buildPayoutRecordTile(
                    p,
                    cardBg,
                    borderColor,
                    textPrimary,
                    textSecondary,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBalanceCard({
    required BuildContext context,
    required double available,
    required double inEscrow,
    required double totalWithdrawn,
    required Color primaryColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF161B22), const Color(0xFF0F141C)]
              : [Colors.white, const Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('available_for_payout'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.checkmark_shield_fill, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'CLEARED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Available Amount & Withdraw CTA Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$${available.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PressableScale(
                onTap: available > 0 ? _openWithdrawSheet : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: available > 0 ? primaryColor : textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: available > 0
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.arrow_up_right_circle_fill, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('withdraw_funds'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 14),

          // Sub-metrics: In Escrow & Total Paid Out
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.tr('in_escrow_clearance'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(CupertinoIcons.lock_fill, size: 10, color: textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${inEscrow.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: borderColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('total_withdrawn'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalWithdrawn.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard({
    required BuildContext context,
    required dynamic profile,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3D64),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'ABA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.payoutBankName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PRIMARY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.payoutAccountHolder} • ${profile.payoutAccountNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(CupertinoIcons.chevron_right, size: 16, color: textSecondary),
        ],
      ),
    );
  }

  Widget _buildSettlementTile({
    required BuildContext context,
    required SellerSettlement settlement,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required bool isDark,
  }) {
    Color badgeBg;
    Color badgeColor;
    String badgeText;

    switch (settlement.status) {
      case SettlementStatus.available:
        badgeBg = const Color(0xFF10B981).withValues(alpha: 0.12);
        badgeColor = const Color(0xFF10B981);
        badgeText = 'AVAILABLE';
        break;
      case SettlementStatus.inEscrow:
        badgeBg = const Color(0xFF3B82F6).withValues(alpha: 0.12);
        badgeColor = const Color(0xFF3B82F6);
        badgeText = 'IN ESCROW';
        break;
      case SettlementStatus.paidOut:
        badgeBg = isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0);
        badgeColor = textSecondary;
        badgeText = 'PAID OUT';
        break;
    }

    final dateStr = DateFormat('MMM d, h:mm a').format(settlement.orderDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    settlement.orderId,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• $dateStr',
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Items summary & Buyer
          Text(
            '${settlement.customerName} — ${settlement.itemsSummary}',
            style: TextStyle(fontSize: 12, color: textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Fee line items
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _feePill('Gross', '\$${settlement.grossAmount.toStringAsFixed(2)}', textSecondary),
                _feePill('Fee (5%)', '-\$${settlement.platformFee.toStringAsFixed(2)}', primaryColor),
                _feePill('Gateway (2.5%)', '-\$${settlement.paymentProcessingFee.toStringAsFixed(2)}', const Color(0xFFF59E0B)),
                _feePill('Net', '\$${settlement.netAmount.toStringAsFixed(2)}', const Color(0xFF10B981), isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feePill(String title, String val, Color valColor, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Color(0xFF8B949E)),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutRecordTile(
    SellerPayoutRecord p,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final dateStr = DateFormat('MMM d, yyyy').format(p.requestedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.arrow_down_left, color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.destinationBank} (${p.destinationAccount})',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                  Text(
                    '${p.referenceCode} • $dateStr',
                    style: TextStyle(fontSize: 10, color: textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '-\$${p.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  void _showEscrowInfoDialog(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Settlement & Fee Policy'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            '1. Escrow Protection: Funds for active and shipped orders are held safely in escrow until the customer receives the delivery.\n\n'
            '2. Instant Release: Upon delivery confirmation, funds are automatically cleared after platform & payment gateway fee deductions (92.5% Net Payout).\n\n'
            '3. Fast Withdrawals: Request payouts anytime to your linked ABA Bank or Bakong account with 0 withdrawal fees.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Understood'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
