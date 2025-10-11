import 'package:flutter/cupertino.dart';
import 'package:trentify/model/bill_category.dart';

class BillTileWidget extends StatelessWidget {
  const BillTileWidget({required this.cat, required this.onTap});
  final BillCategory cat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: cat.tint.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(cat.icon, color: const Color(0xFF4F77FE), size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }
}
