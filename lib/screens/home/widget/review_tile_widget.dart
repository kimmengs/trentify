import 'package:flutter/material.dart';
import 'package:trentify/screens/home/product_detail.dart';

class ReviewTileWidget extends StatelessWidget {
  final ReviewData r;
  const ReviewTileWidget(this.r, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${r.author.hashCode}'),
                backgroundColor: isDark ? const Color(0xFF1E2633) : const Color(0xFFE2E8F0),
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
                            r.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.ago,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < r.stars.round();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: const Color(0xFFF59E0B),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (r.variant.isNotEmpty)
            Text(
              'Variant: ${r.variant}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            r.text,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          if (r.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: r.photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    r.photos[i],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
