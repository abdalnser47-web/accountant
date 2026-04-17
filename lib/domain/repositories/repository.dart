import '../entities/transaction_entity.dart';
import '../entities/account_entity.dart';
import '../entities/category_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// مستودع المعاملات المالية
abstract class TransactionRepository {
  /// الحصول على قائمة المعاملات
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
    String? accountId,
    String? categoryId,
    TransactionType? type,
    int page = 1,
    int limit = 20,
  });
  
  /// الحصول على معاملة محددة
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);
  
  /// إضافة معاملة جديدة
  Future<Either<Failure, String>> addTransaction(TransactionEntity transaction);
  
  /// تحديث معاملة موجودة
  Future<Either<Failure, bool>> updateTransaction(TransactionEntity transaction);
  
  /// حذف معاملة
  Future<Either<Failure, bool>> deleteTransaction(String id);
  
  /// حذف مجموعة من المعاملات
  Future<Either<Failure, bool>> deleteTransactions(List<String> ids);
  
  /// الحصول على إجمالي الدخل والمصروفات لفترة معينة
  Future<Either<Failure, Map<String, double>>> getTotals({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  /// الحصول على المعاملات غير المتزامنة
  Future<Either<Failure, List<TransactionEntity>>> getUnsyncedTransactions();
  
  /// مزامنة المعاملات مع الخادم
  Future<Either<Failure, bool>> syncTransactions();
}

/// مستودع الحسابات المالية
abstract class AccountRepository {
  /// الحصول على قائمة الحسابات
  Future<Either<Failure, List<AccountEntity>>> getAccounts({String? userId});
  
  /// الحصول على حساب محدد
  Future<Either<Failure, AccountEntity>> getAccountById(String id);
  
  /// إضافة حساب جديد
  Future<Either<Failure, String>> addAccount(AccountEntity account);
  
  /// تحديث حساب موجود
  Future<Either<Failure, bool>> updateAccount(AccountEntity account);
  
  /// حذف حساب
  Future<Either<Failure, bool>> deleteAccount(String id);
  
  /// تحديث رصيد الحساب
  Future<Either<Failure, bool>> updateBalance(String id, double newBalance);
  
  /// الحصول على الحساب الافتراضي
  Future<Either<Failure, AccountEntity?>> getDefaultAccount();
  
  /// الحصول على الحسابات غير المتزامنة
  Future<Either<Failure, List<AccountEntity>>> getUnsyncedAccounts();
  
  /// مزامنة الحسابات مع الخادم
  Future<Either<Failure, bool>> syncAccounts();
}

/// مستودع التصنيفات
abstract class CategoryRepository {
  /// الحصول على قائمة التصنيفات
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String? userId,
    CategoryType? type,
  });
  
  /// الحصول على تصنيف محدد
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);
  
  /// إضافة تصنيف جديد
  Future<Either<Failure, String>> addCategory(CategoryEntity category);
  
  /// تحديث تصنيف موجود
  Future<Either<Failure, bool>> updateCategory(CategoryEntity category);
  
  /// حذف تصنيف
  Future<Either<Failure, bool>> deleteCategory(String id);
  
  /// الحصول على التصنيفات الافتراضية
  Future<Either<Failure, List<CategoryEntity>>> getDefaultCategories();
  
  /// تهيئة التصنيفات الافتراضية
  Future<Either<Failure, bool>> initializeDefaultCategories(String userId);
}
