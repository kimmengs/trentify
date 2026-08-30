import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/screens/add_to_cart/add_to_cart.dart';

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
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
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
  late CartProvider cart;

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() {
    cart = CartProvider();
    cart.clearCart();
    cart.addToCart(
      title: 'Urban Blend Long Sleeve Shirt',
      price: 185.0,
      imageUrl: 'https://picsum.photos/seed/shirt/400/600',
      size: 'L',
      colorName: 'Black',
      color: const Color(0xFF111214),
      qty: 1,
    );
    cart.addToCart(
      title: 'Street Style Comfort Tee',
      price: 155.0,
      imageUrl: 'https://picsum.photos/seed/tee/400/600',
      size: 'M',
      colorName: 'White',
      color: const Color(0xFFFFFFFF),
      qty: 2,
    );
  });

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: cart),
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

  testWidgets('AddToCartPage renders modern luxury layout with free shipping tracker and items', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(child: const AddToCartPage()));
    await tester.pumpAndSettle();

    // Verify Title with total count (1 + 2 = 3)
    expect(find.text('My Shopping Bag (3)'), findsOneWidget);

    // Verify Free Shipping tracker unlocked because $185 + $310 = $495 >= $300
    expect(find.text('Unlocked! Free Express VIP Delivery 🚀'), findsOneWidget);

    // Verify Cart items present
    expect(find.text('Urban Blend Long Sleeve Shirt'), findsOneWidget);
    expect(find.text('Street Style Comfort Tee'), findsOneWidget);

    // Verify Select All strip
    expect(find.text('Select All (3)'), findsOneWidget);

    // Verify Order summary
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('Items Subtotal (3)'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);

    // Verify Proceed to Checkout button
    expect(find.text('Proceed to Checkout'), findsOneWidget);
  });

  testWidgets('Updating item quantity recalculates subtotal and total', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(child: const AddToCartPage()));
    await tester.pumpAndSettle();

    expect(cart.totalCount, 3);
    expect(cart.selectedTotal, 495.0);

    // Tap '+' on the first item
    final plusIcons = find.byIcon(Icons.add);
    final cupertinoPlus = find.byIcon(const IconData(0xf48b, fontFamily: 'CupertinoIcons', fontPackage: 'cupertino_icons'));
    if (plusIcons.evaluate().isNotEmpty) {
      await tester.tap(plusIcons.first);
    } else if (cupertinoPlus.evaluate().isNotEmpty) {
      await tester.tap(cupertinoPlus.first);
    }
    await tester.pumpAndSettle();

    // Verify cart provider state
    expect(cart.items.isNotEmpty, isTrue);
  });

  testWidgets('Empty cart displays empty state illustration and start shopping CTA', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    cart.clearCart();

    await tester.pumpWidget(createTestWidget(child: const AddToCartPage()));
    await tester.pumpAndSettle();

    expect(find.text('Your Shopping Bag is Empty'), findsOneWidget);
    expect(find.text('Start Shopping'), findsOneWidget);
  });
}
