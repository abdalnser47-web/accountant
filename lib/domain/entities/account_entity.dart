import 'package:equatable/equatable.dart';

/// نوع الحساب المالي
enum AccountType {
  cash,      // نقدي
  bank,      // بنك
  credit,    // بطاقة ائتمان
  savings,   // توفير
  investment,// استثمار
  other,     // آخر
}

/// كيان الحساب المالي
class AccountEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;
  final String? bankName;         // اسم البنك (للحسابات البنكية)
  final String? accountNumber;    // رقم الحساب
  final String? iban;             // رقم الآيبان
  final double? creditLimit;      // حد الائتمان (للبطاقات الائتمانية)
  final double? availableCredit;  // الرصيد المتاح
  final bool isActive;
  final bool isDefault;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.currency = 'SAR',
    this.icon,
    this.color,
    this.bankName,
    this.accountNumber,
    this.iban,
    this.creditLimit,
    this.availableCredit,
    this.isActive = true,
    this.isDefault = false,
    this.notes,
    this.metadata,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });
  
  /// إنشاء نسخة معدلة من الكيان
  AccountEntity copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    String? icon,
    String? color,
    String? bankName,
    String? accountNumber,
    String? iban,
    double? creditLimit,
    double? availableCredit,
    bool? isActive,
    bool? isDefault,
    String? notes,
    Map<String, dynamic>? metadata,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      creditLimit: creditLimit ?? this.creditLimit,
      availableCredit: availableCredit ?? this.availableCredit,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// التحقق مما إذا كان الحساب بطاقة ائتمان
  bool get isCreditCard => type == AccountType.credit;
  
  /// التحقق مما إذا كان حساب بنكي
  bool get isBankAccount => type == AccountType.bank;
  
  /// التحقق مما إذا كان حساب نقدي
  bool get isCashAccount => type == AccountType.cash;
  
  /// الحصول على الرصيد الإجمالي (مع مراعاة حد الائتمان)
  double get totalBalance {
    if (isCreditCard && creditLimit != null) {
      return creditLimit! - balance;
    }
    return balance;
  }
  
  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        balance,
        currency,
        isActive,
        isDefault,
      ];
}
