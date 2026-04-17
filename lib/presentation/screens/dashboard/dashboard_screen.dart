import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/statistics_provider.dart';
import '../widgets/custom_app_bar.dart';

/// شاشة dashboard الرئيسية تعرض:
/// - ملخص الرصيد الكلي
/// - الدخل والمصروفات للشهر الحالي
/// - رسم بياني للمصروفات حسب التصنيف
/// - رسم بياني للدخل والمصروفات خلال الأشهر
/// - آخر المعاملات
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedPeriod = 0; // 0: اليوم، 1: الأسبوع، 2: الشهر، 3: السنة
  
  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider(limit: 5));
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'لوحة التحكم',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showPeriodFilter(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(statisticsProvider.future);
          await ref.refresh(recentTransactionsProvider(limit: 5).future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- ملخص الرصيد الكلي ---
            _buildTotalBalanceCard(),
            
            const SizedBox(height: 16),
            
            // --- بطاقات الدخل والمصروفات ---
            Row(
              children: [
                Expanded(child: _buildIncomeExpenseCard(isIncome: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildIncomeExpenseCard(isIncome: false)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // --- الرسم البياني الدائري للتصنيفات ---
            _buildCategoryPieChart(statistics),
            
            const SizedBox(height: 24),
            
            // --- الرسم البياني الشريطي الشهري ---
            _buildMonthlyBarChart(),
            
            const SizedBox(height: 24),
            
            // --- آخر المعاملات ---
            _buildRecentTransactions(recentTransactions),
            
            const SizedBox(height: 16),
            
            // --- زر عرض كل التقارير ---
            ElevatedButton.icon(
              onPressed: () {
                // الانتقال لشاشة التقارير
                // context.push('/reports');
              },
              icon: const Icon(Icons.assessment),
              label: const Text('عرض جميع التقارير'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// بطاقة الرصيد الكلي
  Widget _buildTotalBalanceCard() {
    final totalBalance = ref.watch(totalBalanceProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الرصيد الكلي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          totalBalance.when(
            data: (balance) => Text(
              '${balance.toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            error: (_, __) => const Text(
              'خطأ في التحميل',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStatItem(
                icon: Icons.trending_up,
                label: 'الدخل',
                value: ref.watch(monthlyIncomeProvider),
                color: Colors.greenAccent,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildMiniStatItem(
                icon: Icons.trending_down,
                label: 'المصروفات',
                value: ref.watch(monthlyExpenseProvider),
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStatItem({
    required IconData icon,
    required String label,
    required AsyncValue<double> value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        value.when(
          data: (val) => Text(
            '${val.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          loading: () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          error: (_, __) => const Text('-', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
  
  /// بطاقة الدخل أو المصروفات
  Widget _buildIncomeExpenseCard({required bool isIncome}) {
    final provider = isIncome ? monthlyIncomeProvider : monthlyExpenseProvider;
    final value = ref.watch(provider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIncome 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIncome 
              ? Colors.green.withOpacity(0.3) 
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isIncome ? 'دخل الشهر' : 'مصروفات الشهر',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          value.when(
            data: (val) => Text(
              '${val.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const CircularProgressIndicator(strokeWidth: 2),
            error: (_, __) => const Text('خطأ'),
          ),
        ],
      ),
    );
  }
  
  /// الرسم البياني الدائري للتصنيفات
  Widget _buildCategoryPieChart(AsyncValue<Map<String, double>> statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المصروفات حسب التصنيف',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: statistics.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(
                  child: Text('لا توجد بيانات لعرضها'),
                );
              }
              
              final sections = data.entries.map((entry) {
                return PieChartSectionData(
                  value: entry.value,
                  title: '${entry.value.toStringAsFixed(0)}%',
                  color: _getCategoryColor(entry.key),
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList();
              
              return PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('خطأ في تحميل البيانات')),
          ),
        ),
      ],
    );
  }
  
  /// الرسم البياني الشريطي الشهري
  Widget _buildMonthlyBarChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الدخل والمصروفات (آخر 6 أشهر)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10000, // يجب حسابها ديناميكياً
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toStringAsFixed(0),
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = ['يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          months[value.toInt() % 6],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: 5000, color: Colors.green, width: 12),
                  BarChartRodData(toY: 3000, color: Colors.red, width: 12),
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: 6000, color: Colors.green, width: 12),
                  BarChartRodData(toY: 4500, color: Colors.red, width: 12),
                ]),
                // ... المزيد من البيانات
              ],
              groupsSpace: 12,
            ),
          ),
        ),
      ],
    );
  }
  
  /// قائمة آخر المعاملات
  Widget _buildRecentTransactions(AsyncValue<dynamic> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'آخر المعاملات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // الانتقال لصفحة كل المعاملات
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        transactions.when(
          data: (data) {
            if (data == null || (data as List).isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('لا توجد معاملات حديثة'),
                ),
              );
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final transaction = data[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.type == 'income' 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.red.withOpacity(0.2),
                      child: Icon(
                        transaction.type == 'income' 
                            ? Icons.arrow_downward 
                            : Icons.arrow_upward,
                        color: transaction.type == 'income' 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                    title: Text(transaction.note ?? 'بدون وصف'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(transaction.date)),
                    trailing: Text(
                      '${transaction.amount.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        color: transaction.type == 'income' 
                            ? Colors.green 
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('خطأ في التحميل')),
        ),
      ],
    );
  }
  
  void _showPeriodFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('اليوم'),
              onTap: () {
                setState(() => _selectedPeriod = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('الأسبوع'),
              onTap: () {
                setState(() => _selectedPeriod = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('الشهر'),
              onTap: () {
                setState(() => _selectedPeriod = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('السنة'),
              onTap: () {
                setState(() => _selectedPeriod = 3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String categoryId) {
    // ألوان عشوائية للتصنيفات
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[categoryId.hashCode % colors.length];
  }
}
