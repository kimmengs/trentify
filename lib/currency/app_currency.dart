import 'package:intl/intl.dart';

enum AppCurrency {
  usd(
    code: 'USD',
    symbol: r'$',
    name: 'US Dollar',
    nativeName: 'US Dollar',
    flag: '🇺🇸',
    rateToUsd: 1.0,
    decimalDigits: 2,
    symbolOnLeft: true,
  ),
  khr(
    code: 'KHR',
    symbol: '៛',
    name: 'Cambodian Riel',
    nativeName: 'រៀលខ្មែរ',
    flag: '🇰🇭',
    rateToUsd: 4100.0,
    decimalDigits: 0,
    symbolOnLeft: false,
  ),
  vnd(
    code: 'VND',
    symbol: '₫',
    name: 'Vietnamese Dong',
    nativeName: 'Đồng Việt Nam',
    flag: '🇻🇳',
    rateToUsd: 25400.0,
    decimalDigits: 0,
    symbolOnLeft: false,
  );

  final String code;
  final String symbol;
  final String name;
  final String nativeName;
  final String flag;
  final double rateToUsd;
  final int decimalDigits;
  final bool symbolOnLeft;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.rateToUsd,
    required this.decimalDigits,
    required this.symbolOnLeft,
  });

  static AppCurrency fromCode(String? code) {
    if (code == null) return AppCurrency.usd;
    final normalized = code.trim().toUpperCase();
    return switch (normalized) {
      'KHR' => AppCurrency.khr,
      'VND' || 'DONG' => AppCurrency.vnd,
      _ => AppCurrency.usd,
    };
  }

  double convert(double amountInUsd) {
    return amountInUsd * rateToUsd;
  }

  String format(double amountInUsd) {
    return formatRaw(convert(amountInUsd));
  }

  String formatRaw(double amountInCurrency) {
    if (decimalDigits == 0) {
      final formatter = NumberFormat('#,###');
      final formatted = formatter.format(amountInCurrency.round());
      return symbolOnLeft ? '$symbol$formatted' : '$formatted $symbol';
    } else {
      final formatter = NumberFormat('#,##0.00');
      final formatted = formatter.format(amountInCurrency);
      return symbolOnLeft ? '$symbol$formatted' : '$formatted $symbol';
    }
  }

  String get exchangeRateLabel => switch (this) {
    AppCurrency.usd => '1 USD = \$1.00',
    AppCurrency.khr => '1 USD ≈ 4,100 ៛',
    AppCurrency.vnd => '1 USD ≈ 25,400 ₫',
  };

  String get shortLabel => '$code ($symbol)';
  String get displayTitle => '$code ($symbol) - $name';
}
