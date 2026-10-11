import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, transfer }

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final int colorValue; // ARGB hex integer
  final TransactionType type;
  final double? monthlyBudgetLimit;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.type,
    this.monthlyBudgetLimit,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        colorValue,
        type,
        monthlyBudgetLimit,
      ];
}
