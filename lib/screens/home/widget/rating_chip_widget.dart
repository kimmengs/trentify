import 'package:flutter/cupertino.dart';

class RatingChipWidget extends StatelessWidget {
  final double rating;
  const RatingChipWidget({required this.rating});

  @override
  Widget build(BuildContext context) {
    final chipBg = CupertinoDynamicColor.resolve(
      CupertinoColors.systemBackground,
      context,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.star_fill,
              size: 12,
              color: CupertinoColors.systemYellow,
            ),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
