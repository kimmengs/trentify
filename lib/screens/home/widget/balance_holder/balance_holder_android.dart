import 'package:flutter/material.dart';
import 'package:trentify/theme/app_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class BalanceHeaderAndroid extends StatefulWidget {
  const BalanceHeaderAndroid({
    super.key,
    required this.balance,
    this.onScan,
    this.onBell,
  });

  final double balance;
  final VoidCallback? onScan;
  final VoidCallback? onBell;

  @override
  State<BalanceHeaderAndroid> createState() => _BalanceHeaderAndroidState();
}

class _BalanceHeaderAndroidState extends State<BalanceHeaderAndroid> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final theme = Theme.of(context);

    // read your custom BrandTokens extension
    final tokens = Theme.of(context).extension<BrandTokens>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // 👈 ensures child respects card radius
      child: Stack(
        children: [
          // Wallpaper or Lottie background inside the card
          if (tokens?.wallpaperAsset != null)
            Positioned.fill(
              child: Opacity(
                opacity: tokens!.wallpaperOpacity ?? 0.25,
                child: Image.asset(tokens.wallpaperAsset!, fit: BoxFit.cover),
              ),
            ),
          if (tokens?.lottieAsset != null)
            Positioned.fill(
              child: Lottie.asset(
                tokens!.lottieAsset!,
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

          // Foreground content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.grid_view,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onScan,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    IconButton(
                      onPressed: widget.onBell,
                      icon: const Icon(Icons.notifications_none_rounded),
                      color: theme.colorScheme.onPrimaryContainer,
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
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden ? Icons.visibility_off : Icons.visibility,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Balance Available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
