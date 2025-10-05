// success_payment_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessPaymentMaterial extends StatelessWidget {
  const SuccessPaymentMaterial({super.key, required this.payeeName});

  final String payeeName;

  bool _isCupertino(BuildContext context) {
    final p = Theme.of(context).platform;
    return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    final isCupertino = _isCupertino(context);

    final title = Text(
      'Successfully Sent!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: isCupertino
            ? CupertinoColors.label
            : Theme.of(context).colorScheme.onSurface,
      ),
    );

    final subtitle = Text(
      'Your money has been successfully sent to\n$payeeName',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        height: 1.4,
        color: isCupertino
            ? CupertinoColors.systemGrey
            : Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      ),
    );

    final image = SizedBox(
      height: 260,
      child: Image.asset(
        'assets/images/payment/success.png',
        width: 250,
        fit: BoxFit.contain,
      ),
    );

    final bottomButton = isCupertino
        ? CupertinoButton.filled(
            borderRadius: BorderRadius.circular(28),
            onPressed: () => context.go('/home'),
            child: const Text('OK'),
          )
        : SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.go('/home'),
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('OK'),
            ),
          );

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          children: [
            const Spacer(),
            image,
            const SizedBox(height: 12),
            title,
            const SizedBox(height: 8),
            subtitle,
            const Spacer(),
            // Bottom sticky area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: bottomButton,
            ),
          ],
        ),
      ),
    );

    if (isCupertino) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.white,
        child: PopScope(canPop: false, child: SafeArea(child: content)),
      );
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: PopScope(canPop: false, child: SafeArea(child: content)),
      );
    }
  }
}
