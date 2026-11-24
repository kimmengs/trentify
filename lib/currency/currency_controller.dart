import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trentify/currency/app_currency.dart';

class CurrencyController extends ChangeNotifier {
  final SharedPreferences _prefs;

  CurrencyController(this._prefs) {
    _load();
  }

  static const String _prefKey = 'app_currency_code';

  AppCurrency _currency = AppCurrency.usd;

  AppCurrency get currency => _currency;
  String get currencyCode => _currency.code;
  String get symbol => _currency.symbol;
  double get rateToUsd => _currency.rateToUsd;

  String get displayName => switch (_currency) {
    AppCurrency.usd => 'USD (\$) • US Dollar',
    AppCurrency.khr => 'KHR (៛) • Cambodian Riel',
    AppCurrency.vnd => 'VND (₫) • Vietnamese Dong',
  };

  String get displayLabel => '${_currency.code} (${_currency.symbol})';

  void setCurrency(AppCurrency cur) {
    if (_currency == cur) return;
    _currency = cur;
    _prefs.setString(_prefKey, cur.code);
    notifyListeners();
  }

  void setCurrencyCode(String code) {
    setCurrency(AppCurrency.fromCode(code));
  }

  double convert(double amountInUsd) => _currency.convert(amountInUsd);

  String format(double amountInUsd) => _currency.format(amountInUsd);

  String formatRaw(double amountInCurrency) => _currency.formatRaw(amountInCurrency);

  void _load() {
    final savedCode = _prefs.getString(_prefKey);
    if (savedCode != null) {
      _currency = AppCurrency.fromCode(savedCode);
    }
  }
}
