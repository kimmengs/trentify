import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/main.dart';
import 'package:trentify/provider/address_provider.dart';
import 'package:trentify/provider/cart_provider.dart';
import 'package:trentify/provider/order_provider.dart';
import 'package:trentify/provider/product_provider.dart';
import 'package:trentify/provider/wishlist_provider.dart';
import 'package:trentify/theme/theme_controller.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeController>(
            create: (_) => ThemeController(prefs),
          ),
          ChangeNotifierProvider<LocaleController>(
            create: (_) => LocaleController(prefs),
          ),
          ChangeNotifierProvider<AddressProvider>(
            create: (_) => AddressProvider.instance,
          ),
          ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider.instance,
          ),
          ChangeNotifierProvider<WishlistProvider>(
            create: (_) => WishlistProvider.instance,
          ),
          ChangeNotifierProvider<OrderProvider>(
            create: (_) => OrderProvider.instance,
          ),
          Provider<ProductRepository>(
            create: (_) => InMemoryProductRepository(),
          ),
        ],
        child: const App(showOnboarding: true),
      ),
    );

    expect(find.byType(App), findsOneWidget);
  });
}
