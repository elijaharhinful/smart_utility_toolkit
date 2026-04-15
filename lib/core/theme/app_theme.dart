import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFFE8A020);
  static const dark = Color(0xFF1E1E32);
  static const background = Color(0xFFF4F4F4);
  static const cardBg = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF64748B);
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
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
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
