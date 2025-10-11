import 'package:flutter/material.dart';
import 'package:trentify/helper/format_number.dart';

class RatingSummaryWidget extends StatelessWidget {
  final double average;
  final int totalRatings;
  final int totalReviews;
  const RatingSummaryWidget({
    required this.average,
    required this.totalRatings,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget bar(int stars, double fraction) {
      return Row(
        children: [
          SizedBox(width: 16, child: Text('$stars', style: text.labelMedium)),
          const SizedBox(width: 6),
          Expanded(child: LinearProgressIndicator(value: fraction)),
        ],
      );
    }

    // demo fractions; replace with real distribution
    final dist = [0.75, 0.16, 0.05, 0.03, 0.01];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // left: average + stars
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              average.toStringAsFixed(1),
              style: text.displaySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) {
                final filled = i < average.round();
                return Icon(filled ? Icons.star : Icons.star_border, size: 18);
              }),
            ),
            const SizedBox(height: 6),
            Text(
              '${formatNumber(totalRatings)} rating • ${formatNumber(totalReviews)} reviews',
              style: text.bodySmall,
            ),
          ],
        ),
        const SizedBox(width: 16),
        // right: histogram
        Expanded(
          child: Column(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: bar(5 - i, dist[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
