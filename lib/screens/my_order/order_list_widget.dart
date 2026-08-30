import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/order_summary.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/screens/my_order/order_card_widget.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class OrderListWidget extends StatelessWidget {
  OrderListWidget({
    super.key,
    required Iterable<OrderSummary> orders,
    required this.onRequestCancel,
  }) : _orders = orders.toList();

  final List<OrderSummary> _orders;
  final void Function(OrderSummary order) onRequestCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    if (_orders.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.bag,
                  size: 42,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.tr('no_orders_title'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('no_orders_sub'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              PressableScale(
                onTap: () {
                  context.go(AppRoutes.home);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('discover_trends'),
                        style: const TextStyle(
                          fontSize: 14,
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
        ),
      );
    }

    _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = _groupByDate(_orders);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final g = groups[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 14,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    g.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            ...g.items.map(
              (o) => OrderCardWidget(
                order: o,
                onRequestCancel: onRequestCancel,
              ),
            ),
          ],
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
    final df = DateFormat('MMM d, yyyy');
    if (DateUtils.isSameDay(d, now)) {
      return 'Today';
    }
    if (DateUtils.isSameDay(d, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return df.format(d);
  }
}

class _DateGroup {
  final String label;
  final List<OrderSummary> items;
  _DateGroup(this.label, this.items);
}
