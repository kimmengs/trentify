// success_payment_page.dart
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class SuccessPaymentCupertino extends StatelessWidget {
  const SuccessPaymentCupertino({super.key, required this.payeeName});

  final String payeeName;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      // Block back to keep stack clean (optional)
      child: PopScope(
        canPop: false,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  const Spacer(),
                  // Illustration (swap with your asset if you have one)
                  SizedBox(
                    height: 260,
                    child: Image.asset(
                      'assets/images/payment/success.png',
                      width: 250,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Successfully Sent!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your money has been successfully sent to\n$payeeName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                      height: 1.4,
                    ),
                  ),
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
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(28),
                      onPressed: () {
                        context.go(
                          '/home',
                        ); // or context.go('/home') if that's your path
                      },
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
