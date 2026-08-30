import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/screens/wish_list/wish_list.dart';

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

  testWidgets('WishListPage renders grid, switches to list view, and filters by search', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(child: const WishListPage()));
    await tester.pumpAndSettle();

    // Verify Title with count
    expect(find.text('Wishlist (5)'), findsOneWidget);

    // Verify Product items in grid
    expect(find.text('Urban Blend Long Sleeve'), findsOneWidget);
    expect(find.text('Luxe Blend Formal Tee'), findsOneWidget);

    // Toggle to List View
    final listToggle = find.byIcon(CupertinoIcons.list_bullet);
    expect(listToggle, findsOneWidget);
    await tester.tap(listToggle);
    await tester.pumpAndSettle();

    // Verify list view is active (showing In Stock badge)
    expect(find.text('In Stock'), findsWidgets);

    // Toggle back to Grid View
    final gridToggle = find.byIcon(CupertinoIcons.square_grid_2x2);
    expect(gridToggle, findsOneWidget);
    await tester.tap(gridToggle);
    await tester.pumpAndSettle();

    // Open Search Bar
    final searchToggle = find.byIcon(CupertinoIcons.search);
    expect(searchToggle, findsOneWidget);
    await tester.tap(searchToggle);
    await tester.pumpAndSettle();

    // Enter search text
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Formal');
    await tester.pumpAndSettle();

    expect(find.text('Luxe Blend Formal Tee'), findsOneWidget);
    expect(find.text('Urban Blend Long Sleeve'), findsNothing);
  });

  testWidgets('1-tap add to bag adds item to cart provider', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(child: const WishListPage()));
    await tester.pumpAndSettle();

    final addToBagBtns = find.byIcon(CupertinoIcons.bag_badge_plus);
    expect(addToBagBtns, findsWidgets);

    await tester.tap(addToBagBtns.first);
    await tester.pumpAndSettle();

    expect(cart.totalCount, 1);
  });
}
