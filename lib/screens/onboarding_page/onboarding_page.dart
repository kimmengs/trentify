import 'package:flutter/cupertino.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/router/app_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _onDone(BuildContext context) async {
    // Save flag so we don’t show it again next launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (context.mounted) context.go(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: IntroductionScreen(
          // The list of slides
          pages: [
            PageViewModel(
              title: "Easy Payments",
              body: "Now easier to make online payments.",
              image: Image.asset(
                'assets/images/onboard/slide1.png',
                width: 250,
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                bodyTextStyle: TextStyle(fontSize: 16),
                pageColor: CupertinoColors.white,
              ),
            ),
            PageViewModel(
              title: "Secure Payments",
              body: "Secure transactions & Reliable anytime.",
              image: Image.asset(
                'assets/images/onboard/slide2.png',
                width: 250,
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                bodyTextStyle: TextStyle(fontSize: 16),
                pageColor: CupertinoColors.white,
              ),
            ),
            PageViewModel(
              title: "Manage Financials",
              body: "Let's manage your financials now.",
              image: Image.asset(
                'assets/images/onboard/slide3.png',
                width: 250,
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                bodyTextStyle: TextStyle(fontSize: 16),
                pageColor: CupertinoColors.white,
              ),
            ),
          ],

          onDone: () => _onDone(context),
          showSkipButton: true,
          skip: const Text(
            "Skip",
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
          next: const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.activeBlue,
          ),
          done: const Text(
            "Get Started",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CupertinoColors.activeBlue,
            ),
          ),

          // iOS-style dots animation
          dotsDecorator: const DotsDecorator(
            activeColor: CupertinoColors.activeBlue,
            size: Size(10.0, 10.0),
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
          globalBackgroundColor: CupertinoColors.white,
        ),
      ),
    );
  }
}
