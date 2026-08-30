import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/l10n/locale_controller.dart';

void main() {
  group('3-Language Localization Tests (EN, KM/KH, VI/VN)', () {
    test('English translations resolve correctly', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.translate('nav_home'), 'Home');
      expect(l10n.translate('welcome_back'), 'Welcome Back');
      expect(l10n.translate('shop_owner_center'), 'Shop Owner Center');
      expect(l10n.translate('sign_in'), 'Sign In');
    });

    test('Khmer translations resolve in natural Khmer script', () {
      final l10n = AppLocalizations(const Locale('km'));
      expect(l10n.translate('nav_home'), 'ទំព័រដើម');
      expect(l10n.translate('welcome_back'), 'សូមស្វាគមន៍មកកាន់ WeBuy');
      expect(l10n.translate('shop_owner_center'), 'មជ្ឈមណ្ឌលម្ចាស់ហាង');
      expect(l10n.translate('sign_in'), 'ចូលគណនី');
    });

    test('Vietnamese translations resolve in Vietnamese script', () {
      final l10n = AppLocalizations(const Locale('vi'));
      expect(l10n.translate('nav_home'), 'Trang chủ');
      expect(l10n.translate('welcome_back'), 'Chào mừng trở lại');
      expect(l10n.translate('shop_owner_center'), 'Trung tâm người bán');
      expect(l10n.translate('sign_in'), 'Đăng nhập');
    });

    test('LocaleController switches language and normalizes kh/vn aliases', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ctl = LocaleController(prefs);

      expect(ctl.languageCode, 'en');
      expect(ctl.displayName, contains('English'));

      // Switch to Khmer
      ctl.setLanguageCode('km');
      expect(ctl.languageCode, 'km');
      expect(ctl.displayName, contains('ភាសាខ្មែរ'));

      // Switch to Khmer with alias 'kh'
      ctl.setLanguageCode('kh');
      expect(ctl.languageCode, 'km');

      // Switch to Vietnamese with alias 'vn'
      ctl.setLanguageCode('vn');
      expect(ctl.languageCode, 'vi');
      expect(ctl.displayName, contains('Tiếng Việt'));

      // Verify delegate supports all codes
      expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('km')), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('vi')), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('kh')), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('vn')), isTrue);
    });
  });
}
