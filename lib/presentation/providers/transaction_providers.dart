import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/network/network_info.dart';
import '../../../domain/repositories/repository.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../../repositories/transaction_repository_impl.dart';

/// Provider لخدمة الاتصال بالشبكة
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

/// Provider لمستودع المعاملات
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final networkInfo = ref.watch(networkInfoProvider);
  
  return TransactionRepositoryImpl(
    firestore: firestore,
    networkInfo: networkInfo,
  );
});

/// Provider لحالة استخدام إضافة معاملة
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return AddTransactionUseCase(repository);
});

/// Provider لحالة استخدام الحصول على المعاملات
final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUseCase(repository);
});

/// Provider لحالة استخدام حذف معاملة
final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return DeleteTransactionUseCase(repository);
});

/// Provider لحالة استخدام الحصول على الإجماليات
final getTotalsUseCaseProvider = Provider<GetTotalsUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTotalsUseCase(repository);
});

/// حالة بيانات المعاملات
class TransactionsState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<dynamic> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  
  const TransactionsState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.transactions = const [],
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.balance = 0.0,
  });
  
  TransactionsState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<dynamic>? transactions,
    double? totalIncome,
    double? totalExpense,
    double? balance,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
    );
  }
}

/// Provider لإدارة حالة المعاملات
final transactionsStateProvider = StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  return TransactionsNotifier(
    getTransactionsUseCase: ref.watch(getTransactionsUseCaseProvider),
    getTotalsUseCase: ref.watch(getTotalsUseCaseProvider),
  );
});

/// Notifier لإدارة حالة المعاملات
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetTotalsUseCase getTotalsUseCase;
  
  TransactionsNotifier({
    required this.getTransactionsUseCase,
    required this.getTotalsUseCase,
  }) : super(const TransactionsState());
  
  /// تحميل المعاملات
  Future<void> loadTransactions({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    state = state.copyWith(isLoading: true, hasError: false);
    
    final result = await getTransactionsUseCase(GetTransactionsParams(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    ));
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        );
      },
      (transactions) {
        state = state.copyWith(
          isLoading: false,
          transactions: transactions,
        );
      },
    );
  }
  
  /// تحميل الإجماليات
  Future<void> loadTotals({
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final result = await getTotalsUseCase(GetTotalsParams(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    ));
    
    result.fold(
      (failure) {
        // لا نظهر الخطأ هنا لتجنب الإزعاج
      },
      (totals) {
        state = state.copyWith(
          totalIncome: totals['income'] ?? 0.0,
          totalExpense: totals['expense'] ?? 0.0,
          balance: totals['balance'] ?? 0.0,
        );
      },
    );
  }
  
  /// إعادة تعيين الحالة
  void reset() {
    state = const TransactionsState();
  }
}
