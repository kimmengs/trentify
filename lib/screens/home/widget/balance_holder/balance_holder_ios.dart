import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class BalanceHeaderCupertino extends StatefulWidget {
  const BalanceHeaderCupertino({
    super.key,
    required this.balance,
    this.onScan,
    this.onBell,
  });

  final double balance;
  final VoidCallback? onScan;
  final VoidCallback? onBell;

  @override
  State<BalanceHeaderCupertino> createState() => _BalanceHeaderCupertinoState();
}

class _BalanceHeaderCupertinoState extends State<BalanceHeaderCupertino> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A66F7), Color(0xFF487BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.circle_grid_3x3_fill,
                    size: 14,
                    color: Color(0xFF3A66F7),
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  onPressed: widget.onScan,
                  child: const Icon(
                    CupertinoIcons.qrcode,
                    color: CupertinoColors.white,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  onPressed: widget.onBell,
                  child: const Icon(
                    CupertinoIcons.bell,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    _hidden ? '******' : f.format(widget.balance),
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.all(4),
                  onPressed: () => setState(() => _hidden = !_hidden),
                  child: Icon(
                    _hidden
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    color: CupertinoColors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Balance Available',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
