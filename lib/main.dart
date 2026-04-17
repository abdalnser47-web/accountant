import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'presentation/routers/app_router.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase بشكل آمن (لن يتعطل التطبيق إذا لم يتم الربط بعد)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  
  // تثبيت الاتجاه العمودي مناسب لتطبيقات المالية
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // تحسين مظهر شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'مدير حساباتي',
      debugShowCheckedModeBanner: false,
      
      // دعم اللغتين العربية والإنجليزية
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // الإنجليزية
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // الثيم
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // استخدام إعداد النظام
      
      // التوجيه
      routerConfig: AppRouter.router,
      
      // الصفحة الرئيسية
      home: const HomeScreen(),
    );
  }
}
