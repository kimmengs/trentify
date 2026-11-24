import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/currency/app_currency.dart';
import 'package:trentify/currency/currency_controller.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/provider/address_provider.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/screens/more/currency_page.dart';
import 'package:trentify/screens/more/more_page.dart';
import 'package:trentify/screens/seller/dashboard/seller_dashboard_page.dart';
import 'package:trentify/theme/theme_controller.dart';
import 'package:trentify/widgets/app_price_text.dart';

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
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('AppCurrency Unit Tests', () {
    test('Correct metadata for USD, KHR, and VND', () {
      expect(AppCurrency.usd.code, 'USD');
      expect(AppCurrency.usd.symbol, '\$');
      expect(AppCurrency.usd.rateToUsd, 1.0);

      expect(AppCurrency.khr.code, 'KHR');
      expect(AppCurrency.khr.symbol, '៛');
      expect(AppCurrency.khr.rateToUsd, 4100.0);

      expect(AppCurrency.vnd.code, 'VND');
      expect(AppCurrency.vnd.symbol, '₫');
      expect(AppCurrency.vnd.rateToUsd, 25400.0);
    });

    test('AppCurrency.fromCode parses properly with aliases and fallback', () {
      expect(AppCurrency.fromCode('USD'), AppCurrency.usd);
      expect(AppCurrency.fromCode('usd'), AppCurrency.usd);
      expect(AppCurrency.fromCode('KHR'), AppCurrency.khr);
      expect(AppCurrency.fromCode('VND'), AppCurrency.vnd);
      expect(AppCurrency.fromCode('DONG'), AppCurrency.vnd);
      expect(AppCurrency.fromCode('dong'), AppCurrency.vnd);
      expect(AppCurrency.fromCode(null), AppCurrency.usd);
      expect(AppCurrency.fromCode('unknown'), AppCurrency.usd);
    });

    test('Currency formatters output expected formats', () {
      // 100 USD
      expect(AppCurrency.usd.format(100.0), '\$100.00');
      // 100 USD = 410,000 KHR
      expect(AppCurrency.khr.format(100.0), '410,000 ៛');
      // 100 USD = 2,540,000 VND
      expect(AppCurrency.vnd.format(100.0), '2,540,000 ₫');
    });
  });

  group('CurrencyController Tests', () {
    test('Defaults to USD and persists changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final controller = CurrencyController(prefs);
      expect(controller.currency, AppCurrency.usd);
      expect(controller.currencyCode, 'USD');

      controller.setCurrency(AppCurrency.vnd);
      expect(controller.currency, AppCurrency.vnd);
      expect(prefs.getString('app_currency_code'), 'VND');

      // Reload in fresh controller
      final reloaded = CurrencyController(prefs);
      expect(reloaded.currency, AppCurrency.vnd);
    });
  });

  group('AppPriceText Widget Tests', () {
    testWidgets('AppPriceText respects CurrencyController in context', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final currencyCtl = CurrencyController(prefs);

      await tester.pumpWidget(
        ChangeNotifierProvider<CurrencyController>.value(
          value: currencyCtl,
          child: const MaterialApp(
            home: Scaffold(
              body: AppPriceText(price: 50.0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('\$50.00'), findsOneWidget);

      // Change currency to VND (Vietnam Dong)
      currencyCtl.setCurrency(AppCurrency.vnd);
      await tester.pumpAndSettle();

      // 50 USD * 25400 = 1,270,000 ₫
      expect(find.text('1,270,000 ₫'), findsOneWidget);

      // Change currency to KHR (Cambodia Riel)
      currencyCtl.setCurrency(AppCurrency.khr);
      await tester.pumpAndSettle();

      // 50 USD * 4100 = 205,000 ៛
      expect(find.text('205,000 ៛'), findsOneWidget);
    });
  });

  group('CurrencySettingsPage Widget Tests', () {
    testWidgets('CurrencySettingsPage lists USD, KHR, and VND and switches selection', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final currencyCtl = CurrencyController(prefs);

      await tester.pumpWidget(
        ChangeNotifierProvider<CurrencyController>.value(
          value: currencyCtl,
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: CurrencySettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Display Currency'), findsOneWidget);
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.text('Cambodian Riel'), findsOneWidget);
      expect(find.text('Vietnamese Dong'), findsOneWidget);

      // Tap on Vietnamese Dong
      await tester.tap(find.text('Vietnamese Dong'));
      await tester.pumpAndSettle();

      expect(currencyCtl.currency, AppCurrency.vnd);
      expect(prefs.getString('app_currency_code'), 'VND');
    });
  });

  group('MorePage Currency Option & Modal Picker Tests', () {
    testWidgets('MorePage opens currency picker and updates selection to VND', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final themeCtl = ThemeController(prefs);
      final localeCtl = LocaleController(prefs);
      final currencyCtl = CurrencyController(prefs);
      localeCtl.setLanguageCode('en');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AddressProvider>.value(value: AddressProvider.instance),
            ChangeNotifierProvider<CartProvider>.value(value: CartProvider.instance),
            ChangeNotifierProvider<LocaleController>.value(value: localeCtl),
            ChangeNotifierProvider<CurrencyController>.value(value: currencyCtl),
            ChangeNotifierProvider<ThemeController>.value(value: themeCtl),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: MorePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Display Currency tile
      final currencyTile = find.text('Display Currency');
      expect(currencyTile, findsOneWidget);
      expect(find.text('USD (\$) • US Dollar'), findsOneWidget);

      // Tap Display Currency to open bottom sheet modal
      await tester.tap(currencyTile);
      await tester.pumpAndSettle();

      // Modal is open
      expect(find.text('Select Display Currency'), findsOneWidget);
      expect(find.text('USD (\$) - US Dollar'), findsOneWidget);
      expect(find.text('KHR (៛) - Cambodian Riel'), findsOneWidget);
      expect(find.text('VND (₫) - Vietnamese Dong'), findsOneWidget);

      // Tap VND option
      await tester.tap(find.text('VND (₫) - Vietnamese Dong'));
      await tester.pumpAndSettle();

      // Verify currency controller updated
      expect(currencyCtl.currency, AppCurrency.vnd);
      expect(find.text('VND (₫) • Vietnamese Dong'), findsOneWidget);
    });
  });

  group('Seller Dashboard Currency Display Tests', () {
    testWidgets('SellerDashboardPage updates amounts according to display currency', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final currencyCtl = CurrencyController(prefs);

      await tester.pumpWidget(
        ChangeNotifierProvider<CurrencyController>.value(
          value: currencyCtl,
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: SellerDashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to VND (Vietnam Dong)
      currencyCtl.setCurrency(AppCurrency.vnd);
      await tester.pumpAndSettle();

      // Check today's sales formatted in VND: 1,240.50 * 25,400 = 31,508,700 ₫
      expect(find.text('31,508,700 ₫'), findsOneWidget);
    });
  });
}
