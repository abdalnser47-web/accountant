import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/account_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// شاشة إضافة معاملة جديدة (دخل/مصروف/تحويل)
/// تدعم النظام المحاسبي Double Entry بشكل تلقائي
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // حقول النموذج
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  
  // نوع المعاملة
  TransactionType _transactionType = TransactionType.expense;
  
  // الحسابات والتصنيفات المختارة
  String? _selectedAccountId;
  String? _selectedCategoryId;
  
  // التاريخ والوقت
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // هل هذه معاملة متكررة؟
  bool _isRecurring = false;
  RecurringFrequency? _recurringFrequency;
  
  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  void _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
      );
      return;
    }
    
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار حساب')),
      );
      return;
    }
    
    // إنشاء كائن المعاملة
    final transaction = TransactionEntity(
      id: UniqueKey().toString(),
      amount: amount,
      type: _transactionType,
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      isRecurring: _isRecurring,
      recurringFrequency: _recurringFrequency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    try {
      // إضافة المعاملة عبر Riverpod Provider
      await ref.read(transactionProvider.notifier).addTransaction(transaction);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_transactionType == TransactionType.income 
                ? 'تم إضافة الدخل بنجاح' 
                : 'تم إضافة المصروف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // العودة للشاشة السابقة
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'إضافة معاملة',
        onBack: () => context.pop(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- نوع المعاملة ---
            _buildTransactionTypeSelector(),
            
            const SizedBox(height: 24),
            
            // --- المبلغ ---
            CustomTextField(
              controller: _amountController,
              label: 'المبلغ',
              hint: 'أدخل المبلغ',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              suffixText: 'ر.س',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المبلغ';
                }
                if (double.tryParse(value) == null) {
                  return 'مبلغ غير صحيح';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // --- الحساب ---
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'الحساب',
                hintText: 'اختر الحساب',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.account_balance_wallet),
              ),
              value: _selectedAccountId,
              items: accounts.when(
                data: (data) => data.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text('${account.name} (${account.balance.toStringAsFixed(2)} ر.س)'),
                  );
                }).toList(),
                loading: () => const [DropdownMenuItem(child: Text('جاري التحميل...'))],
                error: (_, __) => const [DropdownMenuItem(child: Text('خطأ في تحميل الحسابات'))],
              ),
              onChanged: (value) {
                setState(() {
                  _selectedAccountId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'الرجاء اختيار حساب';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // --- التصنيف (للمصروفات والدخل فقط) ---
            if (_transactionType != TransactionType.transfer)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'التصنيف',
                  hintText: 'اختر التصنيف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                value: _selectedCategoryId,
                items: categories.when(
                  data: (data) => data
                      .where((cat) => cat.type == CategoryType.values.firstWhere(
                            (t) => t.name == (_transactionType == TransactionType.expense ? 'expense' : 'income'),
                            orElse: () => CategoryType.expense,
                          ))
                      .map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          if (category.icon != null)
                            Icon(category.icon, size: 20, color: category.color),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  loading: () => const [DropdownMenuItem(child: Text('جاري التحميل...'))],
                  error: (_, __) => const [DropdownMenuItem(child: Text('خطأ في تحميل التصنيفات'))],
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            
            const SizedBox(height: 16),
            
            // --- التاريخ والوقت ---
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'التاريخ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'الوقت',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // --- الملاحظات ---
            CustomTextField(
              controller: _noteController,
              label: 'ملاحظات (اختياري)',
              hint: 'أضف ملاحظات إضافية',
              maxLines: 3,
              prefixIcon: Icons.note,
            ),
            
            const SizedBox(height: 24),
            
            // --- معاملة متكررة ---
            SwitchListTile(
              title: const Text('معاملة متكررة'),
              subtitle: const Text('تكرار شهري/أسبوعي/سنوي'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
              secondary: const Icon(Icons.repeat),
            ),
            
            if (_isRecurring) ...[
              DropdownButtonFormField<RecurringFrequency>(
                decoration: InputDecoration(
                  labelText: 'تكرار',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _recurringFrequency ?? RecurringFrequency.monthly,
                items: RecurringFrequency.values.map((freq) {
                  String displayValue;
                  switch (freq) {
                    case RecurringFrequency.daily:
                      displayValue = 'يومي';
                      break;
                    case RecurringFrequency.weekly:
                      displayValue = 'أسبوعي';
                      break;
                    case RecurringFrequency.monthly:
                      displayValue = 'شهري';
                      break;
                    case RecurringFrequency.yearly:
                      displayValue = 'سنوي';
                      break;
                  }
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(displayValue),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _recurringFrequency = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            
            const SizedBox(height: 24),
            
            // --- زر الإضافة ---
            CustomButton(
              text: 'إضافة المعاملة',
              onPressed: _submitTransaction,
              icon: Icons.add_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
  
  ///_widget محدد لنوع المعاملة (دخل/مصروف/تحويل)
  Widget _buildTransactionTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.expense,
              icon: Icons.shopping_cart,
              label: 'مصروف',
              color: Colors.red,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              icon: Icons.payment,
              label: 'دخل',
              color: Colors.green,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.transfer,
              icon: Icons.swap_horiz,
              label: 'تحويل',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeButton({
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _transactionType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _transactionType = type;
          // إعادة تعيين التصنيف عند تغيير النوع
          _selectedCategoryId = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
