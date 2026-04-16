import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF1B5E20); // أخضر مالي احترافي
  static const _surfaceLight = Color(0xFFF8F9FA);
  static const _surfaceDark = Color(0xFF121212);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
          surface: _surfaceLight,
        ),
        fontFamily: 'System',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          bodyMedium: TextStyle(fontSize: 16, height: 1.5),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
          surface: _surfaceDark,
        ),
        fontFamily: 'System',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          bodyMedium: TextStyle(fontSize: 16, height: 1.5),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF1E1E1E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
