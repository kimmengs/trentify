import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/main.dart' as app;

Future<void> _safeTap(WidgetTester tester, Finder finder, {int delayMs = 1200}) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(milliseconds: delayMs));
  }
}

Future<void> _safeDrag(WidgetTester tester, Finder finder, Offset offset, {int delayMs = 1200}) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.drag(finder.first, offset);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(milliseconds: delayMs));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('WeBuy UAT - Complete Showcase Demo Flow for Video Recording', (tester) async {
    SharedPreferences.setMockInitialValues({'seenOnboarding': true});
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 2000));

    // ==========================================
    // 1. LOGIN SCREEN & VIP ACCESS
    // ==========================================
    final vipBtn = find.textContaining('Quick 1-Tap VIP Access');
    await _safeTap(tester, vipBtn, delayMs: 2000);

    // ==========================================
    // 2. HOME FEED & LIQUID GLASS DISCOVERY
    // ==========================================
    final homeScrollView = find.byType(CustomScrollView);
    await _safeDrag(tester, homeScrollView, const Offset(0, -350), delayMs: 1400);
    await _safeDrag(tester, homeScrollView, const Offset(0, -350), delayMs: 1400);
    await _safeDrag(tester, homeScrollView, const Offset(0, 700), delayMs: 1200);

    // Switch Category Pills
    await _safeTap(tester, find.text('Women'), delayMs: 1200);
    await _safeTap(tester, find.text('Men'), delayMs: 1000);
    await _safeTap(tester, find.text('All'), delayMs: 1000);

    // ==========================================
    // 3. PRODUCT DETAIL & ADD TO BAG
    // ==========================================
    final productTile = find.textContaining('Classic');
    if (productTile.evaluate().isNotEmpty) {
      await _safeTap(tester, productTile, delayMs: 1800);

      // Tap Add to Bag
      final addBagBtn = find.textContaining('Add to Bag');
      await _safeTap(tester, addBagBtn, delayMs: 1800);

      // Return to Home
      final backBtn = find.byIcon(CupertinoIcons.back);
      await _safeTap(tester, backBtn, delayMs: 1000);
    }

    // ==========================================
    // 4. WISHLIST FLOW (GRID & LIST MODES)
    // ==========================================
    final wishlistNav = find.byIcon(CupertinoIcons.heart);
    await _safeTap(tester, wishlistNav, delayMs: 1500);

    // Switch to List View
    final listToggle = find.byIcon(CupertinoIcons.list_bullet);
    await _safeTap(tester, listToggle, delayMs: 1400);

    // Switch back to Grid View
    final gridToggle = find.byIcon(CupertinoIcons.square_grid_2x2);
    await _safeTap(tester, gridToggle, delayMs: 1200);

    // ==========================================
    // 5. SHOPPING BAG & 3-STEP CHECKOUT
    // ==========================================
    final bagNav = find.byIcon(CupertinoIcons.bag);
    await _safeTap(tester, bagNav, delayMs: 1600);

    // Tap Checkout
    final checkoutBtn = find.textContaining('Checkout');
    await _safeTap(tester, checkoutBtn, delayMs: 2000);

    // Tap Place Order on Checkout
    final placeOrderBtn = find.textContaining('Place Order');
    await _safeTap(tester, placeOrderBtn, delayMs: 2800);

    // Tap View My Orders from confirmation modal
    final viewOrdersBtn = find.textContaining('View My Orders');
    if (viewOrdersBtn.evaluate().isNotEmpty) {
      await _safeTap(tester, viewOrdersBtn, delayMs: 1800);
    }

    // ==========================================
    // 6. MY ORDERS & TRACKING SHEET
    // ==========================================
    final trackOrderBtn = find.text('Track Order');
    if (trackOrderBtn.evaluate().isNotEmpty) {
      await _safeTap(tester, trackOrderBtn, delayMs: 2200);

      // Dismiss tracking sheet
      final doneBtn = find.text('Done');
      await _safeTap(tester, doneBtn, delayMs: 1000);
    }

    // ==========================================
    // 7. SELLER CENTER (SHOP OWNER HUB)
    // ==========================================
    final moreNav = find.byIcon(CupertinoIcons.person_crop_circle);
    await _safeTap(tester, moreNav, delayMs: 1600);

    // Open Shop Owner Center
    final sellerHubTile = find.text('Shop Owner Center');
    if (sellerHubTile.evaluate().isNotEmpty) {
      await _safeTap(tester, sellerHubTile, delayMs: 2200);

      // Inventory Tab
      final inventoryTab = find.text('Inventory');
      await _safeTap(tester, inventoryTab, delayMs: 1600);

      // Payouts Tab
      final payoutsTab = find.text('Payouts');
      await _safeTap(tester, payoutsTab, delayMs: 1800);

      // Return to Account
      final backToMore = find.byIcon(CupertinoIcons.back);
      await _safeTap(tester, backToMore, delayMs: 1200);
    }

    // ==========================================
    // 8. THEME & APPEARANCE STUDIO
    // ==========================================
    final themeTile = find.text('Theme & Appearance');
    if (themeTile.evaluate().isNotEmpty) {
      await _safeTap(tester, themeTile, delayMs: 1800);

      // Switch to Dark Obsidian Mode
      final darkModeCard = find.text('Dark');
      await _safeTap(tester, darkModeCard, delayMs: 2000);

      // Switch to Emerald Velvet Palette
      final emeraldPalette = find.text('Emerald Velvet');
      await _safeTap(tester, emeraldPalette, delayMs: 1600);

      // Switch to Rose Gold Palette
      final rosePalette = find.text('Rose Gold Couture');
      await _safeTap(tester, rosePalette, delayMs: 1600);

      // Switch to Imperial Sapphire Palette
      final sapphirePalette = find.text('Imperial Sapphire');
      await _safeTap(tester, sapphirePalette, delayMs: 1600);

      // Return to Account
      final backFromTheme = find.byIcon(CupertinoIcons.back);
      await _safeTap(tester, backFromTheme, delayMs: 1500);
    }

    // Final showcase pause on Account
    await Future.delayed(const Duration(milliseconds: 2500));
  });
}
