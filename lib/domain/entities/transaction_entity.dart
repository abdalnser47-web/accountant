import 'package:equatable/equatable.dart';

/// نوع المعاملة المالية
enum TransactionType {
  income,    // دخل
  expense,   // مصروف
  transfer,  // تحويل
}

/// حالة المعاملة
enum TransactionStatus {
  pending,   // قيد الانتظار
  completed, // مكتملة
  cancelled, // ملغاة
}

/// كيان المعاملة المالية (نقي - لا يعتمد على Flutter أو JSON)
class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String categoryId;
  final String? categoryName;
  final String accountId;
  final String? accountName;
  final String? toAccountId;        // للتحويلات
  final String? toAccountName;      // للتحويلات
  final String? description;
  final DateTime date;
  final TransactionStatus status;
  final List<String>? tags;
  final Map<String, dynamic>? metadata; // بيانات إضافية
  final bool isSynced;              // حالة المزامنة
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // حقول النظام المحاسبي (Double Entry)
  final String? debitAccountId;     // حساب المدين
  final String? creditAccountId;    // حساب الدائن
  
  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'SAR',
    required this.categoryId,
    this.categoryName,
    required this.accountId,
    this.accountName,
    this.toAccountId,
    this.toAccountName,
    this.description,
    required this.date,
    this.status = TransactionStatus.completed,
    this.tags,
    this.metadata,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
    this.debitAccountId,
    this.creditAccountId,
  });
  
  /// إنشاء نسخة معدلة من الكيان
  TransactionEntity copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? currency,
    String? categoryId,
    String? categoryName,
    String? accountId,
    String? accountName,
    String? toAccountId,
    String? toAccountName,
    String? description,
    DateTime? date,
    TransactionStatus? status,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? debitAccountId,
    String? creditAccountId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      toAccountId: toAccountId ?? this.toAccountId,
      toAccountName: toAccountName ?? this.toAccountName,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      debitAccountId: debitAccountId ?? this.debitAccountId,
      creditAccountId: creditAccountId ?? this.creditAccountId,
    );
  }
  
  /// التحقق مما إذا كانت المعاملة دخل
  bool get isIncome => type == TransactionType.income;
  
  /// التحقق مما إذا كانت المعاملة مصروف
  bool get isExpense => type == TransactionType.expense;
  
  /// التحقق مما إذا كانت المعاملة تحويل
  bool get isTransfer => type == TransactionType.transfer;
  
  /// الحصول على المبلغ مع الإشارة (موجب للدخل، سالب للمصروف)
  double get signedAmount {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        return 0; // التحويلات لا تؤثر على صافي القيمة
    }
  }
  
  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        currency,
        categoryId,
        accountId,
        toAccountId,
        description,
        date,
        status,
        isSynced,
        debitAccountId,
        creditAccountId,
      ];
}
