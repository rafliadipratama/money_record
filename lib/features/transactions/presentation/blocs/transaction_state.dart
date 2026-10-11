import 'package:equatable/equatable.dart';

import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/transaction_entity.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final DateTime selectedMonth;
  final List<TransactionEntity> transactions;
  final MonthlySummary summary;
  final List<CategoryEntity> categories;
  final bool isPrivacyMode;
  final String? errorMessage;

  const TransactionState({
    required this.status,
    required this.selectedMonth,
    required this.transactions,
    required this.summary,
    required this.categories,
    required this.isPrivacyMode,
    this.errorMessage,
  });

  factory TransactionState.initial() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    return TransactionState(
      status: TransactionStatus.initial,
      selectedMonth: currentMonth,
      transactions: const [],
      summary: MonthlySummary.empty(currentMonth),
      categories: const [],
      isPrivacyMode: false,
    );
  }

  TransactionState copyWith({
    TransactionStatus? status,
    DateTime? selectedMonth,
    List<TransactionEntity>? transactions,
    MonthlySummary? summary,
    List<CategoryEntity>? categories,
    bool? isPrivacyMode,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      categories: categories ?? this.categories,
      isPrivacyMode: isPrivacyMode ?? this.isPrivacyMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedMonth,
    transactions,
    summary,
    categories,
    isPrivacyMode,
    errorMessage,
  ];
}
