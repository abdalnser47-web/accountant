/// ثوابت التطبيق الرئيسية
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'مدير حساباتي';
  static const String appVersion = '1.0.0';
  
  // مفاتيح التخزين المحلي
  static const String themeBoxName = 'theme_box';
  static const String settingsBoxName = 'settings_box';
  static const String transactionsBoxName = 'transactions_box';
  static const String accountsBoxName = 'accounts_box';
  
  // مفاتيح التفضيلات
  static const String isDarkModeKey = 'is_dark_mode';
  static const String currencyCodeKey = 'currency_code';
  static const String languageCodeKey = 'language_code';
  static const String isPremiumKey = 'is_premium';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String pinCodeKey = 'pin_code';
  
  // العملات المدعومة
  static const List<String> supportedCurrencies = [
    'SAR', // ريال سعودي
    'AED', // درهم إماراتي
    'EGP', // جنيه مصري
    'KWD', // دينار كويتي
    'QAR', // ريال قطري
    'BHD', // دينار بحريني
    'OMR', // ريال عماني
    'JOD', // دينار أردني
    'USD', // دولار أمريكي
    'EUR', // يورو
  ];
  
  // اللغات المدعومة
  static const List<String> supportedLanguages = ['ar', 'en'];
  static const String defaultLanguage = 'ar';
  static const String defaultCurrency = 'SAR';
  
  // حدود التطبيق
  static const int maxCategoriesPerGroup = 20;
  static const int maxAccounts = 50;
  static const int transactionsPerPage = 20;
  
  // فترات التقارير
  static const List<String> reportPeriods = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
    'custom',
  ];
  
  // أنواع الإعلانات (لـ AdMob)
  static const String adMobAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY';
  static const String bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB';
  static const String interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/CCCCCCCCCC';
  static const String rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/DDDDDDDDDD';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String accountsCollection = 'accounts';
  static const String categoriesCollection = 'categories';
  static const String debtsCollection = 'debts';
  static const String customersCollection = 'customers';
  static const String suppliersCollection = 'suppliers';
  static const String employeesCollection = 'employees';
  static const String goalsCollection = 'goals';
  static const String settingsCollection = 'settings';
  
  // مهلات الاتصال
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // إعدادات المزامنة
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxOfflineTransactions = 1000;
}
