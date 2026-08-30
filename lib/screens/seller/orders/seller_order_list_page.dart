import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_order.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SellerOrderListPage extends StatefulWidget {
  const SellerOrderListPage({super.key});

  @override
  State<SellerOrderListPage> createState() => _SellerOrderListPageState();
}

class _SellerOrderListPageState extends State<SellerOrderListPage> {
  final _seller = SellerProvider.instance;
  int _selectedStatusIndex = 0; // 0: All, 1: Pending, 2: Processing, 3: Shipped, 4: Delivered, 5: Cancelled

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

  List<SellerOrder> get _filteredOrders {
    if (_selectedStatusIndex == 0) return _seller.orders;

    final targetStatus = switch (_selectedStatusIndex) {
      1 => SellerOrderStatus.pending,
      2 => SellerOrderStatus.processing,
      3 => SellerOrderStatus.shipped,
      4 => SellerOrderStatus.delivered,
      5 => SellerOrderStatus.cancelled,
      _ => null,
    };

    if (targetStatus == null) return _seller.orders;
    return _seller.orders.where((o) => o.status == targetStatus).toList();
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

    final statusFilters = [
      context.tr('order_status_all'),
      context.tr('order_status_pending'),
      context.tr('order_status_processing'),
      context.tr('order_status_shipped'),
      context.tr('order_status_delivered'),
      context.tr('order_status_cancelled'),
    ];

    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('orders_to_ship')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Tab Filter Bar
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: statusFilters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedStatusIndex == index;
                  final count = _getCountForStatus(index);

                  return PressableScale(
                    onTap: () => setState(() => _selectedStatusIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              statusFilters[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : textSecondary,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Order List
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.doc_plaintext, size: 48, color: textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'No orders in this status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return AnimatedEntry(
                          delay: Duration(milliseconds: index * 30),
                          child: _SellerOrderCard(
                            order: order,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            primaryColor: primaryColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onAccept: () {
                              HapticFeedback.mediumImpact();
                              _seller.updateOrderStatus(order.id, SellerOrderStatus.processing);
                            },
                            onShip: () => _showFulfillModal(order),
                            onDeliver: () {
                              HapticFeedback.mediumImpact();
                              _seller.updateOrderStatus(order.id, SellerOrderStatus.delivered);
                            },
                            onCancel: () {
                              _confirmCancel(order);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCountForStatus(int index) {
    if (index == 0) return _seller.orders.length;
    final status = switch (index) {
      1 => SellerOrderStatus.pending,
      2 => SellerOrderStatus.processing,
      3 => SellerOrderStatus.shipped,
      4 => SellerOrderStatus.delivered,
      5 => SellerOrderStatus.cancelled,
      _ => null,
    };
    return _seller.orders.where((o) => o.status == status).length;
  }

  void _showFulfillModal(SellerOrder order) {
    final carrierCtl = TextEditingController(text: 'DHL Express');
    final trackingCtl = TextEditingController(text: 'TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
        final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fulfill Order ${order.orderNumber}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(CupertinoIcons.xmark_circle_fill),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Courier / Shipping Carrier',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
              ),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: carrierCtl,
                placeholder: 'e.g. DHL Express, FedEx, USPS',
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              const SizedBox(height: 14),
              Text(
                'Tracking Number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
              ),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: trackingCtl,
                placeholder: 'e.g. DHL-9481029418',
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              const SizedBox(height: 24),
              PressableScale(
                onTap: () {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  _seller.updateOrderStatus(
                    order.id,
                    SellerOrderStatus.shipped,
                    carrier: carrierCtl.text.trim(),
                    trackingNumber: trackingCtl.text.trim(),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Confirm Shipment',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmCancel(SellerOrder order) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cancel Order?'),
        content: Text('Cancel order ${order.orderNumber} and initiate buyer refund?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Back'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel & Refund'),
            onPressed: () {
              Navigator.pop(ctx);
              _seller.updateOrderStatus(order.id, SellerOrderStatus.cancelled);
            },
          ),
        ],
      ),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  final SellerOrder order;
  final Color cardBg;
  final Color borderColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onAccept;
  final VoidCallback onShip;
  final VoidCallback onDeliver;
  final VoidCallback onCancel;

  const _SellerOrderCard({
    required this.order,
    required this.cardBg,
    required this.borderColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onAccept,
    required this.onShip,
    required this.onDeliver,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy · hh:mm a');

    final statusColor = switch (order.status) {
      SellerOrderStatus.pending => const Color(0xFFF59E0B),
      SellerOrderStatus.processing => const Color(0xFF3B82F6),
      SellerOrderStatus.shipped => const Color(0xFF8B5CF6),
      SellerOrderStatus.delivered => const Color(0xFF10B981),
      SellerOrderStatus.cancelled => const Color(0xFFEF4444),
    };

    final statusLabel = switch (order.status) {
      SellerOrderStatus.pending => 'Pending',
      SellerOrderStatus.processing => 'Processing',
      SellerOrderStatus.shipped => 'In Transit',
      SellerOrderStatus.delivered => 'Delivered',
      SellerOrderStatus.cancelled => 'Cancelled',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
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
          // Order Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.bag_fill, size: 16, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            dateFormat.format(order.createdAt),
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),

          // Customer Profile Info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
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
                      '${order.customerEmail} • ${order.customerPhone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items in Order
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Size: ${item.size} • Color: ${item.color} • Qty: ${item.quantity}',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currency.format(item.totalPrice),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 10),

          // Total and Shipping Address
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Order Payout',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
              ),
              Text(
                currency.format(order.total),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          if (order.trackingNumber != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.location_solid, size: 14, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    '${order.carrier}: ${order.trackingNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Fulfillment Workflow Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (order.status == SellerOrderStatus.pending) ...[
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Accept Order'),
                ),
              ] else if (order.status == SellerOrderStatus.processing) ...[
                FilledButton.icon(
                  onPressed: onShip,
                  icon: const Icon(CupertinoIcons.cube_box, size: 16),
                  label: const Text('Ship & Add Tracking'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ] else if (order.status == SellerOrderStatus.shipped) ...[
                FilledButton.icon(
                  onPressed: onDeliver,
                  icon: const Icon(CupertinoIcons.checkmark_alt, size: 16),
                  label: const Text('Mark as Delivered'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
