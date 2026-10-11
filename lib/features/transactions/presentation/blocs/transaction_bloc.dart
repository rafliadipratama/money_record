import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/save_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final SaveTransaction saveTransactionUseCase;
  final DeleteTransaction deleteTransactionUseCase;

  StreamSubscription? _transactionSubscription;

  TransactionBloc({
    required this.transactionRepository,
    required this.categoryRepository,
    required this.saveTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionState.initial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<ChangeMonthEvent>(_onChangeMonth);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<TogglePrivacyModeEvent>(_onTogglePrivacyMode);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading, selectedMonth: event.month));

    try {
      final categories = await categoryRepository.getCategories();
      await _transactionSubscription?.cancel();

      // Listen to reactive stream from SQLite repository
      await emit.forEach(
        transactionRepository.watchTransactionsByMonth(event.month),
        onData: (transactions) {
          double totalIncome = 0;
          double totalExpense = 0;
          final Map<int, double> dailyExpenses = {};
          final Map<int, double> dailyIncomes = {};
          final Map<String, double> categoryBreakdown = {};

          for (final tx in transactions) {
            final day = tx.date.day;
            if (tx.type.name == 'income') {
              totalIncome += tx.amount;
              dailyIncomes[day] = (dailyIncomes[day] ?? 0.0) + tx.amount;
            } else if (tx.type.name == 'expense') {
              totalExpense += tx.amount;
              dailyExpenses[day] = (dailyExpenses[day] ?? 0.0) + tx.amount;
              categoryBreakdown[tx.categoryId] =
                  (categoryBreakdown[tx.categoryId] ?? 0.0) + tx.amount;
            }
          }

          final netSavings = totalIncome - totalExpense;
          final savingsRate =
              totalIncome > 0 ? (netSavings / totalIncome) * 100 : 0.0;

          final computedSummary = state.summary.copyWithMonthAndData(
            month: event.month,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            netSavings: netSavings,
            savingsRate: savingsRate,
            dailyExpenses: dailyExpenses,
            dailyIncomes: dailyIncomes,
            categoryBreakdown: categoryBreakdown,
            transactionCount: transactions.length,
          );

          return state.copyWith(
            status: TransactionStatus.success,
            transactions: transactions,
            categories: categories,
            summary: computedSummary,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: TransactionStatus.failure,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonthEvent event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactionsEvent(event.month));
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await saveTransactionUseCase(event.transaction);
      final summary = await transactionRepository.getMonthlySummary(state.selectedMonth);
      emit(state.copyWith(summary: summary));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await deleteTransactionUseCase(event.id);
      final summary = await transactionRepository.getMonthlySummary(state.selectedMonth);
      emit(state.copyWith(summary: summary));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onTogglePrivacyMode(
    TogglePrivacyModeEvent event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(isPrivacyMode: !state.isPrivacyMode));
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
