import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class CalendarGridView extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final List<TransactionEntity> transactions;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarGridView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.transactions,
    required this.onDateSelected,
  });

  static const List<String> _weekdays = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInCurrentMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    final daysInPrevMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      0,
    ).day;

    // ISO weekday: Monday = 1 ... Sunday = 7
    final leadingPadding = firstDayOfMonth.weekday - 1;
    final totalCells = leadingPadding + daysInCurrentMonth;
    final totalRows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        children: [
          // Weekdays Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) {
              final isWeekend = day == 'Sab' || day == 'Min';
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.caption.copyWith(
                      color: isWeekend
                          ? AppColors.expense.withOpacity(0.8)
                          : AppColors.textMutedDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardBorderDark, height: 1),
          const SizedBox(height: 12),

          // Monthly Calendar Grid
          for (int rowIndex = 0; rowIndex < totalRows; rowIndex++) ...[
            Row(
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;

                // Leading days from previous month
                if (cellIndex < leadingPadding) {
                  final prevDayNumber =
                      daysInPrevMonth - leadingPadding + cellIndex + 1;
                  return Expanded(
                    child: Center(
                      child: Text(
                        '$prevDayNumber',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMutedDark.withOpacity(0.25),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }

                // Days within current month
                final dayNumber = cellIndex - leadingPadding + 1;
                if (dayNumber <= daysInCurrentMonth) {
                  final date = DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    dayNumber,
                  );
                  final isSelected = AppDateUtils.isSameDay(date, selectedDate);
                  final isToday = AppDateUtils.isSameDay(date, DateTime.now());

                  // Filter transactions on this day
                  final dayTxs = transactions
                      .where((tx) => AppDateUtils.isSameDay(tx.date, date))
                      .toList();
                  final hasIncome = dayTxs.any(
                    (tx) => tx.type == TransactionType.income,
                  );
                  final hasExpense = dayTxs.any(
                    (tx) => tx.type == TransactionType.expense,
                  );

                  return Expanded(
                    child: InkWell(
                      onTap: () => onDateSelected(date),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : (isToday
                                    ? AppColors.primaryAccent.withOpacity(0.12)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(14),
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: AppColors.primaryAccent,
                                  width: 1.2,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryAccent.withOpacity(
                                      0.35,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isSelected
                                    ? Colors.black
                                    : (isToday
                                          ? AppColors.primaryAccent
                                          : AppColors.textPrimaryDark),
                                fontWeight: (isSelected || isToday)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Income & Expense Dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (hasIncome)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.black87
                                          : AppColors.income,
                                    ),
                                  ),
                                if (hasExpense)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFFB91C1C)
                                          : AppColors.expense,
                                    ),
                                  ),
                                if (!hasIncome && !hasExpense)
                                  const SizedBox(height: 5),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Trailing days from next month
                final nextDayNumber = dayNumber - daysInCurrentMonth;
                return Expanded(
                  child: Center(
                    child: Text(
                      '$nextDayNumber',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMutedDark.withOpacity(0.25),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (rowIndex < totalRows - 1) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
