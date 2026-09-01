import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/provider/wishlist_provider.dart';
import 'package:trentify/screens/home/category/show_platform_sort_sheet.dart';
import 'package:trentify/widgets/sort_filter/luxury_filter_sheet.dart';
import 'package:trentify/widgets/sort_filter/luxury_sort_sheet.dart';
import 'package:trentify/widgets/sort_filter/sort_filter_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('LuxurySortFilterBar renders sort and filter buttons with active indicators', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: LuxurySortFilterBar(
          isDark: false,
          currentSort: SortOption.priceLowToHigh,
          currentFilter: FilterResult.initial().copyWith(categories: {'Clothing', 'Shoe'}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // 2 active category filters
  });

  testWidgets('LuxurySortSheet displays sort options and allows selection', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SortOption? selectedOption;

    await tester.pumpWidget(
      createTestWidget(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                selectedOption = await LuxurySortSheet.show(context, initial: SortOption.mostSuitable);
              },
              child: const Text('Open Sort'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open sheet
    await tester.tap(find.text('Open Sort'));
    await tester.pumpAndSettle();

    // Verify sort options
    expect(find.text('Sort Collections'), findsOneWidget);
    expect(find.text('Curated For You'), findsOneWidget);
    expect(find.text('Price: Low to High'), findsOneWidget);
    expect(find.text('Price: High to Low'), findsOneWidget);
    expect(find.text('Top Customer Rated'), findsOneWidget);

    // Pick Price: Low to High
    await tester.tap(find.text('Price: Low to High'));
    await tester.pumpAndSettle();

    expect(selectedOption, SortOption.priceLowToHigh);
  });

  testWidgets('LuxuryFilterSheet allows selecting categories, price presets, and applying', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    FilterResult? appliedFilter;

    await tester.pumpWidget(
      createTestWidget(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                appliedFilter = await LuxuryFilterSheet.show(context, initial: FilterResult.initial());
              },
              child: const Text('Open Filter'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open sheet
    await tester.tap(find.text('Open Filter'));
    await tester.pumpAndSettle();

    // Verify header and sections
    expect(find.text('Filter Collections'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Price Range'), findsOneWidget);

    // Tap 'Clothing' category
    await tester.tap(find.text('Clothing'));
    await tester.pumpAndSettle();

    // Tap Price Preset '$100 - $250'
    await tester.tap(find.text('\$100 - \$250'));
    await tester.pumpAndSettle();

    // Tap Apply Filters
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(appliedFilter, isNotNull);
    expect(appliedFilter!.categories.contains('Clothing'), isTrue);
    expect(appliedFilter!.priceRange.start, 100.0);
    expect(appliedFilter!.priceRange.end, 250.0);
  });
}
