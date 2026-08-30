import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/cart_item.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/screens/add_to_cart/checkout/checkout.dart';

const List<int> _kTransparentImage = <int>[
  0x89, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
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
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: CartProvider.instance),
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

  testWidgets('CheckoutPage renders delivery address, order review, payment, and place order button', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final sampleItems = [
      CartItem(
        id: 'c1',
        title: 'Silk Long Sleeve Shirt',
        imageUrl: 'https://picsum.photos/seed/shirt/400/600',
        size: 'L',
        colorName: 'Black',
        color: const Color(0xFF111214),
        price: 185.0,
        qty: 1,
      ),
      CartItem(
        id: 'c2',
        title: 'Urban Wool Blazer',
        imageUrl: 'https://picsum.photos/seed/blazer/400/600',
        size: 'M',
        colorName: 'Brown',
        color: const Color(0xFF8D6E63),
        price: 240.0,
        qty: 1,
      ),
    ];

    await tester.pumpWidget(createTestWidget(
      child: CheckoutPage(items: sampleItems),
    ));
    await tester.pumpAndSettle();

    // Verify Title & SSL Security Badge
    expect(find.text('Checkout'), findsNWidgets(2));
    expect(find.text('SSL 256'), findsOneWidget);

    // Verify Step progress indicator
    expect(find.text('Bag'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);

    // Verify Shipping Address section
    expect(find.text('Shipping Address'), findsOneWidget);

    // Verify Order Items section
    expect(find.text('Order Items (2)'), findsOneWidget);
    expect(find.text('Silk Long Sleeve Shirt'), findsOneWidget);
    expect(find.text('Urban Wool Blazer'), findsOneWidget);

    // Verify Courier Speed
    expect(find.text('Delivery Courier Speed'), findsOneWidget);
    expect(find.text('DHL Express VIP Priority Air (1-2 Days)'), findsOneWidget);

    // Verify Payment Method section
    expect(find.text('Payment Method'), findsOneWidget);

    // Verify Place Order CTA
    expect(find.text('Place Order'), findsOneWidget);
  });
}
