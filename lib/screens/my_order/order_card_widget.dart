import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/order_status.dart';
import 'package:trentify/model/order_summary.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({required this.order, required this.onRequestCancel});
  final OrderSummary order;
  final void Function(OrderSummary order) onRequestCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final hero = order.products.first;
    final others = order.products.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            hero.imageUrl,
            width: 108,
            height: 124,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),

        // details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hero.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              if (others > 0)
                Text(
                  '+$others other products',
                  style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              const SizedBox(height: 12),
              Text(
                'Total Shopping',
                style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: text.titleLarge?.copyWith(
                  color: const Color(0xFF528F65),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Track order
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: Color(0xFF528F65)),
                    foregroundColor: const Color(0xFF528F65),
                  ),
                  child: const Text(
                    'Track Order',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
