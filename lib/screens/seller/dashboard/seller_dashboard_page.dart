import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_order.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/screens/seller/seller_shell.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final _seller = SellerProvider.instance;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final currency = NumberFormat.currency(symbol: '\$');

    final profile = _seller.profile;
    final pendingOrders = _seller.orders
        .where((o) => o.status == SellerOrderStatus.pending)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // Top Header: Shop Info & Switch to Buyer Mode
            Row(
              children: [
                // Store Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(profile.logoUrl),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: primaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Store Name & Handle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            profile.handle,
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.star_rounded, size: 14, color: const Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            '${profile.rating}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Buyer Mode Switch Button
                PressableScale(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.go(AppRoutes.home);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.bag_fill, size: 14, color: primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('buyer_view'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Revenue Hero Card
            AnimatedEntry(
              delay: const Duration(milliseconds: 50),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
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
                          context.tr('gross_revenue'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.arrow_up_right, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '+18.4% this mo.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currency.format(_seller.totalRevenue),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _heroStat(context.tr('today_sales'), '\$1,240.50')),
                          Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.2)),
                          Expanded(child: _heroStat(context.tr('items_sold'), '${profile.totalSales}')),
                          Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.2)),
                          Expanded(child: _heroStat(context.tr('followers'), '${profile.followerCount}')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Payout & Settlement Quick Balance Banner
            PressableScale(
              onTap: () => context.push(AppRoutes.sellerPayouts),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: Color(0xFF10B981), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  context.tr('available_for_payout'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '92.5%',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${_seller.availableBalance.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textPrimary, letterSpacing: -0.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('withdraw_funds'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          const Icon(CupertinoIcons.chevron_right, size: 10, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Metrics Grid (Orders & Stock Alerts)
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: context.tr('pending_orders'),
                    value: '${_seller.pendingOrdersCount}',
                    subtitle: 'Requires Fulfillment',
                    icon: CupertinoIcons.cube_box_fill,
                    iconColor: const Color(0xFFF59E0B),
                    badgeColor: const Color(0xFFF59E0B),
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => SellerShell.navigateTo(context, 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: context.tr('low_stock_alerts'),
                    value: '${_seller.lowStockCount}',
                    subtitle: 'SKUs <= 5 items',
                    icon: CupertinoIcons.exclamationmark_triangle_fill,
                    iconColor: const Color(0xFFEF4444),
                    badgeColor: const Color(0xFFEF4444),
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => SellerShell.navigateTo(context, 3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('quick_actions'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: CupertinoIcons.plus_circle_fill,
                    label: context.tr('add_product'),
                    primaryColor: primaryColor,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    onTap: () => context.push(AppRoutes.sellerNewProduct),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionButton(
                    icon: CupertinoIcons.doc_text_fill,
                    label: context.tr('nav_orders'),
                    primaryColor: primaryColor,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    onTap: () => SellerShell.navigateTo(context, 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionButton(
                    icon: CupertinoIcons.slider_horizontal_3,
                    label: context.tr('nav_stock'),
                    primaryColor: primaryColor,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    onTap: () => SellerShell.navigateTo(context, 3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionButton(
                    icon: CupertinoIcons.gear_alt_fill,
                    label: context.tr('account_settings'),
                    primaryColor: primaryColor,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    onTap: () => SellerShell.navigateTo(context, 4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Urgent Orders Section
            if (pendingOrders.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('orders_to_ship'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${pendingOrders.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => SellerShell.navigateTo(context, 1),
                    child: Text(
                      context.tr('view_all'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...pendingOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PendingOrderTile(
                    order: order,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Top Performing Garments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOP PERFORMING PRODUCTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => SellerShell.navigateTo(context, 2),
                  child: Text(
                    'Manage Catalog',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._seller.products.take(3).map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopProductTile(
                  product: p,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryColor: primaryColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primaryColor;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.primaryColor,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingOrderTile extends StatelessWidget {
  final SellerOrder order;
  final Color cardBg;
  final Color borderColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;

  const _PendingOrderTile({
    required this.order,
    required this.cardBg,
    required this.borderColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(order.customerAvatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      order.orderNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currency.format(order.total),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${order.items.length} item(s): ${order.items.map((e) => "${e.title} (${e.size}/${e.color})").join(", ")}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PressableScale(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  SellerProvider.instance.updateOrderStatus(
                    order.id,
                    SellerOrderStatus.processing,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.checkmark_alt, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('accept_order'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final dynamic product;
  final Color cardBg;
  final Color borderColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;

  const _TopProductTile({
    required this.product,
    required this.cardBg,
    required this.borderColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.images.first,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${product.salesCount} sold',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.stock <= 5
                  ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                  : const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${product.stock} in stock',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: product.stock <= 5
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
