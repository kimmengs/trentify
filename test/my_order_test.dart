import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/screens/my_order/my_order.dart';

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
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(
          value: CartProvider.instance,
        ),
        ChangeNotifierProvider<OrderProvider>.value(
          value: OrderProvider.instance,
        ),
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

  testWidgets('MyOrderPage renders active orders, segmented tabs, and search', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(child: const MyOrderPage()));
    await tester.pumpAndSettle();

    // Verify Title & Active Orders
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Active (2)'), findsOneWidget);
    expect(find.text('Completed (1)'), findsOneWidget);
    expect(find.text('Canceled (1)'), findsOneWidget);

    // Verify Active order items
    expect(find.text('#ORD-1001'), findsOneWidget);
    expect(find.text('#ORD-1000'), findsOneWidget);
    expect(find.text('Track Order'), findsNWidgets(2));

    // Open Search Bar
    final searchIconFinder = find.byIcon(CupertinoIcons.search);
    expect(searchIconFinder, findsOneWidget);
    await tester.tap(searchIconFinder);
    await tester.pumpAndSettle();

    // Enter search query for jacket / blazer
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Blazer');
    await tester.pumpAndSettle();

    expect(find.text('#ORD-1000'), findsOneWidget);
    expect(find.text('#ORD-1001'), findsNothing);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    // Switch to Completed tab
    final completedTabFinder = find.text('Completed (1)');
    await tester.tap(completedTabFinder);
    await tester.pumpAndSettle();

    expect(find.text('#ORD-0999'), findsOneWidget);
    expect(find.text('Buy Again'), findsOneWidget);
    expect(find.text('Invoice'), findsOneWidget);

    // Switch to Canceled tab
    final canceledTabFinder = find.text('Canceled (1)');
    await tester.tap(canceledTabFinder);
    await tester.pumpAndSettle();

    expect(find.text('#ORD-0998'), findsOneWidget);
  });

  testWidgets('Tapping Track Order opens courier tracking journey bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(child: const MyOrderPage()));
    await tester.pumpAndSettle();

    final trackOrderFinder = find.text('Track Order').first;
    await tester.tap(trackOrderFinder);
    await tester.pumpAndSettle();

    // Verify Tracking modal content
    expect(find.text('Live Order Tracking'), findsOneWidget);
    expect(find.text('DHL Express Priority (Air Cargo)'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Close modal
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Live Order Tracking'), findsNothing);
  });
}
