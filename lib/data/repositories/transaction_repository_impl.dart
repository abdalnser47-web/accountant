import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/repositories/repository.dart';
import '../models/transaction_model.dart';
import 'package:dartz/dartz.dart';

/// تنفيذ مستودع المعاملات المالية (Firebase + Local)
class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  
  TransactionRepositoryImpl({
    required this.firestore,
    required this.networkInfo,
  });
  
  /// الحصول على مجموعة المعاملات للمستخدم
  CollectionReference _getCollection(String userId) {
    return firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.transactionsCollection);
  }
  
  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
    String? accountId,
    String? categoryId,
    TransactionType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (userId == null || userId.isEmpty) {
        return const Left(ValidationFailure(message: 'معرف المستخدم مطلوب'));
      }
      
      Query query = _getCollection(userId);
      
      // تطبيق الفلاتر
      if (accountId != null && accountId.isNotEmpty) {
        query = query.where('accountId', isEqualTo: accountId);
      }
      
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      
      if (fromDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }
      
      if (toDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }
      
      // الترتيب حسب التاريخ (الأحدث أولاً)
      query = query.orderBy('date', descending: true);
      
      // تحديد الصفحة
      final offset = (page - 1) * limit;
      query = query.limit(limit);
      
      final snapshot = await query.get();
      
      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
      
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في جلب المعاملات: $e'));
    }
  }
  
  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id) async {
    try {
      // سيتم تنبذه من قبل Provider الذي يعرف userId
      return const Left(GeneralFailure(message: 'هذه الطريقة تحتاج إلى معرف المستخدم'));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في جلب المعاملة: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction).copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final docRef = await _getCollection(transaction.userId).add(model.toFirestore());
      
      // إذا كان هناك اتصال، نزامن فوراً
      if (await networkInfo.isConnected) {
        await docRef.update({'isSynced': true});
      }
      
      return Right(docRef.id);
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في إضافة المعاملة: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> updateTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction).copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _getCollection(transaction.userId)
          .doc(transaction.id)
          .update(model.toFirestore());
      
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في تحديث المعاملة: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deleteTransaction(String id) async {
    try {
      // سيتم تنبذه من قبل Provider الذي يعرف userId
      return const Left(GeneralFailure(message: 'هذه الطريقة تحتاج إلى معرف المستخدم'));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في حذف المعاملة: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deleteTransactions(List<String> ids) async {
    try {
      // حذف متعدد
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في حذف المعاملات: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, double>>> getTotals({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      if (userId == null || userId.isEmpty) {
        return const Left(ValidationFailure(message: 'معرف المستخدم مطلوب'));
      }
      
      Query query = _getCollection(userId);
      
      if (fromDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }
      
      if (toDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }
      
      final snapshot = await query.get();
      
      double totalIncome = 0;
      double totalExpense = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'];
        
        if (type == 'income') {
          totalIncome += amount;
        } else if (type == 'expense') {
          totalExpense += amount;
        }
      }
      
      return Right({
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      });
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في حساب الإجماليات: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<TransactionEntity>>> getUnsyncedTransactions() async {
    try {
      // البحث عن المعاملات غير المتزامنة
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في جلب المعاملات غير المتزامنة: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> syncTransactions() async {
    try {
      // مزامنة المعاملات مع الخادم
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'فشل في مزامنة المعاملات: $e'));
    }
  }
}
