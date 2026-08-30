import 'package:flutter/cupertino.dart';

CupertinoThemeData buildCupertinoTheme({
  required Brightness brightness,
  required Color primary,
}) {
  final isDark = brightness == Brightness.dark;
  return CupertinoThemeData(
    brightness: brightness,
    primaryColor: primary,
    primaryContrastingColor: CupertinoColors.white,
    barBackgroundColor: isDark
        ? const Color(0xCC090D14)
        : const Color(0xCCF8FAFC),
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF090D14)
        : const Color(0xFFF8FAFC),
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        color: isDark ? CupertinoColors.white : const Color(0xFF0F172A),
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: isDark ? CupertinoColors.white : const Color(0xFF0F172A),
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.6,
        color: isDark ? CupertinoColors.white : const Color(0xFF0F172A),
      ),
    ),
  );
}
