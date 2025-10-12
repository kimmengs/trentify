import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trentify/model/order_status.dart';
import 'package:trentify/model/order_summary.dart';
import 'package:trentify/screens/my_order/cancel_sheets.dart';
import 'package:trentify/screens/my_order/order_card_widget.dart';

class OrderListWidget extends StatelessWidget {
  OrderListWidget({
    required Iterable<OrderSummary> orders,
    required this.onRequestCancel,
  }) : _orders = orders.toList();

  final List<OrderSummary> _orders;
  final void Function(OrderSummary order) onRequestCancel;

  @override
  Widget build(BuildContext context) {
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders'));
    }

    _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = _groupByDate(_orders);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final g = groups[i];
        return _DateSection(
          label: g.label,
          orders: g.items,
          onRequestCancel: onRequestCancel,
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<OrderSummary> src) {
    final List<_DateGroup> out = [];
    for (final o in src) {
      final label = _dateLabel(o.createdAt);
      final existing = out.where((e) => e.label == label).toList();
      if (existing.isEmpty) {
        out.add(_DateGroup(label, [o]));
      } else {
        existing.first.items.add(o);
      }
    }
    return out;
  }

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final df = DateFormat('EEE, MMM d, yyyy');
    if (DateUtils.isSameDay(d, now)) {
      return 'Today, ${df.format(d)}';
    }
    if (DateUtils.isSameDay(d, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday, ${df.format(d)}';
    }
    return DateFormat('MMM d, yyyy').format(d);
  }
}

class _DateGroup {
  final String label;
  final List<OrderSummary> items;
  _DateGroup(this.label, this.items);
}

class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.label,
    required this.orders,
    required this.onRequestCancel,
  });

  final String label;
  final List<OrderSummary> orders;
  final void Function(OrderSummary order) onRequestCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟢 Header row (with kebab menu)
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Color(0xFF528F65)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // ✅ Section kebab (Cancel Order)
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                position: PopupMenuPosition.under,
                itemBuilder: (_) => [
                  const PopupMenuItem<String>(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Cancel Order',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'cancel') {
                    // find all active orders in this section
                    final activeOrders = orders
                        .where((o) => o.status == OrderStatus.active)
                        .toList();

                    if (activeOrders.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No active orders to cancel.'),
                        ),
                      );
                      return;
                    }

                    // ✅ Delegate to parent — no local popup anymore
                    for (final o in activeOrders) {
                      onRequestCancel(o);
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.more_vert),
                ),
              ),
            ],
          ),

          Divider(color: cs.outlineVariant.withOpacity(.35)),
          const SizedBox(height: 6),

          // 🟢 Orders
          Column(
            children: [
              for (var i = 0; i < orders.length; i++) ...[
                OrderCardWidget(
                  order: orders[i],
                  onRequestCancel: onRequestCancel,
                ),
                if (i != orders.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _KebabMenu extends StatelessWidget {
  const _KebabMenu({required this.enabled, required this.onCancelTap});
  final bool enabled;
  final VoidCallback onCancelTap;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'cancel',
          child: Row(
            children: const [
              Icon(Icons.block, size: 20),
              SizedBox(width: 10),
              Text(
                'Cancel Order',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
      onSelected: (v) {
        if (v == 'cancel') onCancelTap(); // 👈 open bottom sheet
      },
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.more_vert),
      ),
    );
  }
}
