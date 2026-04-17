import 'package:flutter/material.dart';

/// ألوان التطبيق الرئيسية (Material 3)
class AppColors {
  // الألوان الأساسية للوضع الفاتح
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFBBDEFB);
  static const Color onPrimaryContainerLight = Color(0xFF0D47A1);
  
  static const Color secondaryLight = Color(0xFF26A69A);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFB2DFDB);
  static const Color onSecondaryContainerLight = Color(0xFF004D40);
  
  static const Color tertiaryLight = Color(0xFFFF9800);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFFFE0B2);
  static const Color onTertiaryContainerLight = Color(0xFFE65100);
  
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFFCDD2);
  static const Color onErrorContainerLight = Color(0xFFB71C1C);
  
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color onSurfaceLight = Color(0xFF212121);
  static const Color surfaceVariantLight = Color(0xFFEEEEEE);
  static const Color onSurfaceVariantLight = Color(0xFF424242);
  
  static const Color outlineLight = Color(0xFFBDBDBD);
  static const Color shadowLight = Color(0xFF000000);
  
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color onBackgroundLight = Color(0xFF212121);
  
  // الألوان الأساسية للوضع الداكن
  static const Color primaryDark = Color(0xFF90CAF9);
  static const Color onPrimaryDark = Color(0xFF0D47A1);
  static const Color primaryContainerDark = Color(0xFF1565C0);
  static const Color onPrimaryContainerDark = Color(0xFFBBDEFB);
  
  static const Color secondaryDark = Color(0xFF80CBC4);
  static const Color onSecondaryDark = Color(0xFF004D40);
  static const Color secondaryContainerDark = Color(0xFF00897B);
  static const Color onSecondaryContainerDark = Color(0xFFB2DFDB);
  
  static const Color tertiaryDark = Color(0xFFFFCC80);
  static const Color onTertiaryDark = Color(0xFFE65100);
  static const Color tertiaryContainerDark = Color(0xFFF57C00);
  static const Color onTertiaryContainerDark = Color(0xFFFFE0B2);
  
  static const Color errorDark = Color(0xFFEF9A9A);
  static const Color onErrorDark = Color(0xFFB71C1C);
  static const Color errorContainerDark = Color(0xFFC62828);
  static const Color onErrorContainerDark = Color(0xFFFFCDD2);
  
  static const Color surfaceDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color surfaceVariantDark = Color(0xFF1E1E1E);
  static const Color onSurfaceVariantDark = Color(0xFFBDBDBD);
  
  static const Color outlineDark = Color(0xFF424242);
  static const Color shadowDark = Color(0xFF000000);
  
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  
  // ألوان خاصة بالمعاملات
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFE53935);
  static const Color transferColor = Color(0xFF2196F3);
  static const Color debtColor = Color(0xFFFF9800);
  
  // ألوان التصنيفات الشائعة
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFFF7043),
    'transport': Color(0xFF42A5F5),
    'shopping': Color(0xFFAB47BC),
    'entertainment': Color(0xFFEC407A),
    'bills': Color(0xFF26A69A),
    'health': Color(0xFF66BB6A),
    'education': Color(0xFF8D6E63),
    'salary': Color(0xFF4CAF50),
    'investment': Color(0xFFFFCA28),
    'other': Color(0xFF9E9E9E),
  };
  
  // تدرجات لونية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
