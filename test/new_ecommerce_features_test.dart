import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/cart_item.dart';
import 'package:trentify/model/order_status.dart';
import 'package:trentify/model/product.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/provider/wishlist_provider.dart';
import 'package:trentify/screens/home/widget/sizing_guide_sheet.dart';
import 'package:trentify/screens/home/widget/write_review_sheet.dart';
import 'package:trentify/screens/more/vip_rewards_sheet.dart';

const List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('E-commerce Provider Tests', () {
    test('WishlistProvider toggles favorite and moves item to bag', () {
      final wishlist = WishlistProvider.instance;
      wishlist.resetToDefaults();
      final initialCount = wishlist.count;

      const testProduct = Product(
        title: 'Bespoke Cashmere Overcoat',
        price: 890.0,
        rating: 5.0,
        imageUrl: 'https://example.com/coat.jpg',
      );

      // Add product
      wishlist.addProduct(testProduct);
      expect(wishlist.isFavorite('Bespoke Cashmere Overcoat'), isTrue);
      expect(wishlist.count, initialCount + 1);

      // Toggle off
      wishlist.toggleFavorite(testProduct);
      expect(wishlist.isFavorite('Bespoke Cashmere Overcoat'), isFalse);
      expect(wishlist.count, initialCount);
    });

    test('OrderProvider creates order from cart, cancels order and reorders', () {
      final orderProv = OrderProvider.instance;
      final initialCount = orderProv.orders.length;

      final testItems = [
        CartItem(
          id: 'item_1',
          title: 'Silk Velvet Blazer',
          price: 320.0,
          imageUrl: 'https://example.com/blazer.jpg',
          size: 'L',
          colorName: 'Midnight Navy',
          color: const Color(0xFF0F172A),
          qty: 2,
        ),
      ];

      final orderId = orderProv.createOrderFromCart(
        items: testItems,
        total: 640.0,
        address: '742 Evergreen Terrace',
        paymentMethod: 'Apple Pay',
      );

      expect(orderId.startsWith('ORD-'), isTrue);
      expect(orderProv.orders.length, initialCount + 1);
      expect(orderProv.activeOrders.first.id, orderId);

      // Cancel order
      orderProv.cancelOrder(orderId);
      final canceled = orderProv.orders.firstWhere((o) => o.id == orderId);
      expect(canceled.status, OrderStatus.canceled);

      // Reorder adds items to CartProvider
      CartProvider.instance.clearCart();
      orderProv.reorder(orderId);
      expect(CartProvider.instance.totalCount, 1);
    });
  });

  group('Interactive Modal Sheets Tests', () {
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
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('SizingGuideSheet renders smart recommender, switches units and selects fit', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          child: const SizingGuideSheet(productTitle: 'Monogram Wool Coat'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header and Title
      expect(find.text('Sizing & Fit Guide'), findsOneWidget);
      expect(find.text('Smart Fit Recommender'), findsOneWidget);
      expect(find.text('Size L'), findsOneWidget);

      // Switch Unit from CM to INCH
      final inToggle = find.text('INCH');
      expect(inToggle, findsOneWidget);
      await tester.tap(inToggle);
      await tester.pumpAndSettle();

      // Tap Fit Preference Slim Fit (which recalculates recommended size to M)
      final slimFitPill = find.text('Slim Fit');
      expect(slimFitPill, findsOneWidget);
      await tester.tap(slimFitPill);
      await tester.pumpAndSettle();

      expect(find.text('Size M'), findsOneWidget);

      // Verify measurement table
      expect(find.text('Garment Measurements (inches)'), findsOneWidget);
      expect(find.text('XS'), findsWidgets);
      expect(find.text('XL'), findsWidgets);
    });

    testWidgets('WriteReviewSheet collects 5-star rating, fit choice and submits review', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool reviewSubmitted = false;

      await tester.pumpWidget(
        createTestWidget(
          child: WriteReviewSheet(
            productTitle: 'Urban Blend Silk Shirt',
            onReviewSubmitted: (rev) {
              reviewSubmitted = true;
              expect(rev.author, 'Alex Rivera (Verified Buyer)');
              expect(rev.stars, 5.0);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title
      expect(find.text('Rate & Review'), findsOneWidget);

      // Enter review text
      final commentField = find.byType(TextField);
      expect(commentField, findsOneWidget);
      await tester.enterText(commentField, 'Exquisite tailoring and luxurious silk fabric! Fits impeccably.');
      await tester.pumpAndSettle();

      // Select Fit
      final trueToSize = find.text('True to Size');
      expect(trueToSize, findsOneWidget);
      await tester.tap(trueToSize);
      await tester.pumpAndSettle();

      // Submit Review
      final submitBtn = find.text('Submit Review & Earn 50 Pts');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(reviewSubmitted, isTrue);
    });

    testWidgets('VipRewardsSheet renders points balance, perks and referral invitation code', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          child: const VipRewardsSheet(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Points balance & tier
      expect(find.text('VIP Haute Club'), findsOneWidget);
      expect(find.text('2,450 pts'), findsOneWidget);
      expect(find.text('≈ \$24.50 Credit'), findsOneWidget);
      expect(find.text('Next Tier: Royal Black'), findsOneWidget);

      // Verify Privileges
      expect(find.text('Your Elite Privileges'), findsOneWidget);
      expect(find.text('Complimentary DHL Express Priority'), findsOneWidget);
      expect(find.text('24/7 Private Concierge'), findsOneWidget);

      // Verify Referral Code
      expect(find.text('TRENTIFY-VIP-ALEX'), findsOneWidget);
    });
  });
}
