import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  final SharedPreferences _prefs;

  LocaleController(this._prefs) {
    _load();
  }

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  String get displayName => switch (_locale.languageCode) {
    'km' => 'ភាសាខ្មែរ (Khmer)',
    'vi' => 'Tiếng Việt (Vietnamese)',
    _ => 'English (US)',
  };

  void setLocale(Locale loc) {
    var code = loc.languageCode;
    if (code == 'kh') code = 'km';
    if (code == 'vn') code = 'vi';

    _locale = Locale(code);
    _prefs.setString('app_language_code', code);
    notifyListeners();
  }

  void setLanguageCode(String code) {
    setLocale(Locale(code));
  }

  void _load() {
    final savedCode = _prefs.getString('app_language_code');
    if (savedCode != null) {
      final code = switch (savedCode) {
        'kh' => 'km',
        'vn' => 'vi',
        _ => savedCode,
      };
      if (['en', 'km', 'vi'].contains(code)) {
        _locale = Locale(code);
      }
    }
  }
}
