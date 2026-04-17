import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../providers/transaction_providers.dart';

/// الشاشة الرئيسية للتطبيق
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),      // لوحة التحكم
    const TransactionsScreen(),   // المعاملات
    const AccountsScreen(),       // الحسابات
    const ReportsScreen(),        // التقارير
    const SettingsScreen(),       // الإعدادات
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'المعاملات',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'الحسابات',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'التقارير',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // الانتقال لإضافة معاملة جديدة
          context.push('/add-transaction');
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
    );
  }
}

/// شاشة لوحة التحكم
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsStateProvider);
    
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('لوحة التحكم'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
        
        // ملخص الرصيد
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد الإجمالي',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${transactionsState.balance.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            'الدخل',
                            '+${transactionsState.totalIncome.toStringAsFixed(2)}',
                            Icons.arrow_downward,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            'المصروفات',
                            '-${transactionsState.totalExpense.toStringAsFixed(2)}',
                            Icons.arrow_upward,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // آخر المعاملات
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'آخر المعاملات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/transactions');
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
          ),
        ),
        
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: transactionsState.isLoading
              ? const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              : transactionsState.transactions.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('لا توجد معاملات بعد'),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final transaction = transactionsState.transactions[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                transaction.type == 'income'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                              ),
                            ),
                            title: Text(transaction.description ?? 'بدون وصف'),
                            subtitle: Text(transaction.categoryName ?? ''),
                            trailing: Text(
                              '${transaction.amount.toStringAsFixed(2)} ر.س',
                              style: TextStyle(
                                color: transaction.type == 'income'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        childCount: transactionsState.transactions.length > 5
                            ? 5
                            : transactionsState.transactions.length,
                      ),
                    ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// شاشة المعاملات
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المعاملات'),
      ),
      body: const Center(
        child: Text('شاشة المعاملات'),
      ),
    );
  }
}

/// شاشة الحسابات
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحسابات'),
      ),
      body: const Center(
        child: Text('شاشة الحسابات'),
      ),
    );
  }
}

/// شاشة التقارير
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
      ),
      body: const Center(
        child: Text('شاشة التقارير'),
      ),
    );
  }
}

/// شاشة الإعدادات
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: const Center(
        child: Text('شاشة الإعدادات'),
      ),
    );
  }
}
