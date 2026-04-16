import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/locale_provider.dart';
import 'l10n/app_localizations.dart'; // يتم توليده تلقائيًا

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

  runApp(const ProviderScope(child: ExpenseManagerApp()));
}

class ExpenseManagerApp extends ConsumerWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isRTL = currentLocale.languageCode == 'ar';

    return MaterialApp.router(
      title: AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // تبديل تلقائي حسب إعدادات الجهاز
      locale: currentLocale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
