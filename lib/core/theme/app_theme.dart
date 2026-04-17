import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// إعدادات الثيم (Material 3) - Light & Dark Modes
class AppTheme {
  /// ثيم الوضع الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // الألوان الأساسية
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        primaryContainer: AppColors.primaryContainerLight,
        onPrimaryContainer: AppColors.onPrimaryContainerLight,
        
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondaryLight,
        secondaryContainer: AppColors.secondaryContainerLight,
        onSecondaryContainer: AppColors.onSecondaryContainerLight,
        
        tertiary: AppColors.tertiaryLight,
        onTertiary: AppColors.onTertiaryLight,
        tertiaryContainer: AppColors.tertiaryContainerLight,
        onTertiaryContainer: AppColors.onTertiaryContainerLight,
        
        error: AppColors.errorLight,
        onError: AppColors.onErrorLight,
        errorContainer: AppColors.errorContainerLight,
        onErrorContainer: AppColors.onErrorContainerLight,
        
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        surfaceVariant: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        
        outline: AppColors.outlineLight,
        shadow: AppColors.shadowLight,
        
        background: AppColors.backgroundLight,
        onBackground: AppColors.onBackgroundLight,
      ),
      
      // إعدادات AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.onSurfaceLight,
        surfaceTintColor: AppColors.primaryLight,
      ),
      
      // إعدادات Card
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surfaceLight,
        surfaceTintColor: AppColors.primaryLight,
      ),
      
      // إعدادات ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimaryLight,
        ),
      ),
      
      // إعدادات TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // إعدادات FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
      ),
      
      // إعدادات BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.onSurfaceVariantLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // إعدادات Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariantLight,
        contentTextStyle: const TextStyle(color: AppColors.onSurfaceLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// ثيم الوضع الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // الألوان الأساسية
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.onPrimaryContainerDark,
        
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        secondaryContainer: AppColors.secondaryContainerDark,
        onSecondaryContainer: AppColors.onSecondaryContainerDark,
        
        tertiary: AppColors.tertiaryDark,
        onTertiary: AppColors.onTertiaryDark,
        tertiaryContainer: AppColors.tertiaryContainerDark,
        onTertiaryContainer: AppColors.onTertiaryContainerDark,
        
        error: AppColors.errorDark,
        onError: AppColors.onErrorDark,
        errorContainer: AppColors.errorContainerDark,
        onErrorContainer: AppColors.onErrorContainerDark,
        
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceVariant: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        
        outline: AppColors.outlineDark,
        shadow: AppColors.shadowDark,
        
        background: AppColors.backgroundDark,
        onBackground: AppColors.onBackgroundDark,
      ),
      
      // إعدادات AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        surfaceTintColor: AppColors.primaryDark,
      ),
      
      // إعدادات Card
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surfaceDark,
        surfaceTintColor: AppColors.primaryDark,
      ),
      
      // إعدادات ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimaryDark,
        ),
      ),
      
      // إعدادات TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorDark, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // إعدادات FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
      ),
      
      // إعدادات BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.onSurfaceVariantDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // إعدادات Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        contentTextStyle: const TextStyle(color: AppColors.onSurfaceDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
