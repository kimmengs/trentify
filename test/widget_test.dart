// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:trentify/main.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/locale_controller.dart';
import 'package:trentify/provider/product_provider.dart';
import 'package:trentify/theme/theme_controller.dart';

void main() {
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
