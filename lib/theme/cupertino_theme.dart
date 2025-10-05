import 'package:flutter/cupertino.dart';

CupertinoThemeData buildCupertinoTheme({
  required Brightness brightness,
  required Color primary, // same seed/brand
}) {
  final isDark = brightness == Brightness.dark;
  return CupertinoThemeData(
    brightness: brightness,
    primaryColor: primary,
    barBackgroundColor: isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF9F9FB),
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF),
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
      ),
    ),
  );
}
