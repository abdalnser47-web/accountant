import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// إعداد التوجيه في التطبيق
class AppRouter {
  /// تكوين المسارات
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // الصفحة الرئيسية
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreenWrapper(),
      ),
      
      // إضافة معاملة
      GoRoute(
        path: '/add-transaction',
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      
      // عرض المعاملات
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsListScreen(),
      ),
      
      // تفاصيل المعاملة
      GoRoute(
        path: '/transaction/:id',
        name: 'transaction-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: id);
        },
      ),
      
      // الحسابات
      GoRoute(
        path: '/accounts',
        name: 'accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      
      // إضافة حساب
      GoRoute(
        path: '/add-account',
        name: 'add-account',
        builder: (context, state) => const AddAccountScreen(),
      ),
      
      // التقارير
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      
      // الإعدادات
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// غلاف الشاشة الرئيسية
class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    // سيتم استبداله بـ HomeScreen الفعلي
    return const Scaffold(
      body: Center(
        child: Text('جاري التحميل...'),
      ),
    );
  }
}

/// شاشة إضافة معاملة
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة معاملة'),
      ),
      body: const Center(
        child: Text('شاشة إضافة معاملة'),
      ),
    );
  }
}

/// شاشة قائمة المعاملات
class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المعاملات'),
      ),
      body: const Center(
        child: Text('قائمة المعاملات'),
      ),
    );
  }
}

/// شاشة تفاصيل المعاملة
class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;
  
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المعاملة'),
      ),
      body: Center(
        child: Text('تفاصيل المعاملة: $transactionId'),
      ),
    );
  }
}

/// شاشة إضافة حساب
class AddAccountScreen extends StatelessWidget {
  const AddAccountScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة حساب'),
      ),
      body: const Center(
        child: Text('شاشة إضافة حساب'),
      ),
    );
  }
}
