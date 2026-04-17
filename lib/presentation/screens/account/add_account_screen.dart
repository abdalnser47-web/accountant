import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/account_entity.dart';
import '../../providers/account_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// شاشة إضافة حساب جديد (نقد/بنك/بطاقة ائتمان)
class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _descriptionController;
  
  AccountType _accountType = AccountType.cash;
  String? _currency;
  bool _isActive = true;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController(text: '0');
    _descriptionController = TextEditingController();
    _currency = 'SAR'; // القيمة الافتراضية
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _submitAccount() async {
    if (!_formKey.currentState!.validate()) return;
    
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الحساب')),
      );
      return;
    }
    
    final account = AccountEntity(
      id: UniqueKey().toString(),
      name: name,
      type: _accountType,
      balance: balance,
      currency: _currency ?? 'SAR',
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    try {
      await ref.read(accountProvider.notifier).addAccount(account);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الحساب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'إضافة حساب',
        onBack: () => context.pop(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- نوع الحساب ---
            _buildAccountTypeSelector(),
            
            const SizedBox(height: 24),
            
            // --- اسم الحساب ---
            CustomTextField(
              controller: _nameController,
              label: 'اسم الحساب',
              hint: 'مثال: محفظة نقدية، بنك الراجحي...',
              prefixIcon: Icons.account_balance_wallet,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم الحساب';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // --- الرصيد الأولي ---
            CustomTextField(
              controller: _balanceController,
              label: 'الرصيد الأولي',
              hint: 'أدخل الرصيد الحالي',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              suffixText: _currency ?? 'ر.س',
              validator: (value) {
                if (value == null) {
                  return 'الرجاء إدخال الرصيد';
                }
                if (double.tryParse(value) == null) {
                  return 'رصيد غير صحيح';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // --- العملة ---
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'العملة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.currency_exchange),
              ),
              value: _currency,
              items: const [
                DropdownMenuItem(value: 'SAR', child: Text('ريال سعودي - SAR')),
                DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي - USD')),
                DropdownMenuItem(value: 'EUR', child: Text('يورو - EUR')),
                DropdownMenuItem(value: 'GBP', child: Text('جنيه إسترليني - GBP')),
                DropdownMenuItem(value: 'AED', child: Text('درهم إماراتي - AED')),
                DropdownMenuItem(value: 'KWD', child: Text('دينار كويتي - KWD')),
                DropdownMenuItem(value: 'EGP', child: Text('جنيه مصري - EGP')),
              ],
              onChanged: (value) {
                setState(() {
                  _currency = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // --- وصف الحساب ---
            CustomTextField(
              controller: _descriptionController,
              label: 'وصف الحساب (اختياري)',
              hint: 'ملاحظات إضافية عن الحساب',
              maxLines: 3,
              prefixIcon: Icons.description,
            ),
            
            const SizedBox(height: 16),
            
            // --- حالة الحساب ---
            SwitchListTile(
              title: const Text('حساب نشط'),
              subtitle: const Text('يمكن تعطيل الحسابات غير المستخدمة'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: const Icon(Icons.check_circle_outline),
            ),
            
            const SizedBox(height: 32),
            
            // --- زر الإضافة ---
            CustomButton(
              text: 'إضافة الحساب',
              onPressed: _submitAccount,
              icon: Icons.add_account,
            ),
          ],
        ),
      ),
    );
  }
  
  /// widget محدد لنوع الحساب
  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الحساب',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  type: AccountType.cash,
                  icon: Icons.money,
                  label: 'نقدي',
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  type: AccountType.bank,
                  icon: Icons.account_balance,
                  label: 'بنك',
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  type: AccountType.credit_card,
                  icon: Icons.credit_card,
                  label: 'بطاقة ائتمان',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTypeButton({
    required AccountType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _accountType == type;
    final color = isSelected 
        ? Theme.of(context).primaryColor 
        : Colors.grey;
    
    return InkWell(
      onTap: () {
        setState(() {
          _accountType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.2) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
