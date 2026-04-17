import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/account_entity.dart';

/// نموذج بيانات المعاملة للتخزين في Firestore
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    super.currency = 'SAR',
    required super.categoryId,
    super.categoryName,
    required super.accountId,
    super.accountName,
    super.toAccountId,
    super.toAccountName,
    super.description,
    required super.date,
    super.status = TransactionStatus.completed,
    super.tags,
    super.metadata,
    super.isSynced = false,
    super.createdAt,
    super.updatedAt,
    super.debitAccountId,
    super.creditAccountId,
  });
  
  /// إنشاء نموذج من كيان
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      amount: entity.amount,
      currency: entity.currency,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      accountId: entity.accountId,
      accountName: entity.accountName,
      toAccountId: entity.toAccountId,
      toAccountName: entity.toAccountName,
      description: entity.description,
      date: entity.date,
      status: entity.status,
      tags: entity.tags,
      metadata: entity.metadata,
      isSynced: entity.isSynced,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      debitAccountId: entity.debitAccountId,
      creditAccountId: entity.creditAccountId,
    );
  }
  
  /// إنشاء نموذج من خريطة Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'SAR',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'],
      accountId: data['accountId'] ?? '',
      accountName: data['accountName'],
      toAccountId: data['toAccountId'],
      toAccountName: data['toAccountName'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.completed,
      ),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      metadata: data['metadata'],
      isSynced: data['isSynced'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      debitAccountId: data['debitAccountId'],
      creditAccountId: data['creditAccountId'],
    );
  }
  
  /// تحويل النموذج إلى خريطة Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'currency': currency,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'accountId': accountId,
      'accountName': accountName,
      'toAccountId': toAccountId,
      'toAccountName': toAccountName,
      'description': description,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'tags': tags,
      'metadata': metadata,
      'isSynced': isSynced,
      'debitAccountId': debitAccountId,
      'creditAccountId': creditAccountId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
  
  @override
  TransactionModel copyWith({
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
    return TransactionModel(
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
}

/// نموذج الحساب المالي
class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    super.balance = 0.0,
    super.currency = 'SAR',
    super.icon,
    super.color,
    super.bankName,
    super.accountNumber,
    super.iban,
    super.creditLimit,
    super.availableCredit,
    super.isActive = true,
    super.isDefault = false,
    super.notes,
    super.metadata,
    super.isSynced = false,
    super.createdAt,
    super.updatedAt,
  });
  
  /// إنشاء نموذج من كيان
  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      balance: entity.balance,
      currency: entity.currency,
      icon: entity.icon,
      color: entity.color,
      bankName: entity.bankName,
      accountNumber: entity.accountNumber,
      iban: entity.iban,
      creditLimit: entity.creditLimit,
      availableCredit: entity.availableCredit,
      isActive: entity.isActive,
      isDefault: entity.isDefault,
      notes: entity.notes,
      metadata: entity.metadata,
      isSynced: entity.isSynced,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  /// إنشاء نموذج من خريطة Firestore
  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AccountType.other,
      ),
      balance: (data['balance'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'SAR',
      icon: data['icon'],
      color: data['color'],
      bankName: data['bankName'],
      accountNumber: data['accountNumber'],
      iban: data['iban'],
      creditLimit: data['creditLimit']?.toDouble(),
      availableCredit: data['availableCredit']?.toDouble(),
      isActive: data['isActive'] ?? true,
      isDefault: data['isDefault'] ?? false,
      notes: data['notes'],
      metadata: data['metadata'],
      isSynced: data['isSynced'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  /// تحويل النموذج إلى خريطة Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'iban': iban,
      'creditLimit': creditLimit,
      'availableCredit': availableCredit,
      'isActive': isActive,
      'isDefault': isDefault,
      'notes': notes,
      'metadata': metadata,
      'isSynced': isSynced,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
  
  @override
  AccountModel copyWith({
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
    return AccountModel(
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
}
