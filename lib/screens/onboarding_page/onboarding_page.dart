import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/router/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) context.go(AppRoutes.signIn);
  }

  void _nextPage(int totalSlides) {
    HapticFeedback.lightImpact();
    if (_currentIndex < totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final slides = [
      _OnboardSlide(
        tag: context.tr('onboard_tag_1'),
        title: context.tr('onboard_title_1'),
        subtitle: context.tr('onboard_sub_1'),
        imagePath: 'assets/images/onboard/slide1.png',
      ),
      _OnboardSlide(
        tag: context.tr('onboard_tag_2'),
        title: context.tr('onboard_title_2'),
        subtitle: context.tr('onboard_sub_2'),
        imagePath: 'assets/images/onboard/slide2.png',
      ),
      _OnboardSlide(
        tag: context.tr('onboard_tag_3'),
        title: context.tr('onboard_title_3'),
        subtitle: context.tr('onboard_sub_3'),
        imagePath: 'assets/images/onboard/slide3.png',
      ),
    ];

    final isLast = _currentIndex == slides.length - 1;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          CupertinoIcons.sparkles,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TRENTIFY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _completeOnboarding,
                    child: Text(
                      context.tr('skip'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Container with subtle glow
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
                                  ),
                                ),
                                Image.asset(
                                  slide.imagePath,
                                  height: 220,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slide.tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Headline
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Actions & Page Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Smooth Indicator Dots
                  Row(
                    children: List.generate(slides.length, (index) {
                      final active = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 24 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? primaryColor
                              : (isDark
                                  ? const Color(0xFF30363D)
                                  : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  GestureDetector(
                    onTap: () => _nextPage(slides.length),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLast ? 24 : 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? context.tr('get_started') : context.tr('next'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? CupertinoIcons.arrow_right
                                : CupertinoIcons.chevron_right,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide {
  final String tag;
  final String title;
  final String subtitle;
  final String imagePath;

  const _OnboardSlide({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}
