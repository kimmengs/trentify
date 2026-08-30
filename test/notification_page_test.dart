import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/screens/home/notification/notification.dart';

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

  testWidgets('NotificationPage renders categories, notifications list, and mark all read', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(child: const NotificationPage()));
    await tester.pumpAndSettle();

    // Verify Title & Unread Badge
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // 3 unread items

    // Verify Category Pills
    expect(find.text('All (6)'), findsOneWidget);
    expect(find.text('Orders (2)'), findsOneWidget);
    expect(find.text('Promos (2)'), findsOneWidget);
    expect(find.text('System (2)'), findsOneWidget);

    // Verify Notification Items
    expect(find.text('Package Out for Delivery ✈️'), findsOneWidget);
    expect(find.text('VIP Weekend Exclusive: 20% OFF 🎉'), findsOneWidget);

    // Filter by Orders
    await tester.tap(find.text('Orders (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Package Out for Delivery ✈️'), findsOneWidget);
    expect(find.text('Order Confirmed & Prepared 📦'), findsOneWidget);
    expect(find.text('VIP Weekend Exclusive: 20% OFF 🎉'), findsNothing);

    // Filter back to All
    await tester.tap(find.text('All (6)'));
    await tester.pumpAndSettle();

    // Mark all as read
    final markAllBtn = find.text('Mark all as read');
    expect(markAllBtn, findsOneWidget);
    await tester.tap(markAllBtn);
    await tester.pumpAndSettle();

    // Verify unread badge is cleared
    expect(find.text('Mark all as read'), findsNothing);
  });
}
