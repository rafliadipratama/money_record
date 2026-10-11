import 'package:equatable/equatable.dart';

class MonthlySummary extends Equatable {
  final DateTime month;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate;
  final Map<int, double> dailyExpenses;
  final Map<int, double> dailyIncomes;
  final Map<String, double> categoryBreakdown;
  final int transactionCount;

  const MonthlySummary({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.dailyExpenses,
    required this.dailyIncomes,
    required this.categoryBreakdown,
    required this.transactionCount,
  });

  factory MonthlySummary.empty(DateTime month) {
    return MonthlySummary(
      month: month,
      totalIncome: 0.0,
      totalExpense: 0.0,
      netSavings: 0.0,
      savingsRate: 0.0,
      dailyExpenses: const {},
      dailyIncomes: const {},
      categoryBreakdown: const {},
      transactionCount: 0,
    );
  }

  MonthlySummary copyWithMonthAndData({
    DateTime? month,
    double? totalIncome,
    double? totalExpense,
    double? netSavings,
    double? savingsRate,
    Map<int, double>? dailyExpenses,
    Map<int, double>? dailyIncomes,
    Map<String, double>? categoryBreakdown,
    int? transactionCount,
  }) {
    return MonthlySummary(
      month: month ?? this.month,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netSavings: netSavings ?? this.netSavings,
      savingsRate: savingsRate ?? this.savingsRate,
      dailyExpenses: dailyExpenses ?? this.dailyExpenses,
      dailyIncomes: dailyIncomes ?? this.dailyIncomes,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  List<Object?> get props => [
    month,
    totalIncome,
    totalExpense,
    netSavings,
    savingsRate,
    dailyExpenses,
    dailyIncomes,
    categoryBreakdown,
    transactionCount,
  ];
}
