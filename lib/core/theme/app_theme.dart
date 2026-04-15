import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFFE8A020);
  static const dark = Color(0xFF1E1E32);
  static const background = Color(0xFFF4F4F4);
  static const cardBg = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF64748B);
  static const colorAlternative1 = Color(0xFFD6C4AE);
  static const colorAlternative2 = Color(0xFF514534);
  static const colorAlternative3 = Color(0xFFB45309);
  static const colorAlternative4 = Color(0xFFB91C1C);
  static const danger = Color(0xFFEF4444);
  static const iconBg = Color(0xFFFFF3DC);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: background,
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w800,
      ),
      displayMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: dark,
      ),
      iconTheme: IconThemeData(color: primary),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
