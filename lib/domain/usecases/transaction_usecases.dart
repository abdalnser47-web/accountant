import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/repository.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// حالة استخدام إضافة معاملة مالية
class AddTransactionUseCase {
  final TransactionRepository repository;
  
  AddTransactionUseCase(this.repository);
  
  Future<Either<Failure, String>> call(AddTransactionParams params) async {
    // التحقق من صحة البيانات
    final validationFailure = _validate(params);
    if (validationFailure != null) {
      return Left(validationFailure);
    }
    
    // إنشاء كيان المعاملة
    final transaction = TransactionEntity(
      id: '', // سيتم إنشاؤه بواسطة المستودع
      userId: params.userId,
      type: params.type,
      amount: params.amount,
      currency: params.currency,
      categoryId: params.categoryId,
      accountId: params.accountId,
      toAccountId: params.toAccountId,
      description: params.description,
      date: params.date,
      tags: params.tags,
      isSynced: false,
    );
    
    // إضافة المعاملة
    return await repository.addTransaction(transaction);
  }
  
  /// التحقق من صحة البيانات
  Failure? _validate(AddTransactionParams params) {
    if (params.amount <= 0) {
      return const ValidationFailure(message: 'المبلغ يجب أن يكون أكبر من صفر');
    }
    
    if (params.userId.isEmpty) {
      return const ValidationFailure(message: 'معرف المستخدم مطلوب');
    }
    
    if (params.categoryId.isEmpty) {
      return const ValidationFailure(message: 'التصنيف مطلوب');
    }
    
    if (params.accountId.isEmpty) {
      return const ValidationFailure(message: 'الحساب مطلوب');
    }
    
    if (params.type == TransactionType.transfer && params.toAccountId == null) {
      return const ValidationFailure(message: 'الحساب الوجهة مطلوب للتحويلات');
    }
    
    return null;
  }
}

/// معلمات إضافة معاملة
class AddTransactionParams extends Equatable {
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String categoryId;
  final String accountId;
  final String? toAccountId;
  final String? description;
  final DateTime date;
  final List<String>? tags;
  
  const AddTransactionParams({
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'SAR',
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    this.description,
    required this.date,
    this.tags,
  });
  
  @override
  List<Object?> get props => [
        userId,
        type,
        amount,
        currency,
        categoryId,
        accountId,
        toAccountId,
        description,
        date,
      ];
}

/// حالة استخدام الحصول على قائمة المعاملات
class GetTransactionsUseCase {
  final TransactionRepository repository;
  
  GetTransactionsUseCase(this.repository);
  
  Future<Either<Failure, List<TransactionEntity>>> call(GetTransactionsParams params) async {
    return await repository.getTransactions(
      userId: params.userId,
      fromDate: params.fromDate,
      toDate: params.toDate,
      accountId: params.accountId,
      categoryId: params.categoryId,
      type: params.type,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// معلمات الحصول على المعاملات
class GetTransactionsParams extends Equatable {
  final String? userId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? accountId;
  final String? categoryId;
  final TransactionType? type;
  final int page;
  final int limit;
  
  const GetTransactionsParams({
    this.userId,
    this.fromDate,
    this.toDate,
    this.accountId,
    this.categoryId,
    this.type,
    this.page = 1,
    this.limit = 20,
  });
  
  @override
  List<Object?> get props => [
        userId,
        fromDate,
        toDate,
        accountId,
        categoryId,
        type,
        page,
        limit,
      ];
}

/// حالة استخدام حذف معاملة
class DeleteTransactionUseCase {
  final TransactionRepository repository;
  
  DeleteTransactionUseCase(this.repository);
  
  Future<Either<Failure, bool>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure(message: 'معرف المعاملة مطلوب'));
    }
    return await repository.deleteTransaction(id);
  }
}

/// حالة استخدام الحصول على الإجماليات
class GetTotalsUseCase {
  final TransactionRepository repository;
  
  GetTotalsUseCase(this.repository);
  
  Future<Either<Failure, Map<String, double>>> call(GetTotalsParams params) async {
    return await repository.getTotals(
      userId: params.userId,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

/// معلمات الحصول على الإجماليات
class GetTotalsParams extends Equatable {
  final String? userId;
  final DateTime? fromDate;
  final DateTime? toDate;
  
  const GetTotalsParams({
    this.userId,
    this.fromDate,
    this.toDate,
  });
  
  @override
  List<Object?> get props => [userId, fromDate, toDate];
}
