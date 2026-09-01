import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/model/address.dart';
import 'package:trentify/provider/address_provider.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/provider/wishlist_provider.dart';
import 'package:trentify/screens/add_to_cart/address_picker/address_picker.dart';
import 'package:trentify/screens/more/address/address.dart';
import 'package:trentify/screens/more/more_page.dart';
import 'package:trentify/theme/theme_controller.dart';

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
  int get contentLength => 0;
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
    return const Stream<List<int>>.empty().listen(
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

  late AddressProvider addressProvider;

  setUp(() {
    addressProvider = AddressProvider.instance;
  });

  Widget createTestWidget({required Widget child, SharedPreferences? prefs}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AddressProvider>.value(value: addressProvider),
        ChangeNotifierProvider<CartProvider>.value(value: CartProvider.instance),
        ChangeNotifierProvider<OrderProvider>.value(value: OrderProvider.instance),
        ChangeNotifierProvider<WishlistProvider>.value(value: WishlistProvider.instance),
        ChangeNotifierProvider<SellerProvider>.value(value: SellerProvider.instance),
        if (prefs != null) ...[
          ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController(prefs)),
          ChangeNotifierProvider<LocaleController>(create: (_) => LocaleController(prefs)),
        ],
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

  group('Address Management Feature Tests', () {
    test('AddressProvider manages addresses, default status, and selections', () {
      expect(addressProvider.addresses.isNotEmpty, isTrue);

      final initialCount = addressProvider.addresses.length;
      final newAddr = Address(
        id: 'test_addr_${DateTime.now().millisecondsSinceEpoch}',
        label: 'Beach Villa',
        fullName: 'Alex Rivera',
        phone: '+1 (555) 999-8888',
        line1: '100 Ocean Drive, Miami Beach, FL 33139',
        isMain: false,
      );

      // Add address
      addressProvider.addAddress(newAddr);
      expect(addressProvider.addresses.length, initialCount + 1);
      expect(addressProvider.addresses.any((a) => a.id == newAddr.id), isTrue);

      // Set as primary
      addressProvider.setPrimary(newAddr.id);
      expect(addressProvider.primaryAddress?.id, newAddr.id);
      expect(addressProvider.primaryAddress?.label, 'Beach Villa');

      // Update address
      final updated = Address(
        id: newAddr.id,
        label: 'Miami Penthouse',
        fullName: 'Alex Rivera',
        phone: '+1 (555) 999-8888',
        line1: '200 Ocean Drive, Miami Beach, FL 33139',
        isMain: true,
      );
      addressProvider.updateAddress(updated);
      expect(addressProvider.primaryAddress?.label, 'Miami Penthouse');

      // Delete address
      addressProvider.deleteAddress(newAddr.id);
      expect(addressProvider.addresses.any((a) => a.id == newAddr.id), isFalse);
    });

    testWidgets('AddressPickerPage renders shipping addresses with actions', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          child: const AddressPickerPage(isPickerMode: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shipping Addresses'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.pencil), findsWidgets);
      expect(find.byIcon(CupertinoIcons.trash), findsWidgets);
      expect(find.byIcon(CupertinoIcons.plus_circle_fill), findsOneWidget);
    });

    testWidgets('AddressFormPage collects inputs, validates, and submits', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Address? savedAddress;

      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedAddress = await Navigator.push<Address>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressFormPage()),
                );
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      expect(find.text('New Address'), findsOneWidget);
      expect(find.text('CONTACT DETAILS'), findsOneWidget);
      expect(find.text('DELIVERY LOCATION'), findsOneWidget);

      // Select 'Office' chip
      await tester.tap(find.text('Office'));
      await tester.pumpAndSettle();

      // Enter street address
      final addressFields = find.byType(TextFormField);
      await tester.enterText(addressFields.at(2), '500 Fifth Avenue, New York, NY 10110');
      await tester.pumpAndSettle();

      // Tap Save in AppBar
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedAddress, isNotNull);
      expect(savedAddress!.label, 'Office');
      expect(savedAddress!.line1, '500 Fifth Avenue, New York, NY 10110');
    });

    testWidgets('MorePage renders Shipping & Delivery Addresses tile', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        createTestWidget(
          prefs: prefs,
          child: const MorePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shipping & Delivery Addresses'), findsOneWidget);
      expect(find.textContaining('Saved Addresses'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.location_solid), findsOneWidget);
    });
  });
}
