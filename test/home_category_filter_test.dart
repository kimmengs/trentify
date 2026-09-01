import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/provider/wishlist_provider.dart';
import 'package:trentify/screens/home/category/category.dart';
import 'package:trentify/screens/home/home_ios.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: CartProvider.instance),
        ChangeNotifierProvider<WishlistProvider>.value(value: WishlistProvider.instance),
        ChangeNotifierProvider<OrderProvider>.value(value: OrderProvider.instance),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('Home & Category Product Filtering Tests', () {
    testWidgets('HomeScreen renders default feed and filters dynamically when tapping Women tab', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(child: const TrendifyHomeCupertino()));
      await tester.pumpAndSettle();

      // Initial tab All: Shows Top Picks & Shop by Category
      expect(find.text('Shop by Category'), findsOneWidget);
      expect(find.text('Top Picks For You'), findsOneWidget);

      // Tap 'Women' Category Pill
      final womenPill = find.text('Women');
      expect(womenPill, findsWidgets);
      await tester.tap(womenPill.first);
      await tester.pumpAndSettle();

      // Now showing Women Collection with filtered products
      expect(find.text('Women Collection'), findsOneWidget);
      expect(find.textContaining('Curated Luxury Pieces'), findsOneWidget);
      expect(find.text('Monogram Silk Evening Gala Gown'), findsOneWidget);

      // Tap 'Shoes' Category Pill
      final shoesPill = find.text('Shoes');
      expect(shoesPill, findsWidgets);
      await tester.tap(shoesPill.first);
      await tester.pumpAndSettle();

      expect(find.text('Shoes Collection'), findsOneWidget);
      expect(find.text('Royal Calfskin Burnished Loafers'), findsOneWidget);
    });

    testWidgets('CategoryPage renders filtered products for specific category', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(child: const CategoryPage(category: 'Bag')));
      await tester.pumpAndSettle();

      // Verify bag products are loaded
      expect(find.text('Monogram Quilted Caviar Crossbody'), findsOneWidget);
      expect(find.text('Architectural Structured Tan Tote'), findsOneWidget);
      expect(find.text('Luxury Heritage Weekend Duffle Bag'), findsOneWidget);

      // Verify floating sort/filter bar is present
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);
    });

    test('DemoDb returns accurate products across all categories', () {
      final women = DemoDb.getProductsByCategory('Women');
      final men = DemoDb.getProductsByCategory('Men');
      final shoes = DemoDb.getProductsByCategory('Shoe');
      final bags = DemoDb.getProductsByCategory('Bag');
      final luxury = DemoDb.getProductsByCategory('Luxury');

      expect(women.length, greaterThanOrEqualTo(5));
      expect(men.length, greaterThanOrEqualTo(5));
      expect(shoes.length, greaterThanOrEqualTo(4));
      expect(bags.length, greaterThanOrEqualTo(4));
      expect(luxury.length, greaterThanOrEqualTo(3));
    });
  });
}
