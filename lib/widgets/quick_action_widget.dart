import 'package:flutter/cupertino.dart';

class QuickActionTileWidget extends StatelessWidget {
  const QuickActionTileWidget({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.size = 60,
    this.cornerRadius = 50,
    this.backgroundColor = const Color.fromARGB(108, 179, 212, 255),
    this.iconColor = const Color(0xFF4F77FE),
    this.labelColor = CupertinoColors.label,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double cornerRadius;
  final Color backgroundColor;
  final Color iconColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final itemWidth =
        (MediaQuery.of(context).size.width - 16 - 16 - 18 * 3) / 4;

    return SizedBox(
      width: itemWidth,
      child: Column(
        children: [
          // Background box + CupertinoButton stacked
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size(size, size), // full hit target
                onPressed: onTap ?? () {}, // keep enabled
                child: Icon(icon, color: iconColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
