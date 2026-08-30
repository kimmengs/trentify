import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/filter_result.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/screens/home/product_detail.dart';

final List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  late ProductDetailData sampleProduct;
  late CartProvider cart;

  setUp(() {
    cart = CartProvider();
    cart.clearCart();

    sampleProduct = const ProductDetailData(
      title: 'Monogram Wool Silk Blend Coat',
      price: 450.0,
      images: [
        'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=800&auto=format&fit=crop',
      ],
      rating: 4.9,
      soldCount: 312,
      sizes: ['S', 'M', 'L', 'XL'],
      colors: [Color(0xFF111214), Color(0xFFF8FAFC)],
      specs: {
        'Material': '90% Wool, 10% Silk',
        'Origin': 'Made in Italy',
      },
      description: 'Handcrafted luxury coat tailored for refined winter comfort.',
    );
  });

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: cart),
        ChangeNotifierProvider<SellerProvider>.value(value: SellerProvider.instance),
      ],
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  testWidgets('ProductDetailPage renders Add to Bag button and clicking it adds product to cart', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createTestWidget(
        child: ProductDetailPage(
          data: sampleProduct,
          initial: FilterResult.initial(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(cart.isEmpty, isTrue);
    expect(cart.totalCount, 0);

    // Verify Add to Bag button exists
    final addToBagFinder = find.text('Add to Bag');
    expect(addToBagFinder, findsOneWidget);

    // Tap Add to Bag button
    await tester.tap(addToBagFinder);
    await tester.pump();

    // Verify cart updated immediately
    expect(cart.isEmpty, isFalse);
    expect(cart.totalCount, 1);
    expect(cart.items.first.title, 'Monogram Wool Silk Blend Coat');
    expect(cart.items.first.price, 450.0);
    expect(cart.items.first.qty, 1);

    // Verify button visual state transitioned to added confirmation
    expect(find.text('Added to bag successfully!'), findsWidgets);

    // Settle snackbar animation
    await tester.pump(const Duration(milliseconds: 500));

    // Verify "View Bag" action button is available in the snackbar
    expect(find.text('View Bag'), findsOneWidget);

    // Settle remaining timer
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Selecting a different size and color adds the specific variant to cart', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createTestWidget(
        child: ProductDetailPage(
          data: sampleProduct,
          initial: FilterResult.initial(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Select Size 'L'
    final sizeLFinder = find.text('L');
    expect(sizeLFinder, findsOneWidget);
    await tester.tap(sizeLFinder);
    await tester.pumpAndSettle();

    // Tap Add to Bag
    await tester.tap(find.text('Add to Bag'));
    await tester.pump();

    expect(cart.totalCount, 1);
    expect(cart.items.first.size, 'L');

    // Settle remaining timer
    await tester.pump(const Duration(seconds: 4));
  });
}
