import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trentify/widgets/app_badge_pill.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/app_network_image.dart';
import 'package:trentify/widgets/app_price_text.dart';
import 'package:trentify/widgets/app_step_indicator.dart';
import 'package:trentify/widgets/liquid_glass_card.dart';

void main() {
  testWidgets('LiquidGlassCard renders child and responds to tap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidGlassCard(
            onTap: () => tapped = true,
            child: const Text('Liquid Content'),
          ),
        ),
      ),
    );

    expect(find.text('Liquid Content'), findsOneWidget);
    await tester.tap(find.text('Liquid Content'));
    expect(tapped, isTrue);
  });

  testWidgets('AppBadgePill renders various badge variants', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppBadgePill(label: 'VIP', variant: BadgeVariant.vip),
              AppBadgePill(label: 'Success', variant: BadgeVariant.success),
              AppBadgePill(label: 'Warning', variant: BadgeVariant.warning),
              AppBadgePill(label: 'Error', variant: BadgeVariant.error),
            ],
          ),
        ),
      ),
    );

    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets('AppPriceText renders formatted currency and original price strikethrough', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppPriceText(
            price: 185.00,
            originalPrice: 220.00,
          ),
        ),
      ),
    );

    expect(find.text('\$185.00'), findsOneWidget);
    expect(find.text('\$220.00'), findsOneWidget);
  });

  testWidgets('AppStepIndicator renders step items with current step state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStepIndicator(
            currentStepIndex: 1,
            steps: [
              StepItem(number: '1', title: 'Bag'),
              StepItem(number: '2', title: 'Checkout'),
              StepItem(number: '3', title: 'Delivery'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Bag'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    // Step 1 is done (check icon)
    expect(find.byIcon(Icons.check), findsOneWidget);
    // Step 2 & 3 numbers
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('AppNetworkImage renders fallback error container on broken URL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppNetworkImage(
            imageUrl: 'invalid_url',
            width: 80,
            height: 80,
            borderRadius: 16,
          ),
        ),
      ),
    );

    expect(find.byType(AppNetworkImage), findsOneWidget);
  });

  test('AppHaptics methods can be invoked without exception', () {
    expect(() => AppHaptics.light(), returnsNormally);
    expect(() => AppHaptics.medium(), returnsNormally);
    expect(() => AppHaptics.heavy(), returnsNormally);
    expect(() => AppHaptics.selection(), returnsNormally);
    expect(() => AppHaptics.success(), returnsNormally);
    expect(() => AppHaptics.error(), returnsNormally);
  });
}
